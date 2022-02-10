import 'dart:io';

import 'package:ant_icons/ant_icons.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutube/providers/providers.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _currentIndex = useState<int>(0);
    final _addDownloadController = TextEditingController();
    final toggleSearch = useState<bool>(false);
    final searchedTerm = useState<String>('');
    final _controller = PageController();

    void switchSearchBar({bool? value}) {
      searchedTerm.value = '';
      toggleSearch.value = value ?? !toggleSearch.value;
    }

    final mainScreens = [
      const HomeScreen(),
      const PlaylistScreen(),
      const DownloadsScreen(),
      const SettingsScreen(),
    ];

    final navItems = <String, List<IconData>>{
      context.locals.home: [AntIcons.home_outline, AntIcons.home],
      context.locals.playlist: [AntIcons.unordered_list],
      context.locals.downloads: [Icons.download_outlined, Icons.download],
      context.locals.settings: [AntIcons.setting_outline, AntIcons.setting],
    };

    Future addDownload() async {
      if (_addDownloadController.text.isEmpty) {
        final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
        final youtubeRegEx = RegExp(
          r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$',
        );
        if (clipboard != null &&
            clipboard.text != null &&
            youtubeRegEx.hasMatch(clipboard.text!)) {
          _addDownloadController.text = clipboard.text!;
        }
      }
      return showPopoverWB<dynamic>(
        context: context,
        onConfirm: () {
          context.back();
          if (_addDownloadController.value.text.isNotEmpty) {
            showDownloadPopup(context, videoUrl: _addDownloadController.text);
          }
        },
        hint: 'https://youtube.com/watch?v=***********',
        title: context.locals.downloadFromVideoUrl,
        controller: _addDownloadController,
      );
    }

    void clearAll() {
      final deleteFromStorage = ValueNotifier<bool>(false);
      showPopoverWB<dynamic>(
        context: context,
        builder: (ctx) => ValueListenableBuilder<bool>(
          valueListenable: deleteFromStorage,
          builder: (_, value, ___) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.locals.clearAll,
                  style: context.textTheme.bodyText1,
                ),
                CheckboxListTile(
                  value: value,
                  onChanged: (val) => deleteFromStorage.value = val!,
                  title: Text(context.locals.alsoDeleteThemFromStorage),
                ),
              ],
            );
          },
        ),
        onConfirm: () {
          final downloadListUtils = ref.read(downloadListProvider);
          for (final item in downloadListUtils.downloadList) {
            if (File(item.queryVideo.path + item.queryVideo.name)
                    .existsSync() &&
                deleteFromStorage.value) {
              File(item.queryVideo.path + item.queryVideo.name).deleteSync();
            }
          }
          downloadListUtils.clearAll();
          context.back();
        },
        confirmText: context.locals.yes,
        title: context.locals.confirm,
      );
    }

    return AdwScaffold(
      headerbar: (viewSwitcher) => AdwHeaderBar.bitsdojo(
        appWindow: appWindow,
        start: [
          AdwHeaderButton(
            isActive: toggleSearch.value,
            onPressed: () => toggleSearch.value = !toggleSearch.value,
            icon: const Icon(AntIcons.search_outline, size: 20),
          ),
        ],
        title: toggleSearch.value
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Theme.of(context).appBarTheme.backgroundColor,
                constraints: BoxConstraints.loose(const Size(500, 50)),
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) {
                    if (event.runtimeType == RawKeyDownEvent &&
                        event.logicalKey.keyId == 4294967323) {
                      switchSearchBar(value: false);
                    }
                  },
                  child: AdwTextField(
                    onChanged: (query) => searchedTerm.value = query,
                    icon: Icons.search,
                  ),
                ),
              )
            : viewSwitcher,
        end: [
          if (!toggleSearch.value)
            AdwHeaderButton(
              onPressed: addDownload,
              icon: const Icon(
                Icons.add,
                size: 17,
              ),
            ),
          if (!toggleSearch.value && _currentIndex.value == 2)
            AdwHeaderButton(
              icon: const Icon(AntIcons.delete_outline),
              onPressed: clearAll,
            ),
          if (!toggleSearch.value && _currentIndex.value == 3)
            AdwPopupMenu(
              body: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdwButton.flat(
                    child: Text(context.locals.resetDefault),
                    onPressed: () => resetDefaults(ref),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SFBody(
        child: PageView.builder(
          controller: _controller,
          itemCount: mainScreens.length,
          itemBuilder: (context, index) => mainScreens[index],
          onPageChanged: (index) => _currentIndex.value = index,
        ),
      ),
      viewSwitcher: !toggleSearch.value
          ? AdwViewSwitcher(
              tabs: List.generate(
                navItems.entries.length,
                (index) {
                  final item = navItems.entries.elementAt(index);
                  return ViewSwitcherData(
                    title: item.key,
                    icon: item.value[0],
                  );
                },
              ),
              currentIndex: _currentIndex.value,
              onViewChanged: _controller.jumpToPage,
            )
          : null,
    );
  }
}
