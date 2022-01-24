import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutube/screens/screens.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:flutube/utils/utils.dart';
import 'package:flutube/providers/providers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  late String version = '';

  @override
  void initState() {
    super.initState();
    http
        .get(Uri.parse(
            'https://api.github.com/repos/prateekmedia/flutube/releases'))
        .then((http.Response response) async {
      compute(jsonDecode, response.body).then(
        (value) => setState(
          () {
            List json = value;
            version = json.first['tag_name'];
          },
        ),
      );
    }).catchError((exception) {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final path = ref.watch(downloadPathProvider).path;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      physics: const BouncingScrollPhysics(),
      children: [
        ListTile(
          title: Text(context.locals.downloadFolder),
          subtitle: Text(path),
          onTap: () async => ref.read(downloadPathProvider).path =
              await FilePicker.platform.getDirectoryPath(
                  dialogTitle: context.locals.chooseDownloadFolder),
        ),
        SwitchListTile(
          title: Text(context.locals.darkMode),
          value: context.isDark,
          onChanged: (bool value) =>
              ref.read(themeTypeProvider.notifier).themeType = value ? 2 : 1,
        ),
        SwitchListTile(
          title: Text(context.locals.thumbnailDownloader),
          subtitle: Text(context.locals.showThumbnailDownloaderInDownloadPopup),
          value: ref.watch(thumbnailDownloaderProvider),
          onChanged: (bool value) =>
              ref.read(thumbnailDownloaderProvider.notifier).value = value,
        ),
        FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              bool hasData = snapshot.hasData && snapshot.data != null;
              bool? isLatest = hasData && version.isNotEmpty
                  ? version == snapshot.data!.version
                  : null;
              return ListTile(
                title: Text(context.locals.update),
                onTap: hasData && isLatest != null
                    ? (isLatest
                        ? null
                        : (myApp.url + '/releases/latest').launchIt)
                    : null,
                subtitle: hasData && isLatest != null
                    ? Text(isLatest
                        ? context.locals.youAreUsingTheLatestVersion
                        : '$version ' + context.locals.isAvailable)
                    : const LinearProgressIndicator(),
              );
            }),
        ListTile(
          title: Text(context.locals.about + " ${myApp.name}"),
          onTap: () => context.pushPage(const AboutScreen()),
          subtitle: Text(context.locals.infoAboutTheAppAndtheDevelopers),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
