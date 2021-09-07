import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final path = ref.watch(downloadPathProvider).path;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        const Text("Download path"),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async => ref.read(downloadPathProvider).path =
                    await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose Download Folder'),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.grey[900] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.textTheme.bodyText1!.color!.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(path),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dark Mode'),
            Switch(
                value: context.isDark,
                onChanged: (value) {
                  ref.read(themeTypeProvider.notifier).themeType = context.isDark ? 1 : 0;
                })
          ],
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
