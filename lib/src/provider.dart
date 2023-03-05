import 'package:clever_commandbar/clever_commandbar.dart';
import 'package:flutter/widgets.dart';

/// {@template command_provider}
/// Provides a list of [Command]s to its children.
///
/// This is a part of the [CommandActions] widget,
/// which you should normally use instead of this.
///
/// See also:
/// - [Commandbar] to use the commandbar.
/// {@endtemplate}
class CommandProvider extends InheritedWidget {
  /// {@macro command_provider}
  const CommandProvider({
    super.key,
    required this.commands,
    required super.child,
  });

  /// A list of commands used for the commandbar.
  final Set<Command> commands;

  /// Closest instance of this class that encloses the given context, if any.
  static CommandProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CommandProvider>();
  }

  /// Closest instance of this class that encloses the given context.
  static CommandProvider of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No CommandProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(CommandProvider oldWidget) =>
      commands != oldWidget.commands;
}
