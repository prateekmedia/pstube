import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutube/screens/custom_license_screen.dart';

import 'package:flutube/utils/utils.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: context.backLeading(),
        title: const Text("About"),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.memory(base64Decode(myApp.logoBase64)),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          myApp.name,
                          style: context.textTheme.headline6!.copyWith(fontWeight: FontWeight.w600),
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
                              child: const Text('Star on github'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => context.pushPage(const CustomLicensePage()),
                              child: const Text('Licenses'),
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    'Developer',
                    style: context.textTheme.headline6!.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                for (var ftinfo in developerInfos) ...[
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.memory(base64Decode(ftinfo.logoBase64)),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ftinfo.name,
                                style: context.textTheme.headline6!.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Divider(height: 6),
                              Text(
                                ftinfo.description,
                                style: context.textTheme.bodyText2,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: ftinfo.url.launchIt,
                                child: const Text('Follow on github'),
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
