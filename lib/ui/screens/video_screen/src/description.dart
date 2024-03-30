import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/video_screen/src/export.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher_string.dart';

class DescriptionWidget extends StatelessWidget {
  const DescriptionWidget({
    required this.video,
    super.key,
    this.isInsidePopup = true,
  });

  final bool isInsidePopup;
  final VideoData video;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      controller: ScrollController(),
      padding: const EdgeInsets.all(15),
      children: [
        Text(
          context.locals.description,
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isInsidePopup ? 16 : 18,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DescriptionInfoWidget(
              title: (video.views ?? 0).addCommas,
              body: context.locals.views,
            ),
            DescriptionInfoWidget(
              title: video.uploadDate != null
                  ? DateTime.tryParse(video.uploadDate!) != null
                      ? timeago.format(DateTime.parse(video.uploadDate!))
                      : video.uploadDate!
                  : '',
              body: context.locals.uploadDate,
            ),
          ],
        ),
        const SizedBox(height: 15),
        if ((video.description ?? '').isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Html(
              data: video.description!.replaceAll('\n', '<br>'),
              onLinkTap: (link, _, __) {
                if (link != null) {
                  launchUrlString(link);
                  return;
                }
                debugPrint('Link is Empty');
              },
            ),
          ),
      ],
    );
  }
}
