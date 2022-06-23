import 'package:custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:pstube/data/extensions/extensions.dart';
import 'package:pstube/data/models/models.dart';
import 'package:pstube/ui/screens/video_screen/src/export.dart';

class DescriptionWidget extends StatelessWidget {
  const DescriptionWidget({
    super.key,
    required this.video,
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
          style: context.textTheme.bodyText1!.copyWith(
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
              title: video.uploadDate ?? '',
              body: context.locals.uploadDate,
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: CustomText(
            video.description ?? '',
            onTap: (Type type, link) => link.launchIt(),
            definitions: const [
              TextDefinition(matcher: UrlMatcher()),
              TextDefinition(matcher: EmailMatcher()),
            ],
            matchStyle: const TextStyle(color: Colors.lightBlue),
            // `tapStyle` is not used if both `onTap` and `onLongPress`
            // are null or not set.
            tapStyle: const TextStyle(color: Colors.yellow),
            style: TextStyle(fontSize: isInsidePopup ? 16 : 17),
          ),
        ),
      ],
    );
  }
}
