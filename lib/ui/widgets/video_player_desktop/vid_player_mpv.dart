import 'dart:async';

import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_core_video/media_kit_core_video.dart';



class VideoPlayerMpv extends StatefulWidget {
  const VideoPlayerMpv({
    super.key,
    required this.url,
    required this.audstreams,
    required this.resolutions,
    required this.isCinemaMode,
    required this.handw,
  });

  final ValueNotifier<bool> isCinemaMode;
  final String url;
  final Map<int, String> audstreams;
  final Map<String, String> resolutions;
  final Map<int, int> handw;

  @override
  EventDesktopPlayerState createState() => EventDesktopPlayerState();

}

//begin seekbar
class SeekBar extends StatefulWidget {
  final Player player;
  const SeekBar({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  double volume = 0.5;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    isPlaying = widget.player.state.isPlaying;
    position = widget.player.state.position;
    duration = widget.player.state.duration;
    volume = widget.player.state.volume;
    
    subscriptions.addAll(
      [
        widget.player.streams.isPlaying.listen((event) {
          setState(() {
            isPlaying = event;
          });
        }),
        widget.player.streams.position.listen((event) {
          setState(() {
            position = event;
          });
        }),
        widget.player.streams.duration.listen((event) {
          setState(() {
            duration = event;
          });
        }),
        widget.player.streams.volume.listen((event) {
          setState(() {
            volume = event;
          });
        }),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final s in subscriptions) {
      s.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: widget.player.playOrPause,
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            color: Theme.of(context).toggleableActiveColor,
            iconSize: 36.0,
          ),
          Text(position.toString().substring(2, 7)),
          Expanded(
            child: Slider(
              min: 0.0,
              max: duration.inMilliseconds.toDouble(),
              value: position.inMilliseconds.toDouble().clamp(
                    0,
                    duration.inMilliseconds.toDouble(),
                  ),
              onChanged: (e) {
                setState(() {
                  position = Duration(milliseconds: e ~/ 1);
                });
              },
              onChangeEnd: (e) {
                widget.player.seek(Duration(milliseconds: e ~/ 1));
              },
            ),
          ),
          Text(duration.toString().substring(2, 7)),
          //IconButton(
          //  onPressed: ,
          //  icon: Icon(
          //    Icons.volume = 0.0 ? Icons.volume_off : Icons.volume_up,,
          //  ),
          //  color: Theme.of(context).primaryColor,
          //  iconSize: 36.0,
          //),
        ],
      )
      
    );
  }
}
//end seekbar

class EventDesktopPlayerState extends State<VideoPlayerMpv> {

      // Create a [Player] instance from `package:media_kit`.
  final Player player = Player();
  // Reference to the [VideoController] instance from `package:media_kit_core_video`.
  VideoController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller = await VideoController.create(player.handle);
      setState(() {});
    });
  }

  bool _isDownloading = false;
  bool Triggered = false;
  bool isVisible = false;
  bool Asp = false;
  String? url;
  late List<Media> medias = <Media>[Media(widget.url)];
  late Map<int, String> aud = widget.audstreams;
  late Map<String, String> res = widget.resolutions;
  late Map<int, int> aspect = widget.handw;
  late double aspectvalue;
  

    void _downloadAction(String vid) async {
      // default to using the highest bitrate, probably a better way of doing this
      // TODO probably want a way to override this
      late var bitrate=0;
      late var audurl;

      aud.forEach((k,v){
      if(k>bitrate) {
        audurl = v;
        bitrate = k;
      }
      });

      //load audio track should get put behind an if statment
      if (player?.platform is libmpvPlayer) {
        await (player?.platform as libmpvPlayer?)?.setProperty("audio-files", audurl);
      }

      //await player.open(Playlist(medias)); //load url with both audio and video
      await player.open(Playlist([Media(vid)])); // load video only url

      setState(() => _isDownloading = false);
      setState(() => Triggered = true);
      setState(() => Asp = true);

      var aspectlist = aspect.entries.toList();
      var h = aspectlist[0].key;
      var w = aspectlist[0].value;

      aspectvalue = h / w;
    }

    @override
  void dispose() {
    Future.microtask(() async {
      await controller?.dispose();
      await player.dispose();
    });;
    super.dispose();
  }
    @override
  Widget build(BuildContext context) {

    return Material(
      color: Color.fromARGB(0, 0, 0, 0),
      child: AspectRatio(
        aspectRatio: Asp != true ? 5 / 1 : aspectvalue,
        child: Triggered == true
            ? Stack(
              //alignment: Alignment.bottomCenter,
                children: [
                    Center(child: Video(controller: controller)),
                    if(isVisible)
                    Container(
                      child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        color: Color.fromARGB(125, 0, 0, 0),
                        child: SeekBar(player: player),
                      )
                    )
                  ),
                  MouseRegion(
                    onEnter: (PointerEvent details)=>setState(()=>isVisible = true),
                    onExit: (PointerEvent details)=>setState(()=>isVisible = false),
                    opaque: false,
                  )
                ]
              )
            : //Stack(
                //children: [
                  Center(
                    child: //OutlinedButton.icon(
                      //style: OutlinedButton.styleFrom(
                      //  backgroundColor: Theme.of(context).colorScheme.surface,
                      //),
                      //icon: //_isDownloading
                          //? const SizedBox(
                          //    width: 24,
                          //    height: 24,
                          //    child: CircularProgressIndicator.adaptive(
                          //        strokeWidth: 2),
                          //  )
                          //: 

                          // for showing audio bitrate

                          //SimpleDialog(
                          //    title: Text('Resolutions'),
                          //    children: aud.entries.map((entry) {
                          //      var w = var(entry.key);
                          //      //_downloadAction(entry.value); //sends the URL
                          //      return w;
                          //    }).toList()),  

                          SimpleDialog(
                              title: Text('Resolutions'),
                              children: res.entries.map((entry) {
                                var w = Text(entry.key.toString());
                                _downloadAction(entry.value); //sends the URL
                                return w;
                              }).toList()), //TODO
                          
                          //const Icon(Icons.download_outlined),
                            //label: Text("test"),
                            //onPressed: _downloadAction,
                    ),
                  )
                //],
    );
      //);

  }
}