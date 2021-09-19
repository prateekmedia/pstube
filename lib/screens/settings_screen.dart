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
        ListTile(
          title: const Text("Download folder"),
          subtitle: Text(path),
          onTap: () async => ref.read(downloadPathProvider).path =
              await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose Download Folder'),
        ),
        SwitchListTile(
          title: const Text('Dark mode'),
          subtitle: const Text('Cause light attract bugs'),
          value: context.isDark,
          onChanged: (bool value) => ref.read(themeTypeProvider.notifier).themeType = value ? 2 : 1,
        ),
        SwitchListTile(
          title: const Text('Thumbnail downloader'),
          subtitle: const Text('Show thumbnail downloader in download popup'),
          value: ref.watch(thumbnailDownloaderProvider),
          onChanged: (bool value) => ref.read(thumbnailDownloaderProvider.notifier).value = value,
        ),
        const ListTile(
          title: Text("About"),
          subtitle: Text('Information about the app & the developers'),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
