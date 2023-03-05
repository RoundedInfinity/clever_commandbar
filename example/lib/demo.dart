import 'package:clever_commandbar/clever_commandbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Commands used by the app
    final commands = [
      // This command invokes the SearchForAction when activated.
      //
      // The SearchForCommand class defines its name and description.
      SearchForCommand(action: SearchForAction(context)),

      // These commands do nothing, but you can still test the search with them.
      PlaceholderCommand(
        name: 'Do Nothing',
        action: DoNothingAction(),
        shortcut: const SingleActivator(LogicalKeyboardKey.keyV, alt: true),
      ),
      PlaceholderCommand(
        name: 'Create Something',
        action: DoNothingAction(),
        shortcut: const SingleActivator(LogicalKeyboardKey.keyN),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandbar Demo'),
      ),
      body: Shortcuts(
        shortcuts: {
          // Assign the shortcuts defined in the commands to the shortcuts widget.
          for (final command in commands) command.shortcut: command.intent
        },
        // The actions are stored in the CommandActions widget
        // it also wraps around the flutter Actions widget,
        // which means the shortcuts are now working!
        child: CommandActions(
          commands: commands,
          child: Builder(
            builder: (context) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Focus(
                      autofocus: true,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Use Ctrl + F to invoke the search for action',
                            ),
                            FilledButton(
                              onPressed: () {
                                showCommandbar(context);
                              },
                              child: const Text('Show commandbar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // These command actions create a subsection in your app,
                  // which means you can use different commands and assign
                  // new actions to existing commands
                  CommandActions(
                    commands: [
                      // This overrides the SearchFor command with another action.
                      SearchForCommand(
                        action: SearchForExtraAction(context),
                        description: 'This command has other functionality now',
                      ),
                      // This adds a new action
                      PlaceholderCommand(
                        name: 'A new Command',
                        description:
                            'This command is only available in this subsection',
                        action: DoNothingAction(),
                        shortcut:
                            const SingleActivator(LogicalKeyboardKey.keyW),
                      ),
                    ],
                    // The actions from the first CommandActions Widget will still be available here.
                    inherit: true,
                    child: Builder(
                      builder: (context) {
                        return Container(
                          width: 500,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Focus the text field and then try to use Ctrl + F',
                                ),
                                const TextField(),
                                FilledButton(
                                  onPressed: () {
                                    showCommandbar(context);
                                  },
                                  child: const Text(
                                    'Show commandbar with other actions',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Show a custom commandbar
void showCommandbar(BuildContext actionsContext) {
  // Get the commands form the [CommandActions] widget.
  final commands = CommandActions.of(actionsContext).commands;

  showDialog(
    context: actionsContext,
    builder: (context) {
      return Commandbar(
        commands: commands,
        commandbarTheme: CommandbarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        search: (query, choices) {
          // A very simple custom search algorithm
          return choices
              .where((element) => element.name.toLowerCase().contains(query))
              .toList();
        },
        // Use the context that contains the [CommandActions] widget.
        actionsContext: actionsContext,

        // This builds the individual items in the commandbar
        itemBuilder: (context, details) {
          // Cast your action to your custom type.
          final action = details.command as CustomCommandAction;

          return ListTile(
            selected: details.isFocused,
            title: Text(action.name),
            subtitle: Text(action.description),
            trailing: Text(action.shortcut.debugDescribeKeys()),
            onTap: () {
              // Invoke the action that is found in the actionsContext
              Actions.invoke(actionsContext, details.command.intent);
            },
          );
        },
        searchBuilder: (context, onSearch) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextField(
              autofocus: true,
              // onSearch should be used for the onChanged parameter of a text field.
              onChanged: onSearch,
            ),
          );
        },
        emptyBuilder: (context, query) {
          return Text('Nothing found for "$query"');
        },
      );
    },
  );
}

/// Create a command action with additional properties by extending [Command]
class CustomCommandAction extends Command {
  const CustomCommandAction({
    required super.intent,
    required super.action,
    required super.name,
    required this.description,
    required this.shortcut,
  });

  final String description;
  final ShortcutActivator shortcut;
}

class PlaceholderCommand extends CustomCommandAction {
  const PlaceholderCommand({
    super.intent = const DoNothingIntent(),
    required super.name,
    required super.action,
    super.description = 'This command does nothing',
    required super.shortcut,
  });
}

class SearchForCommand extends CustomCommandAction {
  const SearchForCommand({
    super.intent = const SearchForIntent(),
    super.name = 'Search For',
    required super.action,
    super.description = 'Search for something...',
    super.shortcut =
        const SingleActivator(LogicalKeyboardKey.keyF, control: true),
  });
}

class SearchForIntent extends Intent {
  const SearchForIntent();
}

class SearchForAction extends Action<SearchForIntent> {
  SearchForAction(this.context);

  final BuildContext context;

  @override
  void invoke(covariant SearchForIntent intent) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search for'),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
        ),
      );
}

class SearchForExtraAction extends Action<SearchForIntent> {
  SearchForExtraAction(this.context);

  final BuildContext context;

  @override
  void invoke(covariant SearchForIntent intent) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('a different search'),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
        ),
      );
}
