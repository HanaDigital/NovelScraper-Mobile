import 'package:flutter/material.dart';
import 'package:novelscraper/components/text.dart';
import 'package:novelscraper/theme.dart';

enum DialogType {
  constructive,
  destructive,
}

void confirmationDialog({
  required BuildContext context,
  required String title,
  required String body,
  DialogType type = DialogType.constructive,
  String confirmText = 'Confirm',
  required void Function() onConfirm,
  String cancelText = 'Cancel',
  void Function()? onCancel,
}) async {
  Color fgColor = AppColors.primaryColor;
  Color bgColor = AppColors.primaryColor.withOpacity(0.1);
  if (type == DialogType.destructive) {
    fgColor = AppColors.errorColor;
    bgColor = AppColors.errorColor.withOpacity(0.1);
  }
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TitleText(title),
          content: SingleChildScrollView(
            child: MediumText(body),
          ),
          actions: <Widget>[
            TextButton(
              child: SmallText(cancelText),
              onPressed: () {
                if (onCancel != null) onCancel();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(bgColor),
              ),
              child: SmallText(
                confirmText,
                style: TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
