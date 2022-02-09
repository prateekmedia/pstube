import 'package:flutter/material.dart';
import 'package:flutube/utils/utils.dart';
import 'package:libadwaita/libadwaita.dart';

Future<T?> showPopover<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
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
  String? title,
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
  assert(
    title != null || builder != null,
    "Title and Builder both can't be null",
  );
  final _formKey = key ?? GlobalKey<FormState>();
  return showPopover<T>(
    context: context,
    padding: padding,
    innerPadding: innerPadding,
    isScrollControlled: isScrollControlled,
    builder: (ctx) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (title != null) ...[
          Text(title, style: context.textTheme.headline6),
          const Divider(),
        ],
        if (builder != null) builder(ctx),
        if (controller != null)
          Padding(
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
    required this.padding,
    required this.innerPadding,
    this.isScrollable = true,
  }) : super(key: key);

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? innerPadding;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        _buildHandle(context),
        const SizedBox(height: 8),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: innerPadding,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: isScrollable
                  ? SingleChildScrollView(padding: padding, child: child)
                  : child,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHandle(BuildContext context) {
    // final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Container(
        height: 6,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
