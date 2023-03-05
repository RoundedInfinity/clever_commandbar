import 'package:clever_commandbar/clever_commandbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// {@template searchResultDetails}
/// Details on the search result that contain the associated action,
/// search query and focused index for an item.
/// {@endtemplate}
class SearchResultDetails<T extends Command> {
  /// {@macro searchResultDetails}
  SearchResultDetails({
    required this.index,
    required this.focusedIndex,
    required this.query,
    required this.command,
  });

  /// The index of the item that is currently focused.
  ///
  /// When this is equal to [index] this item should be focused.
  ///
  /// See also:
  /// - [isFocused]
  final int focusedIndex;

  /// The index of this item in the search result.
  final int index;

  /// The search query used in the current search.
  ///
  /// For example, this can be used to
  /// highlight matching letters in the item widget.
  final String query;

  /// The [Command] that belongs to this item.
  final T command;

  /// Returns true when the this item is currently selected.
  bool get isFocused => focusedIndex == index;
}

/// {@template commandbarItemBuilder}
/// Builder for individual widgets used to display
/// the search results of the [Commandbar]
/// {@endtemplate}
typedef CommandbarItemBuilder = Widget Function(
  BuildContext context,
  SearchResultDetails details,
);

/// {@template commandbarSearchBuilder}
/// Builder for the Text input of the [Commandbar].
///
/// Typically a [TextField].
///
/// [TextField.onChanged] should call [onSearch].
/// {@endtemplate}
typedef CommandbarSearchBuilder = Widget Function(
  BuildContext context,
  void Function(String value) onSearch,
);

/// Returns a list of search results for the given [choices] and [query].
typedef CommandSearch = List<Command> Function(
  String query,
  List<Command> choices,
);

CommandSearch _defaultSearch = (query, choices) {
  return extractTop<Command>(
    query: query,
    choices: choices,
    getter: (obj) {
      return obj.name;
    },
    limit: 6,
    cutoff: 60,
  ).map((e) => e.choice).toList();
};

/// {@template commandbar}
/// A widget that shows a Commandbar that can be used to
/// search for commands and execute them.
/// {@endtemplate}
class Commandbar extends StatefulWidget {
  /// {@macro commandbar}
  const Commandbar({
    super.key,
    required this.commands,
    required this.actionsContext,
    required this.itemBuilder,
    this.insetPadding =
        const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    required this.searchBuilder,
    this.shortcuts = const {
      SingleActivator(LogicalKeyboardKey.arrowUp): CommandShortcutType.moveUp,
      SingleActivator(LogicalKeyboardKey.arrowDown):
          CommandShortcutType.moveDown,
      SingleActivator(LogicalKeyboardKey.enter): CommandShortcutType.invoke,
    },
    this.search,
    this.constraints = const BoxConstraints(maxHeight: 400, maxWidth: 600),
    this.startCommands,
    this.commandbarTheme,
    this.closeAfterInvoke = true,
    required this.emptyBuilder,
  });

  /// The commands available for this [Commandbar].
  ///
  /// This is typically `CommandProvider.of(context).commands`.
  ///
  /// See also:
  /// - [CommandActions] Widget used to distribute [CommandActions]s.
  final Set<Command> commands;

  /// Commands shown before entering a search
  /// in the commandbar.
  ///
  /// When this is not set, [commands] will be shown instead
  final Set<Command>? startCommands;

  /// The context that contains the different [Action]s.
  ///
  /// This should be a context that contains
  /// an [Actions] (or [CommandActions]) widget.
  final BuildContext actionsContext;

  /// {@macro commandbarItemBuilder}
  final CommandbarItemBuilder itemBuilder;

  /// The padding applied to the dialog.
  ///
  /// See also:
  /// - [Dialog.insetPadding] for a more detailed explanation.
  final EdgeInsets insetPadding;

  /// The padding between the dialog and its content (searchbar, results,...)
  final EdgeInsets padding;

