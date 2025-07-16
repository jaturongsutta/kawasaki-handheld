import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Dialog(
  //     backgroundColor: Colors.transparent,
  //     child: Center(
  //       child: SizedBox(
  //         width: 80,
  //         height: 80,
  //         child: LoadingIndicator(
  //           indicatorType: Indicator.ballSpinFadeLoader,
  //           colors: [Theme.of(context).primaryColor],
  //           strokeWidth: 2,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: LoadingIndicator(
            indicatorType: Indicator.ballRotateChase,
            colors: [Theme.of(context).primaryColor],
            backgroundColor: Colors.transparent,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
