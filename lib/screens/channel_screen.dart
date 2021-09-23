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
    final channel = useFuture(useMemoized(() => YoutubeExplode().channels.get(id)));
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
            title: Text(channel.data != null ? channel.data!.title : ""),
            flexibleSpace: channel.data != null
                ? FlexibleSpaceBar(
                    background: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChannelInfo(channel: channel, textColor: Colors.white),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: FtBody(
              expanded: false,
              child: FutureBuilder<ChannelUploadsList>(
                future: channel.hasData && channel.data != null
                    ? YoutubeExplode().channels.getUploadsFromPage(channel.data!.id.value)
                    : null,
                builder: (ctx, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (ctx, idx) => FTVideo(
                            videoData: snapshot.data![idx],
                            loadData: true,
                            showChannel: false,
                            isRow: true,
                          ),
                          itemCount: snapshot.data!.length,
                        )
                      : getCircularProgressIndicator();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
