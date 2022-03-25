import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:libadwaita_searchbar_ac/libadwaita_searchbar_ac.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:piped_api/piped_api.dart';

import 'package:pstube/providers/providers.dart';
import 'package:pstube/screens/screens.dart';
import 'package:pstube/utils/utils.dart';
import 'package:pstube/widgets/widgets.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _currentIndex = useState<int>(0);
    final _addDownloadController = TextEditingController();
    final _searchController = TextEditingController();
    final toggleSearch = useState<bool>(false);
    final searchedTerm = useState<String>('');
    final _controller = PageController(initialPage: _currentIndex.value);
    final videos = useMemoized(
      () => PipedApi().getUnauthenticatedApi().trending(
            region: ref.watch(regionProvider),
          ),
    );

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
        actions: AdwActions().bitsdojo,
        start: [
          AdwHeaderButton(
            isActive: toggleSearch.value,
            onPressed: toggleSearchBar,
            icon: const Icon(Icons.search, size: 20),
          ),
        ],
        title: toggleSearch.value
            ? AdwSearchBarAc(
                constraints: BoxConstraints.loose(const Size(500, 36)),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                toggleSearchBar: toggleSearchBar,
                asyncSuggestions: (str) => str.isNotEmpty
                    ? YoutubeExplode().search.getQuerySuggestions(str)
                    : Future.value([]),
                onSubmitted: (str) => searchedTerm.value = str,
                controller: _searchController,
              )
            : null,
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
              icon: const Icon(LucideIcons.trash),
              onPressed: clearAll,
            ),
        ],
        body: FutureBuilder<Response>(
          future: videos,
          builder: (context, snapshot) {
            final mainScreens = [
              HomeScreen(snapshot: snapshot),
              const PlaylistScreen(),
              const DownloadsScreen(),
              const SettingsScreen(),
            ];

            return Column(
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
                        ? HookBuilder(
                            builder: (_) {
                              final isMounted = useIsMounted();
                              final yt = YoutubeExplode();
                              final _currentPage = useState<SearchList?>(null);

                              Future<void> loadVideos() async {
                                if (!isMounted()) return;
                                _currentPage.value = await yt.search
                                    .getVideos(searchedTerm.value);
                              }

                              final controller = useScrollController();

                              Future<void> _getMoreData() async {
                                if (_currentPage.value != null &&
                                    isMounted() &&
                                    controller.position.pixels ==
                                        controller.position.maxScrollExtent) {
                                  final page =
                                      await _currentPage.value!.nextPage();

                                  if (page == null ||
                                      page.isEmpty ||
                                      !isMounted()) return;

                                  _currentPage.value!.addAll(page);
                                  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                  _currentPage.notifyListeners();
                                }
                              }

                              useEffect(
                                () {
                                  loadVideos();
                                  controller.addListener(_getMoreData);
                                  searchedTerm.addListener(loadVideos);
                                  return () {
                                    searchedTerm.removeListener(loadVideos);
                                    controller.removeListener(_getMoreData);
                                  };
                                },
                                [controller],
                              );

                              return _currentPage.value != null
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      controller: controller,
                                      itemCount: _currentPage.value!.length + 1,
                                      itemBuilder: (ctx, idx) =>
                                          idx == _currentPage.value!.length
                                              ? getCircularProgressIndicator()
                                              : SFVideo(
                                                  videoData:
                                                      _currentPage.value![idx],
                                                  isRow: !context.isMobile,
                                                  loadData: true,
                                                ),
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    );
                            },
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: Text(context.locals.typeToSearch)),
                            ],
                          ),
                  ),
              ],
            );
          },
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
