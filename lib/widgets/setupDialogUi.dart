import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kmt/enum/dialog_type.dart';
import 'package:kmt/services/inject.dart';
import 'package:kmt/util/ChannelManager.dart';
import 'package:kmt/util/constants.dart';
import 'package:kmt/widgets/dialogController.dart';
import 'package:stacked_services/stacked_services.dart';

void setupDialogUi() {
  final dialogService = getIt<DialogService>();

  final builders = {
    DialogType.basic: (context, sheetRequest, completer) =>
        _BasicDialog(request: sheetRequest, completer: completer),
    DialogType.form: (context, sheetRequest, completer) =>
        _FormDialog(request: sheetRequest, completer: completer),
    DialogType.avatar: (context, sheetRequest, completer) =>
        CustomDialogBox(request: sheetRequest, completer: completer),
    DialogType.icon: (context, sheetRequest, completer) =>
        IconDialogBox(request: sheetRequest, completer: completer),
    DialogType.confirm: (context, sheetRequest, completer) =>
        ConfirmBox(request: sheetRequest, completer: completer),
    DialogType.multiButton: (context, sheetRequest, completer) =>
        MultiButtonDialogBox(request: sheetRequest, completer: completer),
    DialogType.twoButton: (context, sheetRequest, completer) =>
        TwoButtonDialogBox(request: sheetRequest, completer: completer),
    DialogType.multiLine: (context, sheetRequest, completer) =>
        MultiLineDialogBox(request: sheetRequest, completer: completer),
    DialogType.customTwoButton: (context, sheetRequest, completer) =>
        CustomTwoButtonDialogBox(request: sheetRequest, completer: completer),
    DialogType.oneButton: (context, sheetRequest, completer) =>
        OneButtonDialogBox(request: sheetRequest, completer: completer),
    DialogType.customConfirm: (context, sheetRequest, completer) =>
        CustomConfirmDialogBox(request: sheetRequest, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}

class _BasicDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;
  const _BasicDialog({Key? key, required this.request, required this.completer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Dialog(child: Icon(Icons.ac_unit_outlined));
  }
}

class _FormDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;
  const _FormDialog({Key? key, required this.request, required this.completer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Dialog(child: Icon(Icons.ac_unit_outlined));
  }
}

class CustomDialogBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const CustomDialogBox({super.key, required this.request, required this.completer});

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: const EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.request.title ?? "",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.request.description ?? "",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    widget.completer(DialogResponse(confirmed: true));
                  },
                  child: Text(
                    widget.request.mainButtonTitle ?? "ok",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.network(
                    "https://www.bridgestone.co.th/content/dam/bridgestone/consumer/bst/logos/logo-bridgestone-social.png")),
          ),
        ),
      ],
    );
  }
}

class IconDialogBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const IconDialogBox({super.key, required this.request, required this.completer});

  @override
  _IconDialogBoxState createState() => _IconDialogBoxState();
}

class _IconDialogBoxState extends State<IconDialogBox> {
  late Timer _timer;
  int? counter;
  Widget? icon;

  @override
  void initState() {
    super.initState();
    counter = widget.request.data?['counter'] ?? 3;
    icon = widget.request.data?['icons'];
  }

  @override
  Widget build(BuildContext context) {
    _timer = Timer(Duration(seconds: counter ?? 3), () {
      Navigator.of(context).pop();
    });
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      // height: 228,
      // margin: const EdgeInsets.symmetric(vertical: 10),
      width: 228,
      // padding: const EdgeInsets.only(left: Constants.padding, top: Constants.avatarRadius + Constants.padding, right: Constants.padding, bottom: Constants.padding),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.padding),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 22,
          ),
          if (widget.request.title != null) ...[
            Text(
              widget.request.title ?? "",
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 15,
            ),
          ],
          widget.request.data['icon'] ?? Container(),
          // SvgPicture.asset(
          //   widget.request.imageUrl ?? "",
          //   height: 52,
          //   width: 52,
          // ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.request.description ?? "",
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 22,
          ),
        ],
      ),
    );
  }
}

class ConfirmBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ConfirmBox({super.key, required this.request, required this.completer});

  @override
  _ConfirmBoxState createState() => _ConfirmBoxState();
}

class _ConfirmBoxState extends State<ConfirmBox> {
  // late Timer _timer;
  Color? color;
  Color? colorButtonConfirm;
  Color? colorButtonCancel;
  Color? textColor;
  bool? showIcon;
  TextStyle? titleTextStyle;
  TextStyle? descTextStyle;

