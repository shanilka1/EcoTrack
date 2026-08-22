import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_helper.dart';

/// Reusable Search Bar with integrated Filter Trigger and Active Filter Badges
class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterTap;
  final int activeFilterCount;
  final List<Widget>? activeFilterChips;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    this.hintText = 'Search...',
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterTap,
    this.activeFilterCount = 0,
    this.activeFilterChips,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Search Input Field
            Expanded(
              child: Container(
                height: isSmall ? 44 : 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.cardLight,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: isSmall ? 13 : 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                            ),
                            onPressed: onClearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Filter Button with Active Count Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: isSmall ? 44 : 48,
                  width: isSmall ? 44 : 48,
                  decoration: BoxDecoration(
                    color: activeFilterCount > 0
                        ? AppColors.primary.withAlpha(isDark ? 50 : 30)
                        : (isDark ? AppColors.cardDark : AppColors.cardLight),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: activeFilterCount > 0
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      width: activeFilterCount > 0 ? 1.5 : 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: activeFilterCount > 0
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                    tooltip: 'Filter options',
                    onPressed: onFilterTap,
                  ),
                ),
                if (activeFilterCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$activeFilterCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Active Filter Chips Horizontal Bar (if any)
        if (activeFilterChips != null && activeFilterChips!.isNotEmpty) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: activeFilterChips!,
            ),
          ),
        ],
      ],
    );
  }
}
