import 'package:flutter/material.dart';
import 'package:pstube/foundation/controller/internet_connectivity.dart';
import 'package:pstube/foundation/extensions/extensions.dart';

import 'package:pstube/ui/widgets/widgets.dart';

class SFBody extends StatelessWidget {
  const SFBody({
    super.key,
    required this.child,
    this.expanded = true,
  });

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
    super.key,
  });

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
                          .bodyLarge!
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
                          .bodyLarge!
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
