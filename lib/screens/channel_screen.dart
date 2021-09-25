import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class ChannelScreen extends HookWidget {
  final String id;
  const ChannelScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isMounted = useIsMounted();
    final yt = YoutubeExplode();
    final channel = useState<Channel?>(null);
    final _currentVidPage = useState<ChannelUploadsList?>(null);
    final controller = useScrollController();

    loadInitData() async {
      channel.value = await yt.channels.get(id);
      if (channel.value != null) {
        _currentVidPage.value = await yt.channels.getUploadsFromPage(channel.value!.id.value);
      }
    }

    void _getMoreData() async {
      if (isMounted() &&
          controller.position.pixels == controller.position.maxScrollExtent &&
          _currentVidPage.value != null) {
        final page = await (_currentVidPage.value)!.nextPage();
        if (page == null || page.isEmpty) return;
        _currentVidPage.value = page;
      }
    }

    useEffect(() {
      loadInitData();
      controller.addListener(_getMoreData);
      return () => controller.removeListener(_getMoreData);
    }, [controller]);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(LucideIcons.chevronLeft),
              onPressed: context.back,
            ),
            centerTitle: true,
            title: Text(channel.value?.title ?? ""),
            flexibleSpace: channel.value != null
                ? FlexibleSpaceBar(
                    background: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChannelInfo(
                            channel: AsyncSnapshot.withData(ConnectionState.done, channel.value!),
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: FtBody(
              expanded: false,
              child: _currentVidPage.value != null
                  ? ListView.builder(
                      controller: controller,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (ctx, idx) => idx == _currentVidPage.value!.length
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
            ),
          ),
        ],
      ),
    );
  }
}
