import 'package:clipboard_history/clipboard_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paste_panda/clipboard_list.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/constants.dart';
import 'package:yaru/settings.dart';

void main() async {
  final clipboard = ClipboardHistory.sharedPreferences();
  await clipboard.init();
  registerServiceInstance(clipboard);

  runApp(const PastePandaApp());
}

class PastePandaApp extends StatelessWidget {
  const PastePandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: YaruTheme(
        builder: (context, yaru, child) => MaterialApp(
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(kYaruPagePadding),
              child: ClipboardList(),
            ),
          ),
        ),
      ),
    );
  }
}