  final DialogController dialogController = Get.put(DialogController());

  @override
  void initState() {
    super.initState();
    color = widget.request.data?['color'] ?? const Color(0xFF1A1A1A);
    colorButtonConfirm = widget.request.data?['colorButtonConfirm'] ?? const Color(0xFF5cb85b);
    colorButtonCancel = widget.request.data?['colorButtonCancel'] ?? const Color(0xFFC5C5C5);
    textColor = widget.request.data?['textColor'] ?? const Color(0xFF1A1A1A);
    showIcon = widget.request.data?['showIcon'] ?? true;
    titleTextStyle = widget.request.data?['titleTextStyle'] ??
        GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: color,
        );
    descTextStyle = widget.request.data?['descTextStyle'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        );

    EnterKeyChannelManager.setupMethodChannel((call) {
      if (call.method == 'enterKeyPressed') {
        widget.completer(DialogResponse(confirmed: true));
      } else {
        print('bbbbbbbb');
      }
      return Future.value();
    });
  }

  @override
  void dispose() {
    // EnterKeyChannelManager.disposeMethodChannel();
    super.dispose();
  }
  // void initializeState() {
  //   const MethodChannel('EnterkeyChannel').setMethodCallHandler((call) async {
  //     switch (call.method) {
  //       case 'enterKeyPressed':
  //         widget.completer(DialogResponse(confirmed: true));
  //         break;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // _timer = Timer(const Duration(seconds: 3), () {
    //   Navigator.of(context).pop();
    // });
    dialogController.isDialogOpen.value = true;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      height: 274,
      width: 228,
      // padding: const EdgeInsets.only(left: Constants.padding, top: Constants.avatarRadius + Constants.padding, right: Constants.padding, bottom: Constants.padding),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.padding),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (widget.request.title != null) ...[
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.request.title ?? "",
              style: titleTextStyle,
              textAlign: TextAlign.center,
            ),
            const Divider(
              height: 20,
              thickness: 1,
              color: Color(0xFFC5C5C5),
            ),
            const SizedBox(
              height: 0,
            ),
          ],
          Visibility(
            visible: showIcon ?? true,
            child: SvgPicture.asset(
              widget.request.imageUrl ?? "",
              height: 52,
              width: 52,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.request.description ?? "",
            style: descTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () {
                    widget.completer(DialogResponse(confirmed: true));
                  },
                  child: Container(
                    width: 90,
                    // height: 50,
                    decoration: BoxDecoration(
                      color: colorButtonConfirm,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        widget.request.mainButtonTitle ?? '',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () {
                    dialogController.isDialogOpen.value = false;
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 90,
                    // height: 50,
                    decoration: BoxDecoration(
                      color: colorButtonCancel,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        widget.request.secondaryButtonTitle ?? '',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 43, 43, 43),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

class MultiButtonDialogBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const MultiButtonDialogBox({super.key, required this.request, required this.completer});

  @override
  _MultiButtonDialogBoxState createState() => _MultiButtonDialogBoxState();
}

class _MultiButtonDialogBoxState extends State<MultiButtonDialogBox> {
  // late Timer _timer;
  Color? color;
  Color? colorfirstButton;
  Color? colorsecButton;
  Color? colorthButton;
  Color? textColor;
  bool? showIcon;
  Function? functionHold;
  Function? functionReject;
  Function? functionScrap;
  String? firstButtonLabel;
  String? secButtonLabel;
  String? thButtonLabel;
  TextStyle? descTextStyle;

  final DialogController dialogController = Get.put(DialogController());

  @override
  void initState() {
    super.initState();
    color = widget.request.data?['color'] ?? const Color(0xFF1A1A1A);
    colorfirstButton = widget.request.data?['colorfirstButton'] ?? const Color(0xFFC5C5C5);
    colorsecButton = widget.request.data?['colorsecButton'] ?? const Color(0xFFC5C5C5);
    colorthButton = widget.request.data?['colorthButton'] ?? const Color(0xFFC5C5C5);
    functionHold = widget.request.data?['functionHold'];
    functionReject = widget.request.data?['functionReject'];
    functionScrap = widget.request.data?['functionScrap'];
    firstButtonLabel = widget.request.data?['firstButtonLabel'];
    secButtonLabel = widget.request.data?['secButtonLabel'];
    thButtonLabel = widget.request.data?['thButtonLabel'];
    textColor = widget.request.data?['textColor'] ?? const Color(0xFF1A1A1A);
    showIcon = widget.request.data?['showIcon'] ?? true;
    descTextStyle = widget.request.data?['descTextStyle'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        );

    EnterKeyChannelManager.setupMethodChannel((call) {
      if (call.method == 'enterKeyPressed') {
        widget.completer(DialogResponse(confirmed: true));
      } else {
        print('bbbbbbbb');
      }
      return Future.value();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dialogController.isDialogOpen.value = true;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      height: 274,
      width: 228,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.padding),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (widget.request.title != null) ...[
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.request.title ?? "",
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                // color: const Color(0xFF1A1A1A),
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(
              height: 20,
              thickness: 1,
              color: Color(0xFFC5C5C5),
            ),
            const SizedBox(
              height: 0,
            ),
          ],
          Visibility(
            visible: showIcon ?? true,
            child: SvgPicture.asset(
              widget.request.imageUrl ?? "",
              height: 52,
              width: 52,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.request.description ?? "",
            style: descTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () async {
                    if (functionHold != null) {
                      await functionHold!();
                    }
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: colorfirstButton,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 5),
                            blurRadius: 10),
                      ],
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        firstButtonLabel ?? '',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 43, 43, 43),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () async {
                    if (functionReject != null) {
                      await functionReject!();
                    }
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: colorsecButton,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 5),
                            blurRadius: 10),
                      ],
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        secButtonLabel ?? '',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 43, 43, 43),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: InkWell(
              onTap: () async {
                if (functionScrap != null) {
                  await functionScrap!();
                }
              },
              child: Container(
                width: 90,
                decoration: BoxDecoration(
                  color: colorthButton,
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 5),
                        blurRadius: 10),
                  ],
                ),
                padding: const EdgeInsets.all(6.0),
                child: Center(
                  child: Text(
                    thButtonLabel ?? '',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 43, 43, 43),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

class TwoButtonDialogBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const TwoButtonDialogBox({super.key, required this.request, required this.completer});

  @override
  _TwoButtonDialogBoxState createState() => _TwoButtonDialogBoxState();
}

class _TwoButtonDialogBoxState extends State<TwoButtonDialogBox> {
  // late Timer _timer;
  Color? color;
  Color? colorfirstButton;
  Color? colorsecButton;
  Color? colorthButton;
  Color? textColor;
  bool? showIcon;
  Function? functionHold;
  Function? functionReject;
  Function? functionScrap;
  void Function(RawKeyEvent)? enterHandleFunction;
  String? firstButtonLabel;
  String? secButtonLabel;
  String? thButtonLabel;
  TextStyle? descTextStyle;
  ValueNotifier<bool> isShowDialog = ValueNotifier(true);

  final FocusNode _focusNode = FocusNode();
  final DialogController dialogController = Get.put(DialogController());

  @override
  void initState() {
    super.initState();
    color = widget.request.data?['color'] ?? const Color(0xFF1A1A1A);
    colorfirstButton = widget.request.data?['colorfirstButton'] ?? const Color(0xFFC5C5C5);
    colorsecButton = widget.request.data?['colorsecButton'] ?? const Color(0xFFC5C5C5);
    colorthButton = widget.request.data?['colorthButton'] ?? const Color(0xFFC5C5C5);
    functionHold = widget.request.data?['functionHold'];
    functionReject = widget.request.data?['functionReject'];
    functionScrap = widget.request.data?['functionScrap'];
    enterHandleFunction =
        widget.request.data?['enterHandleFunction'] as void Function(RawKeyEvent)?;
    firstButtonLabel = widget.request.data?['firstButtonLabel'];
    secButtonLabel = widget.request.data?['secButtonLabel'];
    thButtonLabel = widget.request.data?['thButtonLabel'];
    textColor = widget.request.data?['textColor'] ?? const Color(0xFF1A1A1A);
    showIcon = widget.request.data?['showIcon'] ?? true;
    isShowDialog = widget.request.data?['isShowDialog'] ?? ValueNotifier(true);
    descTextStyle = widget.request.data?['descTextStyle'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        );
    _focusNode.requestFocus();

    // EnterKeyChannelManager.setupMethodChannel((call) {
    //   if (call.method == 'enterKeyPressed') {
    //     widget.completer(DialogResponse(confirmed: true));
    //   } else {
    //     print('bbbbbbbb');
    //   }
    //   return Future.value();
    // });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dialogController.isDialogOpen.value = true;
    return ValueListenableBuilder(
      valueListenable: isShowDialog,
      builder: (context, value, child) {
        if (value) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(context),
          );
        } else {
          return Container();
        }
      },
    );
  }

  contentBox(context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: enterHandleFunction,
      child: Container(
        height: 184,
        width: 228,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (widget.request.title != null) ...[
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.request.title ?? "",
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  // color: const Color(0xFF1A1A1A),
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Color(0xFFC5C5C5),
              ),
              const SizedBox(
                height: 0,
              ),
            ],
            Text(
              widget.request.description ?? "",
              style: descTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: () async {
                      if (functionHold != null) {
                        await functionHold!();
                      }
                    },
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: colorfirstButton,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 5),
                              blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: Center(
                        child: Text(
                          firstButtonLabel ?? '',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 43, 43, 43),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: () async {
                      if (functionReject != null) {
                        await functionReject!();
                      }
                    },
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: colorsecButton,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 5),
                              blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: Center(
                        child: Text(
                          secButtonLabel ?? '',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 43, 43, 43),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class MultiLineDialogBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;
  final DialogController dialogController = Get.put(DialogController());

  MultiLineDialogBox({super.key, required this.request, required this.completer});

  @override
  State<MultiLineDialogBox> createState() => _MultiLineDialogBoxState();
}

class _MultiLineDialogBoxState extends State<MultiLineDialogBox> {
  Color? color;
  Color? colorConfirmButton;
  Color? colorCancelButton;
  TextStyle? textDes1Color;
  TextStyle? textDes2Color;
  String? header;
  String? des1;
  String? des2;
  bool? showIcon;
  Function? functionConfirm;
  Function? functionCancel;
  String? confirmButtonLabel;
  String? cancelButtonLabel;
  TextStyle? descTextStyle;

  final DialogController dialogController = Get.put(DialogController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = widget.request.data?['color'] ?? const Color(0xFF1A1A1A);
    colorConfirmButton = widget.request.data?['colorConfirmButton'] ?? const Color(0xFF5cb85b);
    colorCancelButton = widget.request.data?['colorCancelButton'] ?? Colors.grey.shade300;
    textDes1Color = widget.request.data?['textDes1Color'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFff6802),
        );

    textDes2Color = widget.request.data?['textDes2Color'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Colors.redAccent,
        );

    header = widget.request.data?['header'] ?? "";
    des1 = widget.request.data?['des1'] ?? "";
    des2 = widget.request.data?['des2'] ?? "";
    showIcon = widget.request.data?['showIcon'] ?? false;
    functionConfirm = widget.request.data?['functionConfirm'];
    functionCancel = widget.request.data?['functionCancel'];
    confirmButtonLabel = widget.request.data?['confirmButtonLabel'] ?? "Confirm";
    cancelButtonLabel = widget.request.data?['cancelButtonLabel'] ?? "Cancel";
    descTextStyle = widget.request.data?['descTextStyle'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFff6802),
        );

    EnterKeyChannelManager.setupMethodChannel((call) {
      if (call.method == 'enterKeyPressed') {
        widget.completer(DialogResponse(confirmed: true));
      } else {
        print('bbbbbbbb');
      }
      return Future.value();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dialogController.isDialogOpen.value = true;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      height: 200,
      width: 228,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.padding),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.request.title != null) ...[
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.request.title ?? "",
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
              color: Color(0xFFC5C5C5),
            ),
          ],
          Container(
            padding: EdgeInsets.only(left: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  des1?.toString() ?? "",
                  textAlign: TextAlign.start,
                  style: textDes1Color,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  des2?.toString() ?? "",
                  textAlign: TextAlign.start,
                  style: textDes2Color,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () async {
                    if (functionConfirm != null) {
                      await functionConfirm!();
                    }
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: colorConfirmButton,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 5),
                            blurRadius: 10),
                      ],
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        confirmButtonLabel ?? '',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 43, 43, 43),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () async {
                    if (functionCancel != null) {
                      await functionCancel!();
                    }
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: colorCancelButton,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 5),
                            blurRadius: 10),
                      ],
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        cancelButtonLabel ?? '',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 43, 43, 43),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

class CustomTwoButtonDialogBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const CustomTwoButtonDialogBox({super.key, required this.request, required this.completer});

  @override
  _CustomTwoButtonDialogBoxState createState() => _CustomTwoButtonDialogBoxState();
}

class _CustomTwoButtonDialogBoxState extends State<CustomTwoButtonDialogBox> {
  // late Timer _timer;
  Color? color;
  Color? colorfirstButton;
  Color? colorsecButton;
  Color? colorthButton;
  Color? textColor;
  bool? showIcon;
  Function? functionHold;
  Function? functionReject;
  Function? functionScrap;
  String? firstButtonLabel;
  String? secButtonLabel;
  String? thButtonLabel;
  TextStyle? descTextStyle;
  final FocusNode _focusNode = FocusNode();

  final DialogController dialogController = Get.put(DialogController());

  @override
  void initState() {
    super.initState();
    color = widget.request.data?['color'] ?? const Color(0xFF1A1A1A);
    colorfirstButton = widget.request.data?['colorfirstButton'] ?? const Color(0xFFC5C5C5);
    colorsecButton = widget.request.data?['colorsecButton'] ?? const Color(0xFFC5C5C5);
    colorthButton = widget.request.data?['colorthButton'] ?? const Color(0xFFC5C5C5);
    functionHold = widget.request.data?['functionHold'];
    functionReject = widget.request.data?['functionReject'];
    functionScrap = widget.request.data?['functionScrap'];
    firstButtonLabel = widget.request.data?['firstButtonLabel'];
    secButtonLabel = widget.request.data?['secButtonLabel'];
    thButtonLabel = widget.request.data?['thButtonLabel'];
    textColor = widget.request.data?['textColor'] ?? const Color(0xFF1A1A1A);
    showIcon = widget.request.data?['showIcon'] ?? true;
    descTextStyle = widget.request.data?['descTextStyle'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (value) async {
        if (value.logicalKey.keyLabel == "Enter") {
          if (functionHold != null) {
            await functionHold!();
          }
        }
      },
      child: Container(
        height: 184,
        width: 228,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (widget.request.title != null) ...[
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.request.title ?? "",
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  // color: const Color(0xFF1A1A1A),
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Color(0xFFC5C5C5),
              ),
              const SizedBox(
                height: 0,
              ),
            ],
            Text(
              widget.request.description ?? "",
              style: descTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: () async {
                      if (functionHold != null) {
                        await functionHold!();
                      }
                    },
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: colorfirstButton,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 5),
                              blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: Center(
                        child: Text(
                          firstButtonLabel ?? '',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 43, 43, 43),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: () async {
                      if (functionReject != null) {
                        await functionReject!();
                      }
                    },
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: colorsecButton,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 5),
                              blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: Center(
                        child: Text(
                          secButtonLabel ?? '',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 43, 43, 43),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class OneButtonDialogBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const OneButtonDialogBox({super.key, required this.request, required this.completer});

  @override
  _OneButtonDialogBoxState createState() => _OneButtonDialogBoxState();
}

class _OneButtonDialogBoxState extends State<OneButtonDialogBox> {
  Color? titleTextColor;
  Color? buttonColor;
  Color? textColor;
  bool? showIcon;
  Function()? functionOk;
  String? buttonLabel;
  TextStyle? descTextStyle;
  int? timerCount;
  Widget? descriptionWidget;
  late Timer timer;
  double? height = 190.00;
  Function(RawKeyEvent, Function(DialogResponse))? enterHandleFunction;
  final DialogController dialogController = Get.put(DialogController());
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    titleTextColor = widget.request.data?['titleTextColor'] ?? const Color(0xFF1A1A1A);
    buttonColor = widget.request.data?['buttonColor'] ?? const Color(0xFFC5C5C5);
    functionOk = widget.request.data?['functionOk'];
    timerCount = widget.request.data?['timerCount'] ?? 0;
    buttonLabel = widget.request.data?['buttonLabel'] ?? 'OK';
    textColor = widget.request.data?['textColor'] ?? const Color(0xFF1A1A1A);
    showIcon = widget.request.data?['showIcon'] ?? true;
    enterHandleFunction = widget.request.data?['enterHandleFunction'];
    descriptionWidget = widget.request.data?['descriptionWidget'];
    height = widget.request.data?['height'];
    descTextStyle = widget.request.data?['descTextStyle'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        );
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dialogController.isDialogOpen.value = true;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) async {
        if (enterHandleFunction != null) {
          await enterHandleFunction!(event, widget.completer);
        }
      },
      child: Container(
        height: height,
        width: 228,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.padding),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (widget.request.title != null) ...[
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.request.title ?? "",
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: titleTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Color(0xFFC5C5C5),
              ),
              const SizedBox(
                height: 0,
              ),
            ],
            descriptionWidget ??
                Text(
                  widget.request.description ?? "",
                  style: descTextStyle,
                  textAlign: TextAlign.center,
                ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: InkWell(
                onTap: () async {
                  if (functionOk != null) {
                    functionOk!;
                  }
                  widget.completer(DialogResponse(confirmed: true));
                },
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: Center(
                    child: Text(
                      buttonLabel!,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 43, 43, 43),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomConfirmDialogBox extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const CustomConfirmDialogBox({super.key, required this.request, required this.completer});

  @override
  _CustomConfirmDialogBoxState createState() => _CustomConfirmDialogBoxState();
}

class _CustomConfirmDialogBoxState extends State<CustomConfirmDialogBox> {
  // late Timer _timer;
  Color? color;
  Color? colorfirstButton;
  Color? colorsecButton;
  Color? colorthButton;
  Color? textColor;
  bool? showIcon;
  Function? functionHold;
  Function? functionReject;
  Function? functionScrap;
  Function(RawKeyEvent, Function(DialogResponse))? enterHandleFunction;
  String? firstButtonLabel;
  String? secButtonLabel;
  String? thButtonLabel;
  TextStyle? descTextStyle;
  ValueNotifier<bool> isShowDialog = ValueNotifier(true);
  double? height = 184.00;

  final FocusNode _focusNode = FocusNode();
  final DialogController dialogController = Get.put(DialogController());

  @override
  void initState() {
    super.initState();
    color = widget.request.data?['color'] ?? const Color(0xFF1A1A1A);
    colorfirstButton = widget.request.data?['colorfirstButton'] ?? const Color(0xFFC5C5C5);
    colorsecButton = widget.request.data?['colorsecButton'] ?? const Color(0xFFC5C5C5);
    colorthButton = widget.request.data?['colorthButton'] ?? const Color(0xFFC5C5C5);
    functionHold = widget.request.data?['functionHold'];
    functionReject = widget.request.data?['functionReject'];
    functionScrap = widget.request.data?['functionScrap'];
    enterHandleFunction = widget.request.data?['enterHandleFunction'];
    firstButtonLabel = widget.request.data?['firstButtonLabel'];
    secButtonLabel = widget.request.data?['secButtonLabel'];
    thButtonLabel = widget.request.data?['thButtonLabel'];
    textColor = widget.request.data?['textColor'] ?? const Color(0xFF1A1A1A);
    showIcon = widget.request.data?['showIcon'] ?? true;
    height = widget.request.data?['height'];
    isShowDialog = widget.request.data?['isShowDialog'] ?? ValueNotifier(true);
    descTextStyle = widget.request.data?['descTextStyle'] ??
        GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        );
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dialogController.isDialogOpen.value = true;
    return ValueListenableBuilder(
      valueListenable: isShowDialog,
      builder: (context, value, child) {
        if (value) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(context),
          );
        } else {
          return Container();
        }
      },
    );
  }

  contentBox(context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) async {
        if (enterHandleFunction != null) {
          await enterHandleFunction!(event, widget.completer);
        }
      },
      child: Container(
        height: height,
        width: 228,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (widget.request.title != null) ...[
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.request.title ?? "",
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  // color: const Color(0xFF1A1A1A),
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Color(0xFFC5C5C5),
              ),
              const SizedBox(
                height: 0,
              ),
            ],
            Text(
              widget.request.description ?? "",
              style: descTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: () async {
                      widget.completer(DialogResponse(confirmed: true));
                    },
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: colorfirstButton,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 5),
                              blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: Center(
                        child: Text(
                          firstButtonLabel ?? '',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 43, 43, 43),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: InkWell(
                    onTap: () async {
                      if (functionReject != null) {
                        await functionReject!();
                      }
                    },
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: colorsecButton,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 5),
                              blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: Center(
                        child: Text(
                          secButtonLabel ?? '',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 43, 43, 43),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
