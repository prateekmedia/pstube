import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/ui/widgets/widgets.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelScreen extends HookWidget {
  const ChannelScreen({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();
    final yt = YoutubeExplode();
    final channel = useState<Channel?>(null);
    final channelInfo = useState<ChannelAbout?>(null);
    final _currentVidPage = useState<ChannelUploadsList?>(null);
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
      final yte = YoutubeExplode();

      _currentVidPage.value =
          await yte.channels.getUploadsFromPage(channel.value!.id.value);
    }

    Future<void> loadInitData() async {
      channel.value = await yt.channels.get(id);

      if (!isMounted()) return;
      await getVideos();
      channelInfo.value = await yt.channels.getAboutPage(id);
    }

    Future<void> _getMoreData() async {
      if (isMounted() &&
          controller.position.pixels == controller.position.maxScrollExtent) {
        final page = await _currentVidPage.value!.nextPage();

        if (page == null || page.isEmpty || !isMounted()) return;

        _currentVidPage.value!.addAll(page);
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        _currentVidPage.notifyListeners();
      }
    }

    useEffect(
      () {
        loadInitData();
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
      title: channel.value != null ? Text(channel.value!.title) : null,
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
                child: _CustomTab(
                  currentVidPage: _currentVidPage.value,
                  channelInfo: channelInfo.value,
                  getStats: getStats,
                  channel: channel.value,
                  videosScreen: ListView.builder(
                    shrinkWrap: true,
                    controller: controller,
                    itemCount: _currentVidPage.value != null
                        ? _currentVidPage.value!.length + 1
                        : 1,
                    itemBuilder: (ctx, index) =>
                        index == _currentVidPage.value!.length
                            ? getCircularProgressIndicator()
                            : PSVideo(
                                videoData: _currentVidPage.value![index],
                                loadData: true,
                                showChannel: false,
                                isRow: true,
                              ),
                  ),
                  entry: entry,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CustomTab extends StatefulWidget {
  const _CustomTab({
    Key? key,
    required ChannelUploadsList? currentVidPage,
    required this.channelInfo,
    required this.getStats,
    required this.channel,
    required this.entry,
    required this.videosScreen,
  })  : _currentVidPage = currentVidPage,
        super(key: key);

  final ChannelUploadsList? _currentVidPage;
  final ChannelAbout? channelInfo;
  final List<Widget> getStats;
  final Channel? channel;
  final MapEntry<int, String> entry;
  final Widget videosScreen;

  @override
  State<_CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<_CustomTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AdwClamp.scrollable(
      maximumSize: 1200,
      child: (widget.entry.key == 0 && widget.channel != null)
          ? Column(
              children: [
                CachedNetworkImage(imageUrl: widget.channel!.bannerUrl),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                widget.channel!.logoUrl,
                              ),
                            ),
                            color: Colors.grey,
                          ),
                          height: 80,
                          width: 80,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.channel!.title),
                          Text(
                            widget.channel!.subscribersCount != null
                                ? '${widget.channel!.subscribersCount!.addCommas} ${context.locals.subscribers}'
                                : context.locals.hidden,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : (widget.entry.key == 1 && widget._currentVidPage != null)
              ? widget.videosScreen
              : widget.entry.key == 2 && widget.channelInfo != null
                  ? Flex(
                      direction: Axis.horizontal,
                      children: [
                        Flexible(
                          flex: 6,
                          child: ListView(
                            primary: false,
                            controller: ScrollController(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            children: [
                              if (widget.channelInfo!.description != null) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    context.locals.description,
                                    style: context.textTheme.headline5,
                                  ),
                                ),
                                SelectableText(
                                  widget.channelInfo!.description!,
                                ),
                              ],
                              if (widget
                                  .channelInfo!.channelLinks.isNotEmpty) ...[
                                const Divider(),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    context.locals.links,
                                    style: context.textTheme.headline5,
                                  ),
                                ),
                                Wrap(
                                  children: [
                                    for (ChannelLink link
                                        in widget.channelInfo!.channelLinks)
                                      AdwButton.pill(
                                        onPressed: link.url.toString().launchIt,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                          vertical: 3,
                                        ),
                                        child: Text(link.title),
                                        //   labelStyle: context.textTheme.bodyText2,
                                        // ),
                                      )
                                  ],
                                ),
                              ],
                              if (context.isMobile) ...[
                                const Divider(),
                                ...widget.getStats,
                              ]
                            ],
                          ),
                        ),
                        if (!context.isMobile)
                          Flexible(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.getStats,
                            ),
                          ),
                      ],
                    )
                  : getCircularProgressIndicator(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
