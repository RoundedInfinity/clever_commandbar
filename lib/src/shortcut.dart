// ignore_for_file: comment_references

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The type of shortcut that should be used
/// when pressing a specific key in the [Commandbar] widget
enum CommandShortcutType {
  /// Move the focus to the next item above.
  moveUp,

  /// Move the focus to the next item below.
  moveDown,

  /// Invoke the action of the [Command].
  invoke,
}

/// {@template commandbarControlShortcuts}
/// Widget used within the [Commandbar] to control
/// the focus on items with keyboard keys.
///
/// This uses arrow keys and enter by default.
/// {@endtemplate}
class CommandbarControlShortcuts extends StatelessWidget {
  /// {@macro commandbarControlShortcuts}
  const CommandbarControlShortcuts({
    super.key,
    required this.child,
    this.shortcuts = const {
      SingleActivator(LogicalKeyboardKey.arrowUp): CommandShortcutType.moveUp,
      SingleActivator(LogicalKeyboardKey.arrowDown):
          CommandShortcutType.moveDown,
      SingleActivator(LogicalKeyboardKey.enter): CommandShortcutType.invoke,
    },
    required this.onInvoke,
  });

  /// The child of this widget.
  final Widget child;

  /// Shortcuts used to control the focus.
  final Map<ShortcutActivator, CommandShortcutType> shortcuts;

  /// Function that handles pressing one of the shortcuts.
  final void Function(CommandShortcutType shortcut) onInvoke;

  @override
  Widget build(BuildContext context) {
    final bindings = shortcuts.map(
      (key, value) => MapEntry(key, () => onInvoke(value)),
    );

    return CallbackShortcuts(
      bindings: bindings,
      child: child,
    );
  }
}
