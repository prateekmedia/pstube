import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/providers/providers.dart';
import 'package:pstube/utils/utils.dart';
import 'package:pstube/widgets/video_screen/video_action.dart';
import 'package:pstube/widgets/video_screen/video_screen.dart';
import 'package:pstube/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoActions extends HookConsumerWidget {
  const VideoActions({
    Key? key,
    required this.videoData,
    required this.downloadsSideWidget,
    required this.commentSideWidget,
    required this.snapshot,
  }) : super(key: key);

  final Video videoData;
  final ValueNotifier<Widget?> downloadsSideWidget;
  final ValueNotifier<Widget?> commentSideWidget;
  final AsyncSnapshot<StreamManifest> snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedList = ref.watch(likedListProvider);
    final isLiked = useState<bool>(
      likedList.likedVideoList.contains(videoData.url),
    );
    final _textController = TextEditingController();

    void updateLike() {
      isLiked.value = !isLiked.value;

      if (isLiked.value) {
        likedList.addVideo(videoData.url);
      } else {
        likedList.removeVideo(videoData.url);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VideoAction(
            icon: isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
            onPressed: updateLike,
            label: videoData.engagement.likeCount != null
                ? videoData.engagement.likeCount!.formatNumber
                : context.locals.like,
          ),
          VideoAction(
            icon: Icons.share_outlined,
            onPressed: () {
              Share.share(
                videoData.url,
              );
            },
            label: context.locals.share,
          ),
          VideoAction(
            icon: Icons.download_outlined,
            onPressed: downloadsSideWidget.value != null
                ? () => downloadsSideWidget.value = null
                : () {
                    commentSideWidget.value = null;
                    downloadsSideWidget.value = ShowDownloadsWidget(
                      manifest: snapshot.data,
                      downloadsSideWidget: downloadsSideWidget,
                      videoData: videoData,
                    );
                  },
            label: context.locals.download,
          ),
          VideoAction(
            icon: Icons.copy,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: videoData.url));
              BotToast.showText(text: context.locals.copiedToClipboard);
            },
            label: context.locals.copyLink,
          ),
          VideoAction(
            icon: LucideIcons.listPlus,
            onPressed: () {
              showPopoverForm(
                context: context,
                cancelText: context.locals.done,
                hideConfirm: true,
                controller: _textController,
                title: context.locals.save,
                hint: context.locals.createNew,
                onConfirm: () {
                  ref
                      .read(playlistProvider.notifier)
                      .addPlaylist(_textController.value.text);
                  _textController.value = TextEditingValue.empty;
                },
                builder: (ctx) => PlaylistPopup(
                  videoData: videoData,
                ),
              );
            },
            label: context.locals.save,
          ),
        ],
      ),
    );
  }
}
