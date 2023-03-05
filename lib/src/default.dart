import 'package:clever_commandbar/clever_commandbar.dart';
import 'package:flutter/material.dart';

/// {@template simpleCommand}
/// A simple command that contains a name, description and shortcut.
///
/// This command can be displayed with the
/// default commandbar (See [showDefaultCommandbar]).
///
/// [shortcut] does not actually implement a shortcut.
/// It is just a string representation of which buttons to press.
/// {@endtemplate}
class SimpleCommand extends Command {
  /// {@macro simpleCommand}
  const SimpleCommand({
    required super.intent,
    required super.action,
    required super.name,
    this.description,
    this.shortcut,
  });

  /// A description of this shortcut
  /// (e.g. "Create an new document in this folder")
  final String? description;

  /// Which shortcut is used for this command
  ///
  /// This does not actually implement a shortcut.
  /// It is just a string representation of which buttons to press.
  /// For example: `"Ctrl + S"`.
  final String? shortcut;
}

/// Shows a commandbar with a default material design.
///
/// This uses [CommandProvider.of] to get the commands.
Future<void> showDefaultCommandbar(BuildContext actionContext) async {
  final commands = CommandActions.of(actionContext).commands;

  await showGeneralDialog(
    context: actionContext,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.05, 0.7, 0.1, 1),
          reverseCurve: const Cubic(0.3, 0, 0.8, 0.15).flipped,
        ),
      );
      return ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: scaleAnimation,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Commandbar(
        commands: commands,
        actionsContext: actionContext,
        searchBuilder: (context, onSearch) {
          return FocusScope(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: TextField(
                autofocus: true,
                onChanged: onSearch,
              ),
            ),
          );
        },
        itemBuilder: (_, details) {
          return _SearchResultTile(
            command: details.command,
            actionsContext: actionContext,
            isFocused: details.isFocused,
          );
        },
        emptyBuilder: (context, query) {
          return Flexible(
            child: SingleChildScrollView(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No results for "$query"',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.command,
    required this.actionsContext,
    required this.isFocused,
  });

  final Command command;
  final BuildContext actionsContext;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simpleCommand =
        command is SimpleCommand ? command as SimpleCommand : null;

    final subtitle =
        simpleCommand != null && simpleCommand.description!.isNotEmpty
            ? Text(simpleCommand.description!)
            : null;

    final trailing = simpleCommand != null && simpleCommand.shortcut!.isNotEmpty
        ? Text(simpleCommand.shortcut!)
        : null;

    return ListTile(
      title: Text(command.name),
      subtitle: subtitle,
      trailing: trailing,
      key: ValueKey(command),
      selected: isFocused,
      selectedTileColor: theme.colorScheme.secondary.withOpacity(0.1),
      onTap: () async {
        Navigator.pop(context);
        Actions.invoke(
          actionsContext,
          command.intent,
        );
      },
    );
  }
}
