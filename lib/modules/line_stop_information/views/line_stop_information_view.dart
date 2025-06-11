import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/line_stop_information_controller.dart';

class LineStopInformationView extends GetView<LineStopInformationController> {
  const LineStopInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Line Stop Information')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: ListView(
            children: [
              _buildField('Line', controller.line.value, readOnly: true),
              const SizedBox(height: 8),
              _buildDropdown('Machine', controller.machineOptions, controller.selectedMachine),
              const SizedBox(height: 8),
              _buildDatePicker('Stop Date', controller.stopDate),
              const SizedBox(height: 8),
              _buildField('Stop Time', controller.stopTimeController.text),
              const SizedBox(height: 8),
              _buildField('Lost Time', controller.lostTimeController.text,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              _buildDropdown('Reason', controller.reasonOptions, controller.selectedReason),
              const SizedBox(height: 8),
              _buildMultilineField('Comment', controller.commentController.text),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: controller.saveStop,
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: Get.back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 196, 196, 196),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Back'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value,
      {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: value,
              readOnly: readOnly,
              keyboardType: keyboardType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMultilineField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
        Expanded(
          child: TextFormField(
            initialValue: value,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, RxString selectedValue) {
    return Obx(
      () => SizedBox(
        height: 45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedValue.value,
                items:
                    items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) {
                  if (value != null) selectedValue.value = value;
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, Rx<DateTime> selectedDate) {
    return Obx(
      () => SizedBox(
        height: 45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) selectedDate.value = picked;
                },
                child: InputDecorator(
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  child: Text(
                    '${selectedDate.value.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.value.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.value.year}',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
