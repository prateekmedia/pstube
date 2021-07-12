import 'package:flutter/material.dart';
import 'package:flutube/models/models.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'widgets.dart';
import '../utils/utils.dart';

class FTVideo extends StatelessWidget {
  final Video video;

  const FTVideo({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(child: Placeholder()),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment(0.94, 0.94),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    color: Colors.black,
                    child: Text("43:36"),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  MdiIcons.progressDownload,
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        margin: EdgeInsets.only(right: 2),
                        child: Text(
                          video.owner,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              iconWithLabel(
                icon: MdiIcons.eye,
                label: video.views.formatNumber,
              ),
              iconWithLabel(
                icon: MdiIcons.timer,
                label: timeago.format(video.date),
              ),
            ],
          )
        ],
      ),
    );
  }
}
