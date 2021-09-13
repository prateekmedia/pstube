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
                    color: context.getAltBackgroundColor,
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
        SwitchListTile(
          title: const Text('Dark mode'),
          value: context.isDark,
          onChanged: (bool value) => ref.read(themeTypeProvider.notifier).themeType = value ? 2 : 1,
        ),
        SwitchListTile(
          title: const Text('Thumbnail downloader'),
          value: context.isDark,
          onChanged: (bool value) => ref.read(themeTypeProvider.notifier).themeType = value ? 2 : 1,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
