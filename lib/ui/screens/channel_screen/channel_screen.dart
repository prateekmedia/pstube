import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pstube/foundation/extensions/extensions.dart';
import 'package:pstube/ui/screens/channel_screen/state/channel_notifier.dart';
import 'package:pstube/ui/screens/channel_screen/tabs/tabs.dart';
import 'package:pstube/ui/widgets/widgets.dart' hide ChannelDetails;

class ChannelScreen extends HookConsumerWidget {
  const ChannelScreen({super.key, required this.channelId});
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMounted = useIsMounted();
    final _pageController = usePageController();
    final _currentIndex = useState<int>(0);
    final _tabs = <String, IconData>{
      context.locals.home: LucideIcons.home,
      context.locals.videos: LucideIcons.video,
      context.locals.about: LucideIcons.info,
    };
    final controller = useScrollController();
    final channelP = ref.watch(channelProvider);
    final channelData = channelP.channelData;
    final channelInfo = channelP.channelInfo;
    final videos = channelP.videos;

    Future<void> loadChannelData() async {
      await ref.read(channelProvider).loadChannelData(channelId);
    }

    Future<void> loadAboutPage() async {
      await ref.read(channelProvider).loadAboutPage(channelId);
    }

    Future<dynamic> _getMoreData() async {
      if (!isMounted() ||
          controller.position.pixels != controller.position.maxScrollExtent) {
        return;
      }

      await ref.read(channelProvider).videosNextPage();
    }

    useEffect(
      () {
        loadChannelData();
        loadAboutPage();

        controller.addListener(_getMoreData);
        return () => controller.removeListener(_getMoreData);
      },
      [controller],
    );

    return AdwScaffold(
      actions: AdwActions().bitsdojo,
      start: [
        context.backLeading(),
      ],
      title: channelData != null
          ? Text(
              channelData.name,
            )
          : null,
      viewSwitcher: AdwViewSwitcher(
        currentIndex: _currentIndex.value,
        onViewChanged: _pageController.jumpToPage,
        tabs: _tabs.entries
            .map((e) => ViewSwitcherData(title: e.key, icon: e.value))
            .toList(),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) => _currentIndex.value = idx,
        // These are the contents of the tab views, below the tabs.
        children: _tabs.keys.toList().asMap().entries.map(
          (MapEntry<int, String> entry) {
            ScrollController? scrollController;
            late Widget tab;
            late bool isVisible;

            switch (entry.key) {
              case 0:
                tab = ChannelHomeTab(
                  channel: channelData,
                );
                isVisible = channelData != null;
                break;
              case 1:
                scrollController = controller;
                tab = const ChannelVideosTab();
                isVisible = videos != null;
                break;
              case 2:
                tab = const ChannelAboutTab();
                isVisible = channelInfo != null;
                break;
              default:
            }

            return _KeepAliveTab(
              controller: scrollController,
              isVisible: isVisible,
              tab: tab,
            );
          },
        ).toList(),
      ),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({
    required this.isVisible,
    required this.tab,
    this.controller,
  });

  final bool isVisible;
  final Widget tab;
  final ScrollController? controller;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: AdwClamp.scrollable(
        controller: widget.controller,
        maximumSize: 1200,
        child: Visibility(
          visible: widget.isVisible,
          replacement: getCircularProgressIndicator(),
          child: widget.tab,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
