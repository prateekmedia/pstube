import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ant_icons/ant_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/models/models.dart';
import 'package:flutube/screens/screens.dart';
import 'package:flutube/widgets/widgets.dart';
import 'package:flutube/providers/providers.dart';

class MyHomePage extends HookConsumerWidget {
  MyHomePage({Key? key}) : super(key: key);

  final PageController _controller = PageController();

  @override
  Widget build(context, ref) {
    final _currentIndex = useState<int>(0);
    final _addDownloadController = TextEditingController();

    final mainScreens = [
      const HomeScreen(),
      const PlaylistScreen(),
      const DownloadsScreen(),
      const SettingsScreen(),
    ];

    final Map<String, List<IconData>> navItems = {
      "Home": [AntIcons.home_outline, AntIcons.home],
      "Playlist": [AntIcons.unordered_list],
      "Downloads": [Icons.download_outlined, Icons.download],
      "Settings": [AntIcons.setting_outline, AntIcons.setting],
    };

    Future addDownload() async {
      if (_addDownloadController.text.isEmpty) {
        var clipboard = await Clipboard.getData(Clipboard.kTextPlain);
        var youtubeRegEx = RegExp(
            r"^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$");
        if (clipboard != null &&
            clipboard.text != null &&
            youtubeRegEx.hasMatch(clipboard.text!)) {
          _addDownloadController.text = clipboard.text!;
        }
      }
      return showPopoverWB(
        context: context,
        onConfirm: () {
          context.back();
          if (_addDownloadController.value.text.isNotEmpty) {
            showDownloadPopup(context, videoUrl: _addDownloadController.text);
          }
        },
        hint: "https://youtube.com/watch?v=***********",
        title: "Download from video url",
        controller: _addDownloadController,
      );
    }

    clearAll() {
      final deleteFromStorage = ValueNotifier<bool>(false);
      showPopoverWB(
        context: context,
        builder: (ctx) => ValueListenableBuilder<bool>(
            valueListenable: deleteFromStorage,
            builder: (_, value, ___) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clear all items from download list?',
                      style: context.textTheme.bodyText1),
                  CheckboxListTile(
                    value: value,
                    onChanged: (val) => deleteFromStorage.value = val!,
                    title: const Text("Also delete them from storage"),
                  ),
                ],
              );
            }),
        onConfirm: () {
          final downloadListUtils = ref.read(downloadListProvider);
          for (DownloadItem item in downloadListUtils.downloadList) {
            if (File(item.queryVideo.path + item.queryVideo.name)
                    .existsSync() &&
                deleteFromStorage.value) {
              File(item.queryVideo.path + item.queryVideo.name).deleteSync();
            }
          }
          downloadListUtils.clearAll();
          context.back();
        },
        confirmText: "Yes",
        title: "Confirm!",
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            floating: true,
            elevation: 1,
            backgroundColor: context.theme.canvasColor,
            title: Text(myApp.name),
            actions: [
              buildSearchButton(context),
              if (!context.isMobile)
                IconButton(
                  onPressed: addDownload,
                  icon: const Icon(Icons.add),
                ),
              if (_currentIndex.value == 3)
                IconButton(
                  icon: const Icon(AntIcons.delete_outline),
                  onPressed: clearAll,
                  tooltip: "Clear all",
                ),
              if (_currentIndex.value == 4)
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: const Text('Reset default'),
                        onTap: () => resetDefaults(ref),
                      )
                    ];
                  },
                ),
              const SizedBox(width: 10),
            ],
          )
        ],
        body: Row(
          children: [
            if (!context.isMobile)
              NavigationRail(
                backgroundColor: context.theme.canvasColor,
                elevation: 8,
                destinations: [
                  for (var item in navItems.entries)
                    NavigationRailDestination(
                      label: Text(item.key, style: context.textTheme.bodyText1),
                      icon: Icon(item.value[0]),
                      selectedIcon: Icon(
                        item.value.length == 2 ? item.value[1] : item.value[0],
                        color: context.textTheme.bodyText1!.color,
                      ),
                    ),
                ],
                selectedIndex: _currentIndex.value,
                onDestinationSelected: (index) => _controller.jumpToPage(index),
              ),
            Flexible(
              child: FtBody(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: mainScreens.length,
                  itemBuilder: (context, index) => mainScreens[index],
                  onPageChanged: (index) => _currentIndex.value = index,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: context.isMobile,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withAlpha(120),
                blurRadius: 1,
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: context.theme.canvasColor,
            selectedItemColor: context.textTheme.bodyText1!.color,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: List.generate(
              navItems.entries.length + 1,
              (index) {
                if (index != 2) {
                  var item =
                      navItems.entries.elementAt(index < 2 ? index : index - 1);
                  return BottomNavigationBarItem(
                    label: item.key,
                    icon: Icon(item.value[0], size: 20),
                    activeIcon: item.value.length > 1
                        ? Icon(item.value[1], size: 20)
                        : null,
                  );
                } else {
                  return const BottomNavigationBarItem(
                    label: "Add",
                    icon: Icon(Icons.add, size: 20),
                  );
                }
              },
            ),
            currentIndex: _currentIndex.value < 2
                ? _currentIndex.value
                : _currentIndex.value + 1,
            onTap: (index) => index != 2
                ? _controller.jumpToPage(index < 2 ? index : index - 1)
                : addDownload(),
          ),
        ),
      ),
    );
  }
}
