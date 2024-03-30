import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/data/enums/enums.dart';
import 'package:pstube/data/models/video_data.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/foundation/services.dart';
import 'package:pstube/states/states.dart';
import 'package:pstube/ui/screens/video_screen/src/export.dart';
import 'package:pstube/ui/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';

class VideoActions extends HookConsumerWidget {
  const VideoActions({
    required this.sideWidget,
    required this.videoData,
    required this.sideType,
    required this.emptySide,
    required this.isCinemaMode,
    super.key,
  });

  final ValueNotifier<bool> isCinemaMode;
  final VideoData videoData;
  final ValueNotifier<Widget?> sideWidget;
  final ValueNotifier<SideType?> sideType;
  final VoidCallback emptySide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedList = ref.watch(likedListProvider);
    final isLiked = useState<bool>(
      likedList.likedVideoList.contains(videoData.id.url),
    );
    final textController = TextEditingController();

    void updateLike() {
      isLiked.value = !isLiked.value;

      if (isLiked.value) {
        likedList.addVideo(videoData.id.url);
      } else {
        likedList.removeVideo(videoData.id.url);
      }
    }

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VideoAction(
                icon: isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
                onPressed: updateLike,
                label: videoData.likes != null && videoData.likes! >= 0
                    ? videoData.likes!.formatNumber
                    : context.locals.like,
              ),
              if (!context.isMobile)
                VideoAction(
                  icon: Icons.theaters_outlined,
                  onPressed: () {
                    isCinemaMode.value = !isCinemaMode.value;
                    MyPrefs().prefs.setBool('isCinema', isCinemaMode.value);
                  },
                  label: context.locals.cinema,
                ),
              VideoAction(
                icon: Icons.share_outlined,
                onPressed: () => Share.share(
                  videoData.id.url,
                ),
                label: context.locals.share,
              ),
              VideoAction(
                icon: Icons.download_outlined,
                onPressed: sideType.value == SideType.download
                    ? emptySide
                    : () {
                        sideType.value = SideType.download;
                        sideWidget.value = VideoPopupWrapper(
                          onClose: emptySide,
                          title: context.locals.downloadQuality,
                          child: DownloadsWidget(
                            video: videoData,
                            onClose: emptySide,
                          ),
                        );
                      },
                label: context.locals.download,
              ),
              VideoAction(
                icon: Icons.copy,
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: videoData.id.url,
                    ),
                  );
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
                    controller: textController,
                    title: context.locals.save,
                    hint: context.locals.createNew,
                    onConfirm: () {
                      ref
                          .read(playlistProvider.notifier)
                          .addPlaylist(textController.value.text);
                      textController.value = TextEditingValue.empty;
                    },
                    builder: (ctx) => PlaylistPopup(
                      videoData: videoData,
                    ),
                  );
                },
                label: context.locals.save,
              ),
              VideoAction(
                icon: LucideIcons.video,
                onPressed: videoData.relatedStreams == null
                    ? null
                    : sideType.value == SideType.related
                        ? emptySide
                        : () {
                            sideType.value = SideType.related;
                            sideWidget.value = VideoPopupWrapper(
                              onClose: emptySide,
                              title: 'Related Video',
                              child: Column(
                                children: [
                                  for (final streamItem
                                      in videoData.relatedStreams!)
                                    PSVideo(
                                      videoData: VideoData.fromStreamItem(
                                        streamItem,
                                      ),
                                      isRelated: true,
                                      onTap: () {
                                        ref.read(videosProvider).addVideoData(
                                              VideoData.fromStreamItem(
                                                streamItem,
                                              ),
                                              loadMore: true,
                                            );
                                        emptySide();
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                label: 'Related',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoAction extends StatelessWidget {
  const VideoAction({
    required this.icon,
    required this.label,
    super.key,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          AdwButton.circular(
            size: 40,
            onPressed: onPressed,
            child: Icon(icon),
          ),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}
