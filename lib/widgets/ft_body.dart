import 'package:flutter/material.dart';
import 'package:flutube/controller/internet_connectivity.dart';

import 'widgets.dart';

class FtBody extends StatelessWidget {
  final Widget child;
  final bool expanded;

  const FtBody({
    Key? key,
    required this.child,
    this.expanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const NetStatus(),
        expanded ? Expanded(child: child) : child,
      ],
    );
  }
}

class NetStatus extends StatelessWidget {
  const NetStatus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: true,
      stream: InternetConnectivity.networkStream,
      builder: (context, snapshot) {
        return Stack(
          children: [
            SizeExpandedSection(
              expand: snapshot.data == NetworkStatus.offline,
              child: Container(
                width: double.infinity,
                color: Colors.redAccent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    'Network Lost. Showing cached data.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.white),
                  )),
                ),
              ),
            ),
            SizeExpandedSection(
              expand: snapshot.data == NetworkStatus.restored,
              child: Container(
                width: double.infinity,
                color: Colors.green[600],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    'Back online',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.white),
                  )),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
