const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function to securely complete an eco activity and award eco points atomically.
 * Callable via Firebase Functions SDK.
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

    // 4. Read user points and calculate new level
    const userSnap = await transaction.get(userDocRef);
    const currentPoints = (userSnap.data() && userSnap.data().ecoPoints) || 0;
    const pointsAwarded = Number(activityData.points) || 0;
    const newTotalPoints = currentPoints + pointsAwarded;
    const newLevel = Math.floor(newTotalPoints / 100) + 1;

    // 5. Create completion record
    transaction.set(completionDocRef, {
      id: completionDocId,
      activityId: activityId,
      userId: userId,
      activityTitle: activityData.title || "",
      category: activityData.category || "General",
      pointsAwarded: pointsAwarded,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      completionDate: dateKey,
    });

    // 6. Update user profile
    transaction.update(userDocRef, {
      ecoPoints: newTotalPoints,
      level: newLevel,
    });

    return {
      success: true,
      alreadyCompleted: false,
      pointsAwarded: pointsAwarded,
      newTotalPoints: newTotalPoints,
      newLevel: newLevel,
    };
  });
});
