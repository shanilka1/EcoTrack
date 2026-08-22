const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function to securely complete an eco activity, advance active challenges,
 * evaluate achievement milestones, and award eco points atomically.
 */
exports.completeEcoActivity = functions.https.onCall(async (data, context) => {
  // 1. Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to complete an activity."
    );
  }

  const userId = context.auth.uid;
  const { activityId } = data;

  if (!activityId || typeof activityId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with a valid activityId."
    );
  }

  const now = new Date();
  const dateKey = now.toISOString().split("T")[0]; // YYYY-MM-DD
  const completionDocId = `${activityId}_${dateKey}`;

  const activityDocRef = db.collection("ecoActivities").doc(activityId);
  const userDocRef = db.collection("users").doc(userId);
  const completionDocRef = userDocRef.collection("completedActivities").doc(completionDocId);

  // Pre-fetch active challenges and achievements
  const [activeChallengesSnap, activeAchievementsSnap, userCompletionsSnap] = await Promise.all([
    db.collection("challenges").where("isActive", "==", true).get(),
    db.collection("achievements").where("isActive", "==", true).get(),
    userDocRef.collection("completedActivities").get(),
  ]);

  return db.runTransaction(async (transaction) => {
    // 2. Verify activity exists and is active
    const activitySnap = await transaction.get(activityDocRef);
    if (!activitySnap.exists) {
      throw new functions.https.HttpsError("not-found", "Activity not found.");
    }

    const activityData = activitySnap.data();
    if (!activityData.isActive) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "This activity is not currently active."
      );
    }

    // 3. Verify duplicate completion rules (limit 1 per day)
    const completionSnap = await transaction.get(completionDocRef);
    if (completionSnap.exists) {
      return {
        success: false,
        alreadyCompleted: true,
        message: "You have already completed this activity today.",
      };
    }

    // 4. Read user points and calculate base points
    const userSnap = await transaction.get(userDocRef);
    const currentPoints = (userSnap.data() && userSnap.data().ecoPoints) || 0;
    const basePointsAwarded = Number(activityData.points) || 0;
    let totalBonusPoints = 0;
    let newlyCompletedChallenges = 0;

    // 5. Create completion record
    transaction.set(completionDocRef, {
      id: completionDocId,
      activityId: activityId,
      userId: userId,
      activityTitle: activityData.title || "",
      category: activityData.category || "General",
      pointsAwarded: basePointsAwarded,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      completionDate: dateKey,
    });

    // 6. Advance ongoing challenges
    for (const challengeDoc of activeChallengesSnap.docs) {
      const cData = challengeDoc.data();
      const challengeId = challengeDoc.id;
      const type = cData.type || "activity_count";
      const target = Number(cData.target) || 1;
      const targetCategory = cData.targetCategory;
      const rewardPoints = Number(cData.rewardPoints) || 0;

      let isMatching = false;
      if (type === "activity_count") {
        isMatching = true;
      } else if (type === "category_activity") {
        isMatching = !targetCategory || (activityData.category && activityData.category.toLowerCase() === targetCategory.toLowerCase());
      }

      if (!isMatching) continue;

      const progressDocRef = userDocRef.collection("challengeProgress").doc(challengeId);
      const progressSnap = await transaction.get(progressDocRef);

      const currentProgress = (progressSnap.data() && progressSnap.data().progress) || 0;
      const isAlreadyClaimed = (progressSnap.data() && progressSnap.data().rewardClaimed) || false;

      const newProgress = currentProgress + 1;
      const isTargetReached = newProgress >= target;

      if (isTargetReached && !isAlreadyClaimed) {
        totalBonusPoints += rewardPoints;
        newlyCompletedChallenges++;
        transaction.set(progressDocRef, {
          challengeId: challengeId,
          userId: userId,
          progress: newProgress,
          target: target,
          status: "completed",
          startedAt: progressSnap.exists ? progressSnap.data().startedAt : admin.firestore.FieldValue.serverTimestamp(),
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
          rewardClaimed: true,
        }, { merge: true });
      } else if (!isAlreadyClaimed) {
        transaction.set(progressDocRef, {
          challengeId: challengeId,
          userId: userId,
          progress: newProgress,
          target: target,
          status: "in_progress",
          startedAt: progressSnap.exists ? progressSnap.data().startedAt : admin.firestore.FieldValue.serverTimestamp(),
          rewardClaimed: false,
        }, { merge: true });
      }
    }

    const finalAwardedPoints = basePointsAwarded + totalBonusPoints;
    const newTotalPoints = currentPoints + finalAwardedPoints;
    const newLevel = Math.floor(newTotalPoints / 100) + 1;

    // 7. Update user profile
    transaction.update(userDocRef, {
      ecoPoints: newTotalPoints,
      level: newLevel,
    });

    // 8. Evaluate eligible achievements
    const totalCompletions = userCompletionsSnap.docs.length + 1;
    for (const achDoc of activeAchievementsSnap.docs) {
      const aData = achDoc.data();
      const achievementId = achDoc.id;
      const reqType = aData.requirementType || "activity_count";
      const reqVal = Number(aData.requirementValue) || 1;

      const userAchDocRef = userDocRef.collection("achievements").doc(achievementId);
      const userAchSnap = await transaction.get(userAchDocRef);

      if (!userAchSnap.exists) {
        let isEligible = false;
        if (reqType === "first_activity") {
          isEligible = totalCompletions >= 1;
        } else if (reqType === "activity_count") {
          isEligible = totalCompletions >= reqVal;
        } else if (reqType === "points_reached") {
          isEligible = newTotalPoints >= reqVal;
        } else if (reqType === "challenges_completed") {
          isEligible = newlyCompletedChallenges >= reqVal;
        }

        if (isEligible) {
          transaction.set(userAchDocRef, {
            achievementId: achievementId,
            userId: userId,
            unlockedAt: admin.firestore.FieldValue.serverTimestamp(),
            status: "unlocked",
            rewardPointsAwarded: 0,
          });
        }
      }
    }

    return {
      success: true,
      alreadyCompleted: false,
      pointsAwarded: finalAwardedPoints,
      newTotalPoints: newTotalPoints,
      newLevel: newLevel,
    };
  });
});