  /// {@macro commandbarSearchBuilder}
  final CommandbarSearchBuilder searchBuilder;

  /// Shortcuts used to control the commandbar.
  ///
  /// By default the `arrow keys` are used to navigate up and down
  /// and `Enter` is used to invoke an action.
  final Map<ShortcutActivator, CommandShortcutType> shortcuts;

  /// Defines how the commands are searched.
  ///
  /// By default, this uses a fuzzy weighted ratio algorithm
  /// with a limit of 6 items.
  final CommandSearch? search;

  /// Constraints used to limit the size of the [Commandbar].
  ///
  /// [BoxConstraints.maxHeight] and [BoxConstraints.maxWidth]
  /// should be set for this to work properly.
  final BoxConstraints constraints;

  /// The theme used for the commandbar.
  ///
  /// Uses the [CommandbarTheme.of] by default.
  ///
  /// See also:
  /// - [CommandbarTheme] on how to add this theme extension to your app theme
  final CommandbarTheme? commandbarTheme;

  /// A builder for the empty state of the search bar.
  final Widget Function(BuildContext context, String query) emptyBuilder;

  /// Should the commandbar close after invoking an action.
  final bool closeAfterInvoke;

  @override
  State<Commandbar> createState() => _CommandbarState();
}

class _CommandbarState extends State<Commandbar> {
  List<Command> result = [];

  // Using a new focus system because the default one
  // does not allow for 2 focused widget simultaneously.
  int secondaryFocus = 0;

  String query = '';

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    result = widget.startCommands?.toList() ?? widget.commands.toList();

    super.initState();
  }

  void _scrollToItem(int index) {
    final visible = itemPositionsListener.itemPositions.value
        .any((element) => element.index == index);

    if (!visible) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  void onInvoke(CommandShortcutType shortcut) {
    switch (shortcut) {
      case CommandShortcutType.moveDown:
        if (secondaryFocus < result.length - 1) {
          setState(() {
            secondaryFocus++;
            _scrollToItem(secondaryFocus);
          });
        }
        break;
      case CommandShortcutType.moveUp:
        if (secondaryFocus > 0) {
          setState(() {
            secondaryFocus--;
            _scrollToItem(secondaryFocus);
          });
        }
        break;
      case CommandShortcutType.invoke:
        if (widget.closeAfterInvoke) {
          Navigator.pop(context);
        }
        if (result.isNotEmpty) {
          Actions.maybeInvoke(
            widget.actionsContext,
            result[secondaryFocus].intent,
          );
        }

        break;
    }
  }

  void onSearch(String value) {
    setState(() {
      // Use the defined search algorithm to search the commands.
      final search = widget.search ?? _defaultSearch;
      result = search(value, widget.commands.toList());

      if (result.isEmpty && value.isEmpty) {
        result = widget.startCommands?.toList() ?? widget.commands.toList();
      }

      secondaryFocus = 0;

      query = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.commandbarTheme ?? CommandbarTheme.of(context);

    final searchResultWidget = Flexible(
      child: ScrollablePositionedList.builder(
        shrinkWrap: true,
        itemCount: result.length,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, index) {
          final item = result[index];
          return widget.itemBuilder(
            context,
            SearchResultDetails(
              index: index,
              focusedIndex: secondaryFocus,
              query: query,
              command: item,
            ),
          );
        },
      ),
    );

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: widget.insetPadding,
      backgroundColor: theme.backgroundColor,
      elevation: theme.elevation,
      shape: theme.shape,
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: theme.sizeDuration,
        curve: Curves.easeOut,
        child: ConstrainedBox(
          constraints: widget.constraints,
          child: CommandbarControlShortcuts(
            shortcuts: widget.shortcuts,
            onInvoke: onInvoke,
            child: Padding(
              padding: widget.padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.searchBuilder(context, onSearch),

                  // Create the empty state
                  if (result.isEmpty) widget.emptyBuilder(context, query),
                  if (result.isNotEmpty) searchResultWidget,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
