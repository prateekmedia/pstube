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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: context.back,
        ),
      ),
      body: channel.hasData && channel.data != null
          ? ListView(
              children: [
                const SizedBox(height: 40),
                ChannelInfo(channel: channel),
              ],
            )
          : const CircularProgressIndicator().center(),
    );
  }
}
