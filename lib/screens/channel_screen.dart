import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class ChannelScreen extends HookWidget {
  final String id;
  const ChannelScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channel =
        useFuture(useMemoized(() => YoutubeExplode().channels.get(id)));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            centerTitle: true,
            title: Text(channel.data != null ? channel.data!.title : ""),
            flexibleSpace: channel.data != null
                ? FlexibleSpaceBar(
                    background: Center(
                      child: Container(
                        color: context.isDark
                            ? Colors.grey[900]
                            : Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChannelInfo(channel: channel),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          if (channel.hasData && channel.data != null) ...[
            SliverToBoxAdapter(
              child: FutureBuilder<ChannelUploadsList>(
                future: YoutubeExplode()
                    .channels
                    .getUploadsFromPage(channel.data!.id.value),
                builder: (ctx, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (ctx, idx) => FTVideo(
                            videoData: snapshot.data![idx],
                            isOnChannelScreen: true,
                            isRow: true,
                          ),
                          itemCount: snapshot.data!.length,
                        )
                      : const CircularProgressIndicator().center();
                },
              ),
            )
          ] else
            SliverToBoxAdapter(
                child: const CircularProgressIndicator().center()),
        ],
      ),
    );
  }
}
