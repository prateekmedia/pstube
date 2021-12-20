import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';

class ChannelScreen extends HookWidget {
  final String id;
  const ChannelScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isMounted = useIsMounted();
    final yt = YoutubeExplode();
    final channel = useState<Channel?>(null);
    final channelInfo = useState<ChannelAbout?>(null);
    final _currentVidPage = useState<ChannelUploadsList?>(null);
    final controller = useScrollController();
    final _tabController = useTabController(initialLength: 2);
    List<String> _tabs = [context.locals.videos, context.locals.about];

    final List<Widget> getStats = channelInfo.value != null
        ? [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                context.locals.stats,
                style: context.textTheme.headline5!,
              ),
            ),
            const Divider(height: 26),
            Text(context.locals.joined + " " + channelInfo.value!.joinDate,
                style: context.textTheme.bodyText2),
            const Divider(height: 26),
            Text(
                channelInfo.value!.viewCount.addCommas +
                    " " +
                    context.locals.views,
                style: context.textTheme.bodyText2),
            const Divider(height: 26),
            Text(channelInfo.value!.country),
          ]
        : [];

    loadInitData() async {
      channel.value = await yt.channels.get(id);
      if (channel.value != null) {
        _currentVidPage.value =
            await yt.channels.getUploadsFromPage(channel.value!.id.value);
      }
      channelInfo.value = await yt.channels.getAboutPage(id);

      // channelInfo.value!.channelLinks
    }

    void _getMoreData() async {
      if (isMounted() &&
          controller.position.pixels == controller.position.maxScrollExtent &&
          _currentVidPage.value != null) {
        final page = await (_currentVidPage.value)!.nextPage();
        if (page == null || page.isEmpty && !isMounted()) return;
        _currentVidPage.value = page;
      }
    }

    useEffect(() {
      loadInitData();
      controller.addListener(_getMoreData);
      return () => controller.removeListener(_getMoreData);
    }, [controller]);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            <Widget>[
          SliverOverlapAbsorber(
            // This widget takes the overlapping behavior of the SliverAppBar,
            // and redirects it to the SliverOverlapInjector below. If it is
            // missing, then it is possible for the nested "inner" scroll view
            // below to end up under the SliverAppBar even when the inner
            // scroll view thinks it has not been scrolled.
            // This is not necessary if the "headerSliverBuilder" only builds
            // widgets that do not overlap the next sliver.
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: context.back,
              ),
              title: Text(channel.value?.title ?? "",
                  style: context.textTheme.headline5),
              floating: true,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                isScrollable: !context.isMobile,
                controller: _tabController,
                // These are the widgets to put in each tab in the tab bar.
                tabs: _tabs.map((String name) => Tab(text: name)).toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: NetStatus()),
        ],
        body: TabBarView(
          controller: _tabController,
          // These are the contents of the tab views, below the tabs.
          children: _tabs.asMap().entries.map((MapEntry<int, String> entry) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Builder(
                // This Builder is needed to provide a BuildContext that is
                // "inside" the NestedScrollView, so that
                // sliverOverlapAbsorberHandleFor() can find the
                // NestedScrollView.
                builder: (BuildContext context) {
                  return _CustomTab(
                    currentVidPage: _currentVidPage,
                    channelInfo: channelInfo,
                    getStats: getStats,
                    entry: entry,
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CustomTab extends StatefulWidget {
  const _CustomTab({
    Key? key,
    required ValueNotifier<ChannelUploadsList?> currentVidPage,
    required this.channelInfo,
    required this.getStats,
    required this.entry,
  })  : _currentVidPage = currentVidPage,
        super(key: key);

  final ValueNotifier<ChannelUploadsList?> _currentVidPage;
  final ValueNotifier<ChannelAbout?> channelInfo;
  final List<Widget> getStats;
  final MapEntry<int, String> entry;

  @override
  State<_CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<_CustomTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      // The "controller" and "primary" members should be left
      // unset, so that the NestedScrollView can control this
      // inner scroll view.
      // If the "controller" property is set, then this scroll
      // view will not be associated with the NestedScrollView.
      // The PageStorageKey should be unique to this ScrollView;
      // it allows the list to remember its scroll position when
      // the tab view is not on the screen.
      key: PageStorageKey<String>(widget.entry.value),
      slivers: <Widget>[
        SliverOverlapInjector(
          // This is the flip side of the SliverOverlapAbsorber
          // above.
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        if (widget.entry.key == 0)
          widget._currentVidPage.value != null
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // This builder is called for each child.
                      // In this example, we just number each list item.
                      return index == widget._currentVidPage.value!.length
                          ? getCircularProgressIndicator()
                          : FTVideo(
                              videoData: widget._currentVidPage.value![index],
                              loadData: true,
                              showChannel: false,
                              isRow: true,
                            );
                    },
                    // The childCount of the SliverChildBuilderDelegate
                    // specifies how many children this inner list
                    // has. In this example, each tab has a list of
                    // exactly 30 items, but this is arbitrary.
                    childCount: widget._currentVidPage.value!.length + 1,
                  ),
                )
              : SliverToBoxAdapter(
                  child: getCircularProgressIndicator(),
                )
        else
          SliverToBoxAdapter(
            child: widget.channelInfo.value != null
                ? Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        flex: 6,
                        child: ListView(
                          primary: false,
                          controller: ScrollController(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                context.locals.description,
                                style: context.textTheme.headline5!,
                              ),
                            ),
                            SelectableText(
                                widget.channelInfo.value!.description),
                            const Divider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                context.locals.links,
                                style: context.textTheme.headline5!,
                              ),
                            ),
                            Wrap(
                              children: [
                                for (ChannelLink link
                                    in widget.channelInfo.value!.channelLinks)
                                  GestureDetector(
                                    onTap: link.url.toString().launchIt,
                                    child: Chip(
                                      label: Text(link.title),
                                      labelStyle: context.textTheme.bodyText2,
                                    ),
                                  )
                              ],
                            ),
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
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
