import 'package:flutter/material.dart';
import 'package:nearhood/core/services/fcm_service.dart';
import 'package:nearhood/core/utils/cm.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/theme/app_typography.dart';
import 'package:nearhood/common_widget/custom_text.dart';
import 'package:nearhood/common_widget/common_appbar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final FCMService _fcmService = FCMService();

  bool _isLoading = true;
  bool _notificationsEnabled = true;
  String _notificationType = 'all_posts'; // 'all_posts' or 'safety_only'
  Map<String, bool> _categorySettings = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await _fcmService.getNotificationPreferences();
      if (prefs != null) {
        final preferences = prefs['preferences'] as Map<String, dynamic>?;
        if (preferences != null) {
          setState(() {
            _notificationsEnabled = preferences['enabled'] as bool? ?? true;
            _notificationType = preferences['type'] as String? ?? 'all_posts';
            _categorySettings = Map<String, bool>.from(
              preferences['categories'] as Map<String, dynamic>? ?? {},
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load preferences')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePreferences() async {
    try {
      final success = await _fcmService.updateNotificationPreferences(
        type: _notificationType,
        enabled: _notificationsEnabled,
        categories: _categorySettings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Preferences saved successfully'
                  : 'Failed to save preferences',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update preferences'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    final success = await _fcmService.sendTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Test notification sent! Check your notification panel'
                : 'Failed to send test notification',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Notifications'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Master Toggle
                _buildSection(
                  title: 'Push Notifications',
                  child: SwitchListTile(
                    title: CustomText(
                      'Enable Notifications',
                      style: AppTypography.bodyText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: CustomText(
                      'Receive push notifications from Nearhood',
                      style: AppTypography.caption.copyWith(fontSize: 13.sp),
                    ),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      _updatePreferences();
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                ),

                sh(24),

                // Notification Type
                _buildSection(
                  title: 'Notification Type',
                  subtitle: 'Choose what notifications you want to receive',
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: CustomText(
                          'All Posts in My Area',
                          style: AppTypography.bodyText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: CustomText(
                          'Get notified about all posts created in your locality',
                          style: AppTypography.caption.copyWith(
                            fontSize: 13.sp,
                          ),
                        ),
                        value: 'all_posts',
                        groupValue: _notificationType,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                if (value != null) {
                                  setState(() => _notificationType = value);
                                  _updatePreferences();
                                }
                              }
                            : null,
                        activeColor: AppColors.primaryBlue,
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        title: CustomText(
                          'Safety Alerts Only',
                          style: AppTypography.bodyText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: CustomText(
                          'Only receive critical safety alerts from your area, nearby areas, and city',
                          style: AppTypography.caption.copyWith(
                            fontSize: 13.sp,
                          ),
                        ),
                        value: 'safety_only',
                        groupValue: _notificationType,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                if (value != null) {
                                  setState(() => _notificationType = value);
                                  _updatePreferences();
                                }
                              }
                            : null,
                        activeColor: AppColors.red,
                      ),
                    ],
                  ),
                ),

                sh(24),

                // Test Notification
                _buildSection(
                  title: 'Test',
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primaryBlue,
                      size: 24.r,
                    ),
                    title: CustomText(
                      'Send Test Notification',
                      style: AppTypography.bodyText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: CustomText(
                      'Verify that notifications are working',
                      style: AppTypography.caption.copyWith(fontSize: 13.sp),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.grey,
                    ),
                    onTap: _sendTestNotification,
                  ),
                ),

                sh(24),

                // Info Card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primaryBlue,
                        size: 20.r,
                      ),
                      sw(12),
                      Expanded(
                        child: CustomText(
                          'You can change these settings anytime. Safety alerts are always prioritized to keep your neighborhood safe.',
                          style: AppTypography.caption.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                sh(4),
                CustomText(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: child,
        ),
      ],
    );
  }
}
