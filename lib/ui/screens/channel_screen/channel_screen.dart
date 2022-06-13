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
    final _currentVidPage = useState<BuiltList<StreamItem>?>(null);
    final _pageController = usePageController();
    final controller = useScrollController();
    final _currentIndex = useState<int>(0);
    final _tabs = <String, IconData>{
      context.locals.home: LucideIcons.home,
      context.locals.videos: LucideIcons.video,
      context.locals.about: LucideIcons.info,
    };

    final getStats = channelInfo.value != null
        ? <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.locals.stats,
                style: context.textTheme.headline5,
              ),
            ),
            const Divider(height: 26),
            Text(
              '${context.locals.joined} ${channelInfo.value!.joinDate}',
              style: context.textTheme.bodyText2,
            ),
            const Divider(height: 26),
            Text(
              '${(channelInfo.value!.viewCount ?? 0).addCommas} '
              '${context.locals.views}',
              style: context.textTheme.bodyText2,
            ),
            if (channelInfo.value!.country != null) ...[
              const Divider(height: 26),
              Text(channelInfo.value!.country!),
            ],
          ]
        : <Widget>[];

    Future<void> getVideos() async {
      _currentVidPage.value = channel.value!.relatedStreams;
    }

    Future<void> loadChannelData() async {
      channel.value = (await PipedApi().getUnauthenticatedApi().channelInfoId(
                channelId: channelId,
              ))
          .data;

      if (!isMounted()) return;
      await getVideos();
    }

    Future<void> loadAboutPage() async {
      channelInfo.value = await yt.channels.getAboutPage(channelId);
    }

    Future<void> _getMoreData() async {
      if (isMounted() &&
          controller.position.pixels == controller.position.maxScrollExtent) {
        // final yes = channel.value!.nextpage;

        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        _currentVidPage.notifyListeners();
      }
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
        children: _tabs.keys
            .toList()
            .asMap()
            .entries
            .map(
              (MapEntry<int, String> entry) => SafeArea(
                top: false,
                bottom: false,
                child: _KeepAliveTab(
                  isHomeVisible: entry.key == 0 && channel.value != null,
                  isVideosVisible:
                      entry.key == 1 && _currentVidPage.value != null,
                  isAboutVisible: entry.key == 2 && channelInfo.value != null,
                  homeTab: ChannelHomeTab(
                    channel: channel.value,
                  ),
                  videosTab: ChannelVideosTab(
                    controller: controller,
                    currentVidPage: _currentVidPage,
                  ),
                  aboutTab: ChannelAboutTab(
                    channelInfo: channelInfo.value,
                    getStats: getStats,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({
    required this.isHomeVisible,
    required this.isVideosVisible,
    required this.isAboutVisible,
    required this.homeTab,
    required this.videosTab,
    required this.aboutTab,
  });

  final bool isHomeVisible;
  final bool isVideosVisible;
  final bool isAboutVisible;
  final Widget homeTab;
  final Widget videosTab;
  final Widget aboutTab;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AdwClamp.scrollable(
      maximumSize: 1200,
      child: widget.isHomeVisible
          ? widget.homeTab
          : widget.isVideosVisible
              ? widget.videosTab
              : widget.isAboutVisible
                  ? widget.aboutTab
                  : getCircularProgressIndicator(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
