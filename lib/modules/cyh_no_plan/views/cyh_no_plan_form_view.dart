import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kmt/widgets/timeformat.dart';
import '../controllers/cyh_no_plan_controller.dart';

class CYHNoPlanFormView extends GetView<CYHNoPlanController> {
  const CYHNoPlanFormView({super.key});

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    controller.initFormFromArgs();

    final theme = Theme.of(context);

    Widget fieldLabel(String txt) => SizedBox(
          width: 95,
          child: Text(
            txt,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF3D7BFF),
              fontWeight: FontWeight.w600,
            ),
          ),
        );

    InputDecoration deco({Widget? suffix}) => InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: suffix,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('No Plan'),
        backgroundColor: const Color(0xFF3D7BFF),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF4F5FB),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: controller.confirmForm,
              child: const Text('Confirm'),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Obx(() {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Machine (read-only)
                  _buildInfoRow('Machine', controller.selectedMachineNo.value ?? ''),
                  const SizedBox(height: 12),
                  // Start Date
                  _buildDatePicker('Start Date', controller.startDate, isRequired: true),
                  const SizedBox(height: 12),
                  // Start Time
                  _buildTextFormField(
                    'Stop Time',
                    controller.startTimeController,
                    isRequired: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      TimeTextInputFormatter(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // End Date
                  _buildDatePicker('End Date', controller.endDate, isRequired: true),
                  const SizedBox(height: 12),
                  // End Time
                  _buildTextFormField(
                    'End Time',
                    controller.endTimeController,
                    isRequired: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      TimeTextInputFormatter(),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, Rx<DateTime?> selectedDate, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FormField<DateTime>(
        validator: isRequired
            ? (_) {
                if (selectedDate.value == null) {
                  return 'กรุณาเลือก $label';
                }
                return null;
              }
            : null,
        builder: (formFieldState) {
          return Obx(() {
            final dateText = selectedDate.value != null
                ? DateFormat('dd/MM/yy').format(selectedDate.value!)
                : '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(label,
                          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: Get.context!,
                            initialDate: selectedDate.value ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            selectedDate.value = picked;
                            formFieldState.didChange(picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xF2EAF1FC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: formFieldState.hasError ? Colors.red : Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateText.isNotEmpty ? dateText : 'เลือกวันที่',
                                style: TextStyle(
                                  color: dateText.isNotEmpty ? Colors.black : Colors.grey,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (formFieldState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 100, top: 4),
                    child: Text(
                      formFieldState.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Color(0xFF6CC24A), width: 2), // เขียวโทนหลัก
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              ),
              validator: isRequired
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอก $label';
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
