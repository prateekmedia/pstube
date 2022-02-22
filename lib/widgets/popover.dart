import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:sftube/utils/utils.dart';

Future<T?> showPopover<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  required String title,
  bool isScrollControlled = true,
  EdgeInsets? padding = const EdgeInsets.symmetric(horizontal: 8),
  EdgeInsets? innerPadding = const EdgeInsets.symmetric(horizontal: 18),
  bool isScrollable = true,
}) {
  return showModalBottomSheet<T>(
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    context: context,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (ctx) => Popover(
      title: title,
      isScrollable: isScrollable,
      innerPadding: innerPadding,
      padding: padding,
      child: builder(ctx),
    ),
  );
}

Future<T?> showPopoverWB<T>({
  required BuildContext context,
  GlobalKey<FormState>? key,
  required String title,
  Widget Function(BuildContext)? builder,
  required void Function()? onConfirm,
  TextEditingController? controller,
  String hint = '',
  void Function()? onCancel,
  String? Function(String?)? validator,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8),
  EdgeInsets innerPadding = const EdgeInsets.symmetric(horizontal: 18),
  String? cancelText,
  String? confirmText,
  bool isScrollControlled = true,
  bool isScrollable = true,
  bool disableOnNoConfirm = false,
}) {
  final _formKey = key ?? GlobalKey<FormState>();
  return showPopover<T>(
    context: context,
    title: title,
    padding: padding,
    innerPadding: innerPadding,
    isScrollControlled: isScrollControlled,
    builder: (ctx) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (builder != null) builder(ctx),
        if (controller != null)
          Container(
            constraints: BoxConstraints.loose(const Size(500, 36)),
            padding: padding,
            child: Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,
                controller: controller,
                onFieldSubmitted: (val) {
                  onConfirm?.call();
                },
                style: context.textTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: hint,
                  constraints: BoxConstraints.loose(const Size(500, 40)),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AdwButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(cancelText ?? context.locals.cancel),
              onPressed: () {
                context.back();
                if (onCancel != null) onCancel();
              },
            ),
            AdwButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              onPressed: disableOnNoConfirm &&
                      controller != null &&
                      controller.value.text.isEmpty
                  ? null
                  : onConfirm,
              child: Text(confirmText ?? context.locals.ok),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

class Popover extends StatelessWidget {
  const Popover({
    Key? key,
    required this.child,
    required this.title,
    required this.padding,
    required this.innerPadding,
    this.isScrollable = true,
  }) : super(key: key);

  final Widget child;
  final String title;
  final EdgeInsets? padding;
  final EdgeInsets? innerPadding;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdwHeaderBar(
          actions: AdwActions(onClose: Navigator.of(context).pop),
          title: Text(title, style: context.textTheme.headline5),
        ),
        Flexible(
          child: Container(
            padding: innerPadding,
            decoration: BoxDecoration(
              color: theme.canvasColor,
            ),
            child: isScrollable
                ? SingleChildScrollView(padding: padding, child: child)
                : child,
          ),
        ),
      ],
    );
  }
}
