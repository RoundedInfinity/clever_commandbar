import 'package:clever_commandbar/src/provider.dart';
import 'package:flutter/widgets.dart';

/// {@template commandActions}
/// A widget that stores a [Command]s and provides them to its children.
///
/// This inherits commands from [CommandActions] widgets
/// that are above in the widget tree by default.
///
/// When an inherited command has the same name and intent as
/// the one in [commands] it gets overwritten.
///
/// This also wraps around the flutter Actions widget,
/// and adds the actions to it. (See: [Using Actions and Shortcuts](https://docs.flutter.dev/development/ui/advanced/actions_and_shortcuts))
///
/// See also:
/// - [Command] object that is used to define a command.
// ignore: comment_references
/// - [Commandbar] a widget that displays
/// all your commands and lets the user select them.
/// {@endtemplate}
class CommandActions extends StatelessWidget {
  /// {@macro commandActions}
  const CommandActions({
    super.key,
    required this.commands,
    this.inherit = true,
    this.overwrite = true,
    required this.child,
    this.dispatcher,
  });

  /// Returns the nearest [CommandProvider] in the widget tree.
  static CommandProvider of(BuildContext context) {
    return CommandProvider.of(context);
  }

  /// The child of this widget.
  final Widget child;

  /// Inherits commands from [CommandActions] widgets
  /// that are above in the widget tree.
  final bool inherit;

  /// Override inherited action, when [commands] also contains them.
  ///
  /// This should be `true` in most cases.
  final bool overwrite;

  /// The commands stored in this widget.
  ///
  /// See also:
  /// - [Command] representation of a command
  final List<Command> commands;

  /// [ActionDispatcher] used for the actions widget.
  ///
  /// See also:
  /// - [Actions.dispatcher]
  final ActionDispatcher? dispatcher;

  @override
  Widget build(BuildContext context) {
    // Get all commands of the previous
    // [CommandProvider] in the tree (if existent)
    final allInheritedCommands =
        CommandProvider.maybeOf(context)?.commands ?? {};

    // Overwrite the inherited commands
    // when the new [commands] have the same intent and name.
    final inheritedCommands = overwrite
        ? allInheritedCommands.where((element) => !commands.contains(element))
        : allInheritedCommands;

    // Add the inherited commands
    final cleanedCommands = {
      if (inherit) ...inheritedCommands,
      ...commands,
    };

    final actions = <Type, Action<Intent>>{};
    // Map the commands for the [Actions] widget.
    for (final command in cleanedCommands) {
      actions[command.intent.runtimeType] = command.action;
    }

    return CommandProvider(
      commands: cleanedCommands,
      child: Actions(
        actions: actions,
        dispatcher: dispatcher,
        child: child,
      ),
    );
  }
}

/// {@template commandAction}
/// Base class for commands.
///
/// A command contains an action, an intent and a name. It is normally used
/// for the [CommandActions] widget. Unlike standalone [Action]s and [Intent]s,
/// the command has additional properties, like a name, which can be useful to
/// display the functionality of an action.
///
/// For example a class that extends [Command] can have a description
/// and a shortcut:
///```dart
/// class CustomCommandAction extends Command {
///   const CustomCommandAction({
///     required super.intent,
///     required super.action,
///     required super.name,
///     required this.description,
///     required this.shortcut,
///   });

///   final String description;
///   final ShortcutActivator shortcut;
/// }
/// ```
///
/// This can be used to display the command to the user,
// ignore: comment_references
/// for example with [Commandbar]
/// {@endtemplate}
@immutable
class Command {
  /// {@macro commandAction}
  const Command({
    required this.intent,
    required this.action,
    required this.name,
  });

  /// The intent used for this command.
  final Intent intent;

  /// The action used by this command.
  ///
  /// The action should have [intent] as its type parameter.
  final Action action;

  /// A unique name for this action.
  final String name;
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Command && other.intent == intent && other.name == name;
  }

  @override
  int get hashCode => intent.hashCode ^ name.hashCode;

  @override
  String toString() =>
      'CommandAction(intent: $intent, action: $action, name: $name)';
}
