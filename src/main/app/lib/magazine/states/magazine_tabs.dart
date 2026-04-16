import 'package:app/magazine/models/magazine_tab.dart';
import 'package:app/magazine/services/magazine_tab_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'magazine_tabs.freezed.dart';

class MagazineTabsCubit extends Cubit<MagazineTabsState> {
  MagazineTabsCubit(super.initialState) {
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

  void selectTab(MagazineTab? tab) {
    emit(state.copyWith(selectedTab: tab));
  }
}

@freezed
sealed class MagazineTabsState with _$MagazineTabsState implements WithError {
  @Implements<WithError>()
  const factory MagazineTabsState({
    @Default([]) List<MagazineTab> tabs,
    MagazineTab? selectedTab,
    @Default(false) bool loading,
    dynamic error,
    StackTrace? stackTrace,
  }) = _MagazineTabsState;
}
