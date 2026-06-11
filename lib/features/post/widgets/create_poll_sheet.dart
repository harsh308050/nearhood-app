import 'package:nearhood/core/utils/custom_import.dart';

class CreatePollSheet extends StatefulWidget {
  const CreatePollSheet({super.key});

  @override
  State<CreatePollSheet> createState() => _CreatePollSheetState();
}

class _CreatePollSheetState extends State<CreatePollSheet> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  final List<FocusNode> _focusNodes = [FocusNode(), FocusNode()];

  bool _isCreateEnabled = false;
  bool _showVoters = true; // Toggle for showing who voted

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_validateInputs);
    for (var controller in _optionControllers) {
      controller.addListener(_validateInputs);
    }
    _setupLastFocusNodeListener();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _setupLastFocusNodeListener() {
    // Listen to the last focus node. If it gets focus, add a new field.
    if (_focusNodes.isNotEmpty) {
      _focusNodes.last.addListener(_onLastFieldFocused);
    }
  }

  void _onLastFieldFocused() {
    if (_focusNodes.last.hasFocus && _optionControllers.length < 10) {
      _addOptionField();
    }
  }

  void _addOptionField() {
    if (_optionControllers.length >= 10) return;

    // Remove listener from current last node
    _focusNodes.last.removeListener(_onLastFieldFocused);

    setState(() {
      final newController = TextEditingController();
      final newNode = FocusNode();
      newController.addListener(_validateInputs);
      _optionControllers.add(newController);
      _focusNodes.add(newNode);
    });

    // Setup listener on the new last node
    _setupLastFocusNodeListener();
  }

  void _removeOptionField(int index) {
    if (_optionControllers.length <= 2) return;

    // Remove listener from the old last node
    _focusNodes.last.removeListener(_onLastFieldFocused);

    setState(() {
      final controller = _optionControllers.removeAt(index);
      final node = _focusNodes.removeAt(index);
      controller.dispose();
      node.dispose();
    });

    _setupLastFocusNodeListener();
    _validateInputs();
  }

  void _validateInputs() {
    final question = _questionController.text.trim();
    final nonUniqueFilledOptions = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    // Must have a question and at least 2 non-empty options
    final hasEnoughOptions = nonUniqueFilledOptions.length >= 2;
    // Options must be unique to prevent confusion
    final isUnique =
        nonUniqueFilledOptions.toSet().length == nonUniqueFilledOptions.length;

    setState(() {
      _isCreateEnabled = question.isNotEmpty && hasEnoughOptions && isUnique;
    });
  }

  void _submit() {
    if (!_isCreateEnabled) return;

    final question = _questionController.text.trim();
    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    Navigator.pop(context, {
      'question': question,
      'options': options,
      'showVoters': _showVoters,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 20.h + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              height: 4.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          sh(16),
          CustomText(
            AppStrings.createPoll,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          sh(16),

          // Question Input
          CustomText(
            AppStrings.question,
            style: AppTypography.caption.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          sh(6),
          CustomTextField(
            controller: _questionController,
            hint: AppStrings.askQuestionPlaceholder,
          ),
          sh(16),

          // Options Input List
          CustomText(
            AppStrings.options,
            style: AppTypography.caption.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          sh(6),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(_optionControllers.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _optionControllers[index],
                            focusNode: _focusNodes[index],
                            hint: 'Option ${index + 1}',
                          ),
                        ),
                        if (_optionControllers.length > 2) ...[
                          sw(6),
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.red.withOpacity(0.8),
                              size: 22.r,
                            ),
                            onPressed: () => _removeOptionField(index),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          sh(16),

          // Show Voters Toggle
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: AppColors.primaryBlue,
                  size: 20.r,
                ),
                sw(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        AppStrings.showWhoVoted,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      sh(2),
                      CustomText(
                        AppStrings.letVotersSeeDetails,
                        style: AppTypography.caption.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                sw(8),
                Switch.adaptive(
                  value: _showVoters,
                  onChanged: (value) {
                    setState(() {
                      _showVoters = value;
                    });
                  },
                  activeColor: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
          sh(16),

          // Create button
          CustomButton.filled(
            text: AppStrings.createPoll,
            onPressed: _isCreateEnabled ? _submit : null,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
