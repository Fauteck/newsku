import 'dart:io';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_preferences.freezed.dart';

class LocalPreferencesCubit extends Cubit<LocalPreferencesState> {
  LocalPreferencesCubit(super.initialState) {
    init();
  }

  Future<void> init() async {
    var prefs = await SharedPreferences.getInstance();
    var colorValue = prefs.getInt('theme-color');
    Color color = colorValue != null ? Color(colorValue) : Colors.deepPurple;

    var dynamic = prefs.getBool('dynamic-color');
    var blackbackground = prefs.getBool('black-background');

    emit(state.copyWith(themeColor: color, dynamicColor: dynamic ?? false, blackBackground: blackbackground ?? false));
  }

  Future<void> setDynamicColor(bool bool) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('dynamic-color', bool);
    emit(state.copyWith(dynamicColor: bool));
  }

  Future<void> setColor(Color color) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('theme-color', color.toARGB32());
    emit(state.copyWith(themeColor: color));
  }

  Future<void> setBlackBackground(bool bool) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('black-background', bool);
    emit(state.copyWith(blackBackground: bool));
  }
}

@freezed
sealed class LocalPreferencesState with _$LocalPreferencesState {
  const factory LocalPreferencesState({@Default(Colors.deepOrange) Color themeColor, @Default(false) bool dynamicColor, @Default(false) bool blackBackground}) = _LocalPreferencesState;

  const LocalPreferencesState._();

  Future<Color> get color async {
    var color = !kIsWeb && Platform.isAndroid ? await DynamicColorPlugin.getCorePalette() : null;
    return dynamicColor ? color?.toColorScheme().primary ?? themeColor : themeColor;
  }
}
