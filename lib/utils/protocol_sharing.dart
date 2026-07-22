import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareProtocolImage({
  required BuildContext context,
  required Widget protocolWidget,
  String? text,
}) async {
  try {
    final bytes = await ScreenshotController().captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: protocolWidget,
          ),
        ),
      ),
      context: context,
      pixelRatio: 3.0,
      constraints: BoxConstraints.tightFor(
        width: MediaQuery.of(context).size.width,
      ),
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: 'plump_protokoll.png',
          ),
        ],
        text: text,
      ),
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunde inte dela protokollet')),
      );
    }
  }
}
