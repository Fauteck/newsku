import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_preferences.freezed.dart';

const _defaultColor = Colors.deepOrange;

const _brightness = 'brightness';
const _themeColor = 'theme-color';
const _dynamicColor = 'dynamic-color';
const _blackBackground = 'black-background';
const _truncateText = 'truncate-text';
const _titleMaxLines = 'title-max-lines';
const _contentMaxLines = 'content-max-lines';

class LocalPreferencesCubit extends Cubit<LocalPreferencesState> {
  LocalPreferencesCubit(super.initialState) {
    init();
  }

  Future<void> init() async {
    var prefs = await SharedPreferences.getInstance();
    var colorValue = prefs.getInt(_themeColor);
    Color color = colorValue != null ? Color(colorValue) : _defaultColor;

    var dynamic = prefs.getBool(_dynamicColor);
    var blackbackground = prefs.getBool(_blackBackground);

    var density = prefs.getDouble('density');

    var theme = ThemeMode.values.where((v) => v.name == prefs.getString(_brightness)).firstOrNull ?? ThemeMode.system;

    var truncateText = prefs.getBool(_truncateText) ?? true;
    var titleMaxLines = prefs.getInt(_titleMaxLines) ?? 3;
    var contentMaxLines = prefs.getInt(_contentMaxLines) ?? 4;

    emit(
      state.copyWith(
        themeColor: color,
        dynamicColor: dynamic ?? false,
        blackBackground: blackbackground ?? false,
        density: density ?? 4,
        theme: theme,
        truncateText: truncateText,
        titleMaxLines: titleMaxLines,
        contentMaxLines: contentMaxLines,
      ),
    );
  }

  Future<void> setDynamicColor(bool bool) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_dynamicColor, bool);
    emit(state.copyWith(dynamicColor: bool));
  }

  Future<void> setBrightness(ThemeMode theme) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(_brightness, theme.name);
    emit(state.copyWith(theme: theme));
  }

  Future<void> setColor(Color color) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themeColor, color.toARGB32());
    emit(state.copyWith(themeColor: color));
  }

  Future<void> setBlackBackground(bool bool) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_blackBackground, bool);
    emit(state.copyWith(blackBackground: bool));
  }

  Future<void> setDensity(double density) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setDouble('density', density);
    emit(state.copyWith(density: density));
  }

  Future<void> setTruncateText(bool value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_truncateText, value);
    emit(state.copyWith(truncateText: value));
  }

  Future<void> setTitleMaxLines(int value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_titleMaxLines, value);
    emit(state.copyWith(titleMaxLines: value));
  }

  Future<void> setContentMaxLines(int value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_contentMaxLines, value);
    emit(state.copyWith(contentMaxLines: value));
  }
}

@freezed
sealed class LocalPreferencesState with _$LocalPreferencesState {
  const factory LocalPreferencesState({
    @Default(_defaultColor) Color themeColor,
    @Default(false) bool dynamicColor,
    @Default(false) bool blackBackground,
    @Default(4) double density,
    @Default(ThemeMode.system) ThemeMode theme,
    /// When true, article card titles and teasers are clamped to [titleMaxLines]
    /// and [contentMaxLines] respectively. When false, full text is shown.
    @Default(true) bool truncateText,
    @Default(3) int titleMaxLines,
    @Default(4) int contentMaxLines,
  }) = _LocalPreferencesState;

  const LocalPreferencesState._();

  Future<Color> get color async {
    var color = !kIsWeb && Platform.isAndroid ? await DynamicColorPlugin.getCorePalette() : null;
    return dynamicColor ? color?.toColorScheme().primary ?? themeColor : themeColor;
  }
}
