import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    final tabController = useTabController(initialLength: 2);
    final List<Widget> getStats = channelInfo.value != null
        ? [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Stats",
                style: context.textTheme.headline5!,
              ),
            ),
            const Divider(height: 26),
            Text("Joined " + channelInfo.value!.joinDate,
                style: context.textTheme.bodyText2),
            const Divider(height: 26),
            Text(channelInfo.value!.viewCount.addCommas + " views",
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
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronLeft),
              onPressed: context.back,
            ),
            title: Text(channel.value?.title ?? "",
                style: context.textTheme.headline5),
            bottom: TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [Tab(text: "Videos"), Tab(text: "About")],
            ),
            actions: [
              buildSearchButton(context),
            ],
          ),
        ],
        body: FtBody(
          expanded: true,
          child: TabBarView(
            controller: tabController,
            children: [
              _currentVidPage.value != null
                  ? ListView.builder(
                      controller: controller,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (ctx, idx) =>
                          idx == _currentVidPage.value!.length
                              ? getCircularProgressIndicator()
                              : FTVideo(
                                  videoData: _currentVidPage.value![idx],
                                  loadData: true,
                                  showChannel: false,
                                  isRow: true,
                                ),
                      itemCount: _currentVidPage.value!.length + 1,
                    )
                  : getCircularProgressIndicator(),
              channelInfo.value != null
                  ? Flex(
                      direction: Axis.horizontal,
                      children: [
                        Flexible(
                          flex: 6,
                          child: ListView(
                            primary: false,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Description  ",
                                  style: context.textTheme.headline5!,
                                ),
                              ),
                              SelectableText(channelInfo.value!.description),
                              const Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Links",
                                  style: context.textTheme.headline5!,
                                ),
                              ),
                              Wrap(
                                children: [
                                  for (ChannelLink link
                                      in channelInfo.value!.channelLinks)
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
                                ...getStats,
                              ]
                            ],
                          ),
                        ),
                        if (!context.isMobile)
                          Flexible(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: getStats,
                            ),
                          ),
                      ],
                    )
                  : getCircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
