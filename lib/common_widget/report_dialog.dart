import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/report/services/report_api_service.dart';

enum ReportTargetType { post, comment, message, user }

class ReportDialog extends StatefulWidget {
  final ReportTargetType targetType;
  final String targetId;
  final String? parentPostId;
  final String? parentConversationId;

  /// When provided, an extra "Report & Delete" button is shown (for post author reporting a comment).
  final VoidCallback? onReportAndDelete;

  const ReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
    this.parentPostId,
    this.parentConversationId,
    this.onReportAndDelete,
  });

  /// Convenience method to show the report dialog.
  static Future<void> show(
    BuildContext context, {
    required ReportTargetType targetType,
    required String targetId,
    String? parentPostId,
    String? parentConversationId,
    VoidCallback? onReportAndDelete,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ReportDialog(
        targetType: targetType,
        targetId: targetId,
        parentPostId: parentPostId,
        parentConversationId: parentConversationId,
        onReportAndDelete: onReportAndDelete,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  bool _isSubmitting = false;

  static const _reasons = [
    AppStrings.reportReasonSpam,
    AppStrings.reportReasonHarassment,
    AppStrings.reportReasonViolence,
    AppStrings.reportReasonFalseInfo,
    AppStrings.reportReasonInappropriate,
    AppStrings.reportReasonOther,
  ];

  String get _title {
    switch (widget.targetType) {
      case ReportTargetType.post:
        return AppStrings.reportPost;
      case ReportTargetType.comment:
        return AppStrings.reportComment;
      case ReportTargetType.message:
        return AppStrings.reportMessage;
      case ReportTargetType.user:
        return AppStrings.reportUser;
    }
  }

  String get _subtitle {
    switch (widget.targetType) {
      case ReportTargetType.post:
        return AppStrings.whyReportingPost;
      case ReportTargetType.comment:
        return AppStrings.whyReportingComment;
      case ReportTargetType.message:
        return AppStrings.whyReportingMessage;
      case ReportTargetType.user:
        return AppStrings.whyReportingUser;
    }
  }

  String get _successMessage {
    switch (widget.targetType) {
      case ReportTargetType.post:
        return AppStrings.postReportedMessage;
      case ReportTargetType.comment:
        return AppStrings.commentReportedMessage;
      case ReportTargetType.message:
        return AppStrings.messageReportedMessage;
      case ReportTargetType.user:
        return AppStrings.userReportedMessage;
    }
  }

  String get _reportAndActionLabel {
    switch (widget.targetType) {
      case ReportTargetType.user:
        return AppStrings.chatReportAndBlock;
      default:
        return AppStrings.chatReportAndDelete;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showReportAndDelete = widget.onReportAndDelete != null;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: AppColors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              _title,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 18.sp,
                color: AppColors.darkGrey,
              ),
            ),
            sh(8),
            CustomText(
              _subtitle,
              style: AppTypography.bodyText.copyWith(
                fontSize: 14.sp,
                color: AppColors.grey,
              ),
            ),
            sh(16),
            ..._reasons.map(
              (reason) => RadioListTile<String>(
                title: CustomText(
                  reason,
                  style: AppTypography.bodyText.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() => _selectedReason = value);
                },
                activeColor: AppColors.primaryBlue,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            sh(8),
            if (showReportAndDelete) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedReason == null || _isSubmitting)
                      ? null
                      : _submitReportAndDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    disabledBackgroundColor: AppColors.red.withValues(
                      alpha: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : CustomText(
                          _reportAndActionLabel,
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                ),
              ),
              sh(8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                  child: CustomText(
                    AppStrings.cancel,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                sw(8),
                TextButton(
                  onPressed: (_selectedReason == null || _isSubmitting)
                      ? null
                      : _submitReport,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : CustomText(
                          AppStrings.report,
                          style: AppTypography.cardTitle.copyWith(
                            color: _selectedReason == null
                                ? AppColors.grey
                                : AppColors.red,
                            fontSize: 14.sp,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    try {
      final apiService = ReportApiService();
      await apiService.report(
        targetType: widget.targetType.name,
        targetId: widget.targetId,
        reason: _selectedReason!,
        parentPostId: widget.parentPostId,
        parentConversationId: widget.parentConversationId,
      );

      if (!mounted) return;
      Navigator.pop(context);
      AppSnackBar.showMessage(
        context,
        _successMessage,
        borderColor: AppColors.green,
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message == AppStrings.alreadyReported) {
        Navigator.pop(context);
        AppSnackBar.showMessage(
          context,
          AppStrings.alreadyReported,
          borderColor: AppColors.orange,
        );
      } else {
        setState(() => _isSubmitting = false);
        AppSnackBar.showMessage(
          context,
          message.isNotEmpty ? message : AppStrings.reportFailed,
          borderColor: AppColors.red,
        );
      }
    }
  }

  Future<void> _submitReportAndDelete() async {
    if (_selectedReason == null || widget.onReportAndDelete == null) return;

    setState(() => _isSubmitting = true);

    try {
      final apiService = ReportApiService();
      await apiService.report(
        targetType: widget.targetType.name,
        targetId: widget.targetId,
        reason: _selectedReason!,
        parentPostId: widget.parentPostId,
        parentConversationId: widget.parentConversationId,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onReportAndDelete!();
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message == AppStrings.alreadyReported) {
        Navigator.pop(context);
        AppSnackBar.showMessage(
          context,
          AppStrings.alreadyReported,
          borderColor: AppColors.orange,
        );
      } else {
        setState(() => _isSubmitting = false);
        AppSnackBar.showMessage(
          context,
          message.isNotEmpty ? message : AppStrings.reportFailed,
          borderColor: AppColors.red,
        );
      }
    }
  }
}
