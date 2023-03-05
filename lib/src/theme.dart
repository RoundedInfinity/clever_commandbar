import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// {@template commandbarTheme}
/// Holds the background color, shape, elevation and more properties
/// for the `Commandbar` widget.
///
// ignore: comment_references
/// Use this class to configure a [Commandbar] widget,
/// or add it to your theme as an extension
///
/// To obtain the current ambient commandbar theme, use [CommandbarTheme.of].
///
/// ```dart
/// // Add the commandbar theme extension to your theme
/// theme: ThemeData(
///   ...
///   extensions: [
///     CommandbarTheme(...),
///   ],
/// ),
/// ```
/// {@endtemplate}
class CommandbarTheme extends ThemeExtension<CommandbarTheme> {
  /// {@macro commandbarTheme}
  CommandbarTheme({
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.sizeDuration = const Duration(milliseconds: 100),
  });

  /// Returns the data from the closest [CommandbarTheme]
  /// instance that encloses the given context.
  ///
  /// Defaults to the default [CommandbarTheme] properties if
  /// there is no [CommandbarTheme] extension in the given context
  // ignore: prefer_constructors_over_static_methods
  static CommandbarTheme of(BuildContext context) {
    return Theme.of(context).extension<CommandbarTheme>() ?? CommandbarTheme();
  }

  /// Background color of the dialog that shows the commandbar.
  final Color? backgroundColor;

  /// Elevation applied to the commandbar dialog.
  final double? elevation;

  /// Shape of the commandbar dialog.
  final ShapeBorder? shape;

  /// Time it takes for commandbar to change
  /// size (e.g. when the amount of results changes)
  ///
  /// Set this to [Duration.zero] if you do not want this effect.
  final Duration sizeDuration;

  @override
  CommandbarTheme copyWith({
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Duration? sizeDuration,
  }) {
    return CommandbarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      sizeDuration: sizeDuration ?? this.sizeDuration,
    );
  }

  @override
  ThemeExtension<CommandbarTheme> lerp(
    ThemeExtension<CommandbarTheme>? other,
    double t,
  ) {
    if (other is! CommandbarTheme) {
      return this;
    }
    return CommandbarTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      elevation: lerpDouble(elevation, other.elevation, t),
      shape: ShapeBorder.lerp(shape, other.shape, t),
      sizeDuration: lerpDuration(sizeDuration, other.sizeDuration, t),
    );
  }
}
