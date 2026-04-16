import 'package:app/layouts/models/layout_block.dart';
import 'package:app/magazine/models/magazine_tab.dart';
import 'package:app/magazine/services/magazine_tab_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'magazine.freezed.dart';

class MagazineSettingsCubit extends Cubit<MagazineSettingsState> {
  MagazineSettingsCubit(super.initialState) {
    loadTabs();
  }

  Future<void> loadTabs() async {
    try {
      emit(state.copyWith(loading: true));
      final tabs = await MagazineTabService(serverUrl!).getTabs();
      emit(state.copyWith(tabs: tabs, loading: false));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s, loading: false));
    }
  }

  Future<void> createTab(String name) async {
    try {
      final tab = MagazineTab(name: name, displayOrder: state.tabs.length);
      final created = await MagazineTabService(serverUrl!).createTab(tab);
      final newTabs = [...state.tabs, created];
      emit(state.copyWith(tabs: newTabs, selectedTab: created, loading: false));
      await loadTabLayout(created);
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  void clearSelection() {
    emit(state.copyWith(selectedTab: null, tabLayout: []));
  }

  Future<void> selectTab(MagazineTab tab) async {
    emit(state.copyWith(selectedTab: tab, tabLayout: []));
    await loadTabLayout(tab);
  }

  Future<void> loadTabLayout(MagazineTab tab) async {
    if (tab.id == null) return;
    try {
      final layout = await MagazineTabService(serverUrl!).getTabLayout(tab.id!);
      emit(state.copyWith(tabLayout: layout));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  Future<void> updateTab(MagazineTab updated) async {
    try {
      final saved = await MagazineTabService(serverUrl!).updateTab(updated);
      final newTabs = state.tabs.map((t) => t.id == saved.id ? saved : t).toList();
      emit(state.copyWith(tabs: newTabs, selectedTab: saved));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  void updateSelectedTabField({String? name, bool? isPublic, String? aiPreference, bool clearAiPreference = false, String? aiPromptId, bool clearAiPromptId = false, int? minimumImportance, bool clearMinimumImportance = false}) {
    if (state.selectedTab == null) return;
    final updated = state.selectedTab!.copyWith(
      name: name ?? state.selectedTab!.name,
      isPublic: isPublic ?? state.selectedTab!.isPublic,
      aiPreference: clearAiPreference ? null : (aiPreference ?? state.selectedTab!.aiPreference),
      aiPromptId: clearAiPromptId ? null : (aiPromptId ?? state.selectedTab!.aiPromptId),
      minimumImportance: clearMinimumImportance ? null : (minimumImportance ?? state.selectedTab!.minimumImportance),
    );
    emit(state.copyWith(selectedTab: updated));
    EasyDebounce.debounce('magazine-tab-update', const Duration(milliseconds: 800), () => updateTab(updated));
  }

  Future<void> deleteTab(MagazineTab tab) async {
    if (tab.id == null) return;
    try {
      await MagazineTabService(serverUrl!).deleteTab(tab.id!);
      final newTabs = state.tabs.where((t) => t.id != tab.id).toList();
      emit(state.copyWith(tabs: newTabs, selectedTab: null, tabLayout: []));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  Future<void> saveTabLayout(List<LayoutBlock> blocks) async {
    if (state.selectedTab?.id == null) return;
    try {
      final saved = await MagazineTabService(serverUrl!).setTabLayout(state.selectedTab!.id!, blocks);
      emit(state.copyWith(tabLayout: saved));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  @override
  Future<void> close() async {
    EasyDebounce.cancel('magazine-tab-update');
    super.close();
  }
}

@freezed
sealed class MagazineSettingsState with _$MagazineSettingsState implements WithError {
  @Implements<WithError>()
  const factory MagazineSettingsState({
    @Default([]) List<MagazineTab> tabs,
    MagazineTab? selectedTab,
    @Default([]) List<LayoutBlock> tabLayout,
    @Default(false) bool loading,
    dynamic error,
    StackTrace? stackTrace,
  }) = _MagazineSettingsState;
}
