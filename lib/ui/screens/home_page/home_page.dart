import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_searchbar_ac/libadwaita_searchbar_ac.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/states/history/provider.dart';
import 'package:pstube/states/states.dart';
import 'package:pstube/ui/screens/home_page/search_screen.dart';
import 'package:pstube/ui/screens/home_page/tabs.dart';
import 'package:pstube/ui/widgets/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yexp;

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _currentIndex = useState<int>(0);
    final _addDownloadController = TextEditingController();
    final _searchController = TextEditingController();
    final toggleSearch = useState<bool>(false);
    final searchedTerm = useState<String>('');
    final _controller = PageController(initialPage: _currentIndex.value);

    final mainScreens = [
      const HomeTab(),
      const PlaylistTab(),
      const DownloadsTab(),
      const SettingsTab(),
    ];

    void toggleSearchBar({bool? value}) {
      searchedTerm.value = '';
      toggleSearch.value = value ?? !toggleSearch.value;
    }

    final navItems = <String, IconData>{
      context.locals.home: LucideIcons.home,
      context.locals.playlist: LucideIcons.list,
      context.locals.downloads: LucideIcons.download,
      context.locals.settings: LucideIcons.settings,
    };

    Future<dynamic> addDownload() async {
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
      return showPopoverForm(
        context: context,
        onConfirm: () {
          if (_addDownloadController.value.text.isNotEmpty) {
            context.back();
            showDownloadPopup(
              context,
              isClickable: true,
              videoUrl: _addDownloadController.text
                  .split('/')
                  .last
                  .split('watch?v=')
                  .last,
            );
          }
        },
        hint: 'https://youtube.com/watch?v=***********',
        title: context.locals.downloadFromVideoUrl,
        controller: _addDownloadController,
      );
    }

    void clearAll() {
      final deleteFromStorage = ValueNotifier<bool>(false);
      showPopoverForm(
        context: context,
        builder: (ctx) => ValueListenableBuilder<bool>(
          valueListenable: deleteFromStorage,
          builder: (_, value, ___) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.locals.clearAll,
                  style: context.textTheme.bodyLarge,
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

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex.value != 0) {
          _controller.jumpToPage(0);
          return false;
        } else if (toggleSearch.value) {
          toggleSearchBar();
          return false;
        }

        return true;
      },
      child: AdwScaffold(
        actions: AdwActions().windowManager,
        start: [
          AdwHeaderButton(
            isActive: toggleSearch.value,
            onPressed: toggleSearchBar,
            icon: Icon(
              toggleSearch.value == true ? Icons.chevron_left : Icons.search,
              size: 20,
            ),
          ),
        ],
        title: toggleSearch.value
            ? AdwSearchBarAc(
                constraints: BoxConstraints.loose(const Size(500, 40)),
                toggleSearchBar: toggleSearchBar,
                hintText: '',
                // search: null,
                asyncSuggestions: (str) => str.trim().isNotEmpty
                    ? yexp.YoutubeExplode().search.getQuerySuggestions(str)
                    : Future.value(ref.watch(historyProvider.notifier).history),
                onSubmitted: (str) => searchedTerm.value = str,
                controller: _searchController,
              )
            : null,
        end: [
          if (!toggleSearch.value)
            AdwHeaderButton(
              onPressed: addDownload,
              icon: const Icon(Icons.add, size: 17),
            ),
          if (!toggleSearch.value && _currentIndex.value == 2)
            AdwHeaderButton(
              icon: const Icon(LucideIcons.trash),
              onPressed: clearAll,
            ),
        ],
        body: Column(
          children: [
            if (!toggleSearch.value)
              Flexible(
                child: SFBody(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: mainScreens.length,
                    itemBuilder: (context, index) => mainScreens[index],
                    onPageChanged: (index) => _currentIndex.value = index,
                  ),
                ),
              )
            else
              Flexible(
                child: searchedTerm.value.isNotEmpty
                    ? SearchScreen(
                        searchedTerm: searchedTerm,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(context.locals.typeToSearch),
                          ),
                        ],
                      ),
              ),
          ],
        ),
        viewSwitcher: !toggleSearch.value
            ? AdwViewSwitcher(
                tabs: List.generate(
                  navItems.entries.length,
                  (index) {
                    final item = navItems.entries.elementAt(index);
                    return ViewSwitcherData(
                      title: item.key,
                      badge: index == 2
                          ? ref.watch(downloadListProvider).downloading
                          : null,
                      icon: item.value,
                    );
                  },
                ),
                currentIndex: _currentIndex.value,
                onViewChanged: _controller.jumpToPage,
              )
            : null,
      ),
    );
  }
}
