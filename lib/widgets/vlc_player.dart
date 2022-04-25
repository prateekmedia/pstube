import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:pstube/utils/utils.dart';

class VlcPlayer extends StatefulWidget {
  const VlcPlayer({
    Key? key,
    required this.url,
    required this.resolutions,
  }) : super(key: key);

  final String url;
  final Map<String, String> resolutions;

  @override
  State<VlcPlayer> createState() => _VlcPlayerState();
}

class _VlcPlayerState extends State<VlcPlayer> with WidgetsBindingObserver {
  Player player = Player(id: 0);
  CurrentState current = CurrentState();
  PositionState position = PositionState();
  PlaybackState playback = PlaybackState();
  GeneralState general = GeneralState();
  VideoDimensions videoDimensions = const VideoDimensions(0, 0);
  late List<Media> medias = <Media>[Media.network(widget.url)];
  List<Device> devices = <Device>[];
  double bufferingProgress = 0;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      player.currentStream.listen((current) {
        setState(() => this.current = current);
      });
      player.positionStream.listen((position) {
        setState(() => this.position = position);
      });
      player.playbackStream.listen((playback) {
        setState(() => this.playback = playback);
      });
      player.generalStream.listen((general) {
        setState(() => this.general = general);
      });
      player.videoDimensionsStream.listen((videoDimensions) {
        setState(() => this.videoDimensions = videoDimensions);
      });
      player.bufferingProgressStream.listen(
        (bufferingProgress) {
          setState(() => this.bufferingProgress = bufferingProgress);
        },
      );
      player.open(Playlist(medias: medias));
      player.errorStream.listen((event) {
        debugPrint('⚠️⚠️⚠️ libVLC error received.');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    player.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    devices = Devices.all;
    final equalizer = Equalizer.createMode(EqualizerMode.live)
      ..setPreAmp(10)
      ..setBandAmp(31.25, 10);
    player.setEqualizer(equalizer);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      // fit: BoxFit.fitHeight,
      player: player,
      height: context.isMobile ? 320 : 480,
      volumeThumbColor: Colors.blue,
      volumeActiveColor: Colors.blue,
      playlistLength: medias.length,
    );
  }
}
