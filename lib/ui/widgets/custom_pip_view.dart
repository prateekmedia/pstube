import 'package:flutter/material.dart';
import 'package:pip_view/pip_view.dart';

void dismissKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

class CustomPIPView extends StatefulWidget {
  const CustomPIPView({
    super.key,
    required this.builder,
    this.initialCorner = PIPViewCorner.topRight,
    this.floatingWidth,
    this.floatingHeight,
    this.avoidKeyboard = true,
  });
  final PIPViewCorner initialCorner;
  final double? floatingWidth;
  final double? floatingHeight;
  final bool avoidKeyboard;

  final Widget Function(
    BuildContext context,
    bool isFloating,
  ) builder;

  @override
  CustomPIPViewState createState() => CustomPIPViewState();

  static CustomPIPViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<CustomPIPViewState>();
  }
}

class CustomPIPViewState extends State<CustomPIPView>
    with TickerProviderStateMixin {
  Widget? _topWidget;
  bool isFloating = false;

  void presentTop(Widget widget) {
    dismissKeyboard(context);
    setState(() => _topWidget = widget);
    setState(() => isFloating = true);
  }

  void stopFloating() {
    dismissKeyboard(context);
    setState(() => isFloating = false);
  }

  @override
  Widget build(BuildContext context) {
    return RawPIPView(
      avoidKeyboard: widget.avoidKeyboard,
      bottomWidget: isFloating ? null : widget.builder(context, isFloating),
      onTapTopWidget: isFloating ? stopFloating : null,
      topWidget: _topWidget != null
          ? IgnorePointer(
              ignoring: !isFloating,
              child: _topWidget,
            )
          : null,
      floatingHeight: widget.floatingHeight,
      floatingWidth: widget.floatingWidth,
      initialCorner: widget.initialCorner,
    );
  }
}
