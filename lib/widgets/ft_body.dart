import 'package:flutter/material.dart';
import 'package:flutube/controller/internet_connectivity.dart';

import 'package:flutube/utils/utils.dart';
import 'package:flutube/widgets/widgets.dart';

class FtBody extends StatelessWidget {
  const FtBody({
    Key? key,
    required this.child,
    this.expanded = true,
  }) : super(key: key);

  final Widget child;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const NetStatus(),
        if (expanded) Expanded(child: child) else child,
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
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      context.locals.networkLostShowingCachedData,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizeExpandedSection(
              expand: snapshot.data == NetworkStatus.restored,
              child: Container(
                width: double.infinity,
                color: Colors.green[600],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      context.locals.backOnline,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
