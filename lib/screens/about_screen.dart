import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:flutube/models/ft_info.dart';
import 'package:flutube/utils/utils.dart';
import 'package:flutube/screens/screens.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: context.backLeading(),
        title: Text(context.locals.about),
      ),
      body: MasonryGridView(
        gridDelegate: SliverMasonryGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.width > 750 ? 2 : 1,
        ),
        mainAxisSpacing: 6,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        crossAxisSpacing: 10,
        children: [
          Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myApp.imageWidget,
                Flexible(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          myApp.name,
                          style: context.textTheme.headline3,
                        ),
                        const Divider(height: 6),
                        Text(
                          myApp.description,
                          style: context.textTheme.bodyText2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: myApp.url.launchIt,
                              child: Text(
                                context.locals.github,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  context.pushPage(const CustomLicensePage()),
                              child: Text(
                                context.locals.licenses,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(context.locals.developer,
                      style: context.textTheme.headline4),
                ),
                for (var ftinfo in developerInfos) ...[
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ftinfo.imageWidget,
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ftinfo.name,
                                style: context.textTheme.headline3,
                              ),
                              const Divider(height: 6),
                              Text(
                                ftinfo.description,
                                style: context.textTheme.bodyText2,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: ftinfo.url.launchIt,
                                child: Text(
                                  context.locals.github,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
