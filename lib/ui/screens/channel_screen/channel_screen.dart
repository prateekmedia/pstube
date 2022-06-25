import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:piped_api/piped_api.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/ui/screens/channel_screen/tabs/tabs.dart';
import 'package:pstube/ui/widgets/widgets.dart' hide ChannelInfo;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelScreen extends HookWidget {
  const ChannelScreen({super.key, required this.channelId});
  final String channelId;

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();
    final yt = YoutubeExplode();
    final channel = useState<ChannelInfo?>(null);
    final channelInfo = useState<ChannelAbout?>(null);
    final currentVidPage = useState<BuiltList<StreamItem>?>(null);
    final _pageController = usePageController();
    final _currentIndex = useState<int>(0);
    final _tabs = <String, IconData>{
      context.locals.home: LucideIcons.home,
      context.locals.videos: LucideIcons.video,
      context.locals.about: LucideIcons.info,
    };
    final controller = useScrollController();
    final nextPageToken = useState<String?>(null);

    Future<void> getVideos() async {
      currentVidPage.value = channel.value!.relatedStreams;
    }

    final api = PipedApi().getUnauthenticatedApi();

    Future<void> loadChannelData() async {
      channel.value = (await api.channelInfoId(
        channelId: channelId,
      ))
          .data;

      nextPageToken.value = channel.value!.nextpage;

      if (!isMounted()) return;
      await getVideos();
    }

    Future<void> loadAboutPage() async {
      channelInfo.value = await yt.channels.getAboutPage(channelId);
    }

    Future<dynamic> _getMoreData() async {
      if (!isMounted() ||
          channel.value == null ||
          nextPageToken.value == null ||
          controller.position.pixels != controller.position.maxScrollExtent) {
        return;
      }

      final nextPage = await api.channelNextPage(
        channelId: channel.value!.id!,
        nextpage: nextPageToken.value!,
      );

      if (nextPage.data == null && nextPage.data!.relatedStreams != null) {
        return;
      }

      nextPageToken.value = nextPage.data!.nextpage;

      currentVidPage.value = currentVidPage.value!.rebuild(
        (b) => b.addAll(
          nextPage.data!.relatedStreams!.toList(),
        ),
      );
    }

    useEffect(
      () {
        loadChannelData();
        loadAboutPage();

        controller.addListener(_getMoreData);
        return () => controller.removeListener(_getMoreData);
      },
      [controller],
    );

    return AdwScaffold(
      actions: AdwActions().bitsdojo,
      start: [
        context.backLeading(),
      ],
      title: channel.value != null
          ? Text(
              channel.value!.name.toString(),
            )
          : null,
      viewSwitcher: AdwViewSwitcher(
        currentIndex: _currentIndex.value,
        onViewChanged: _pageController.jumpToPage,
        tabs: _tabs.entries
            .map((e) => ViewSwitcherData(title: e.key, icon: e.value))
            .toList(),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) => _currentIndex.value = idx,
        // These are the contents of the tab views, below the tabs.
        children: _tabs.keys.toList().asMap().entries.map(
          (MapEntry<int, String> entry) {
            ScrollController? scrollController;
            late Widget tab;
            late bool isVisible;

            switch (entry.key) {
              case 0:
                tab = ChannelHomeTab(
                  channel: channel.value,
                );
                isVisible = channel.value != null;
                break;
              case 1:
                scrollController = controller;
                tab = ChannelVideosTab(
                  channel: channel.value,
                  currentVidPage: currentVidPage,
                );
                isVisible = currentVidPage.value != null;
                break;
              case 2:
                tab = ChannelAboutTab(
                  channelInfo: channelInfo.value,
                );
                isVisible = currentVidPage.value != null;
                break;
              default:
            }

            return _KeepAliveTab(
              controller: scrollController,
              isVisible: isVisible,
              tab: tab,
            );
          },
        ).toList(),
      ),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({
    required this.isVisible,
    required this.tab,
    this.controller,
  });

  final bool isVisible;
  final Widget tab;
  final ScrollController? controller;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: AdwClamp.scrollable(
        controller: widget.controller,
        maximumSize: 1200,
        child: Visibility(
          visible: widget.isVisible,
          replacement: getCircularProgressIndicator(),
          child: widget.tab,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
