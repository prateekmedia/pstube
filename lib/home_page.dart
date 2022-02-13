import 'dart:io';

import 'package:ant_icons/ant_icons.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dio/dio.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:piped_api/piped_api.dart';

import 'package:sftube/providers/providers.dart';
import 'package:sftube/screens/screens.dart';
import 'package:sftube/utils/utils.dart';
import 'package:sftube/widgets/widgets.dart';

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
        appWindow: platformAppWindow,
        start: [
          AdwHeaderButton(
            isActive: toggleSearch.value,
            onPressed: toggleSearchBar,
            icon: const Icon(AntIcons.search_outline, size: 20),
          ),
        ],
        title: toggleSearch.value
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                color: Theme.of(context).appBarTheme.backgroundColor,
                constraints: BoxConstraints.loose(const Size(500, 40)),
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) {
                    if (event.runtimeType == RawKeyDownEvent &&
                        event.logicalKey.keyId == 4294967323) {
                      toggleSearchBar(value: false);
                    }
                  },
                  child: EasyAutocomplete(
                    asyncSuggestions: (str) =>
                        YoutubeExplode().search.getQuerySuggestions(str),
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      constraints: BoxConstraints.loose(const Size(500, 36)),
                      fillColor: context.theme.canvasColor,
                      contentPadding: const EdgeInsets.only(top: 8),
                      filled: true,
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onChanged: (v) {},
                    onSubmitted: (str) => searchedTerm.value = str,
                    suggestionBuilder: (data) => Container(
                      margin: const EdgeInsets.all(1),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(data),
                    ),
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
                              _currentPage.value =
                                  await yt.search.getVideos(searchedTerm.value);
                            }

                            final controller = useScrollController();

                            Future<void> _getMoreData() async {
                              if (isMounted() &&
                                  controller.position.pixels ==
                                      controller.position.maxScrollExtent &&
                                  _currentPage.value != null) {
                                final page =
                                    await (_currentPage.value)!.nextPage();
                                if (page == null ||
                                    page.isEmpty && !isMounted()) {
                                  return;
                                }

                                _currentPage.value!.addAll(page);
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
                                    itemBuilder: (ctx, idx) => idx ==
                                            _currentPage.value!.length
                                        ? getCircularProgressIndicator()
                                        : SFVideo(
                                            videoData: _currentPage.value![idx],
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
