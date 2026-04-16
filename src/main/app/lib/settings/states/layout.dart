import 'package:app/feed/models/feed_category.dart';
import 'package:app/feed/services/feed_service.dart';
import 'package:app/layouts/models/layout_block.dart';
import 'package:app/layouts/models/layout_block_types.dart';
import 'package:app/layouts/services/layout.dart';
import 'package:app/magazine/models/magazine_tab.dart';
import 'package:app/magazine/services/magazine_tab_service.dart';
import 'package:app/utils/models/with_error.dart';
import 'package:app/utils/utils.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'layout.freezed.dart';

class LayoutCubit extends Cubit<LayoutState> {
  final scrollController = ScrollController();

  LayoutCubit(super.initialState) {
    init();
  }

  Future<void> init() async {
    await Future.wait([getLayout(), loadMagazineTabs()]);
  }

  @override
  Future<void> close() {
    EasyDebounce.cancel('layout-tab-update');
    scrollController.dispose();
    return super.close();
  }

  void setDragging(bool dragging) {
    emit(state.copyWith(dragging: dragging));
  }

  Future<void> getLayout() async {
    try {
      emit(state.copyWith(loading: true));
      if (state.selectedTab != null) {
        final blocks = await MagazineTabService(serverUrl!).getTabLayout(state.selectedTab!.id!);
        emit(state.copyWith(blocks: blocks, loading: false));
        return;
      }
      var layout = LayoutService(serverUrl!).getLayout();
      var categories = await FeedService(serverUrl!).getFeedCategories();
      categories.insert(0, FeedCategory(name: "Any"));
      emit(state.copyWith(blocks: await layout, categories: categories, loading: false));
    } catch (e, s) {
      emit(state.copyWith(loading: false, error: e, stackTrace: s));
      rethrow;
    }
  }

  Future<void> loadMagazineTabs() async {
    try {
      final tabs = await MagazineTabService(serverUrl!).getTabs();
      emit(state.copyWith(magazineTabs: tabs));
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  Future<void> selectTab(MagazineTab? tab) async {
    emit(state.copyWith(selectedTab: tab, blocks: [], loading: true));
    try {
      if (tab != null) {
        final blocks = await MagazineTabService(serverUrl!).getTabLayout(tab.id!);
        emit(state.copyWith(blocks: blocks, loading: false));
      } else {
        var layout = LayoutService(serverUrl!).getLayout();
        var categories = await FeedService(serverUrl!).getFeedCategories();
        categories.insert(0, FeedCategory(name: "Any"));
        emit(state.copyWith(blocks: await layout, categories: categories, loading: false));
      }
    } catch (e, s) {
      emit(state.copyWith(loading: false, error: e, stackTrace: s));
    }
  }

  Future<void> createMagazineTab(String name) async {
    try {
      final tab = MagazineTab(name: name, displayOrder: state.magazineTabs.length);
      final created = await MagazineTabService(serverUrl!).createTab(tab);
      emit(state.copyWith(magazineTabs: [...state.magazineTabs, created]));
      await selectTab(created);
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  Future<void> deleteMagazineTab(MagazineTab tab) async {
    if (tab.id == null) return;
    try {
      await MagazineTabService(serverUrl!).deleteTab(tab.id!);
      final newTabs = state.magazineTabs.where((t) => t.id != tab.id).toList();
      final isSelected = state.selectedTab?.id == tab.id;
      emit(state.copyWith(magazineTabs: newTabs));
      if (isSelected) {
        await selectTab(null);
      }
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
    }
  }

  void updateSelectedTabField({
    String? name,
    bool? isPublic,
    String? aiPromptId,
    bool clearAiPromptId = false,
    int? minimumImportance,
    bool clearMinimumImportance = false,
  }) {
    if (state.selectedTab == null) return;
    final updated = state.selectedTab!.copyWith(
      name: name ?? state.selectedTab!.name,
      isPublic: isPublic ?? state.selectedTab!.isPublic,
      aiPromptId: clearAiPromptId ? null : (aiPromptId ?? state.selectedTab!.aiPromptId),
      minimumImportance: clearMinimumImportance ? null : (minimumImportance ?? state.selectedTab!.minimumImportance),
    );
    final newTabs = state.magazineTabs.map((t) => t.id == updated.id ? updated : t).toList();
    emit(state.copyWith(selectedTab: updated, magazineTabs: newTabs));
    EasyDebounce.debounce('layout-tab-update', const Duration(milliseconds: 800), () async {
      try {
        await MagazineTabService(serverUrl!).updateTab(updated);
      } catch (e, s) {
        emit(state.copyWith(error: e, stackTrace: s));
      }
    });
  }

  void acceptDrag(int index, DragTargetDetails<LayoutBlockTypes> details) {
    final blocks = List<LayoutBlock>.from(state.blocks);

    LayoutBlock newBlock = LayoutBlock(type: details.data, order: index + 1, settings: details.data.defaultSettings);

    blocks.insert(index + 1, newBlock);

    for (int i = 0; i < blocks.length; i++) {
      blocks[i] = blocks[i].copyWith(order: i);
    }

    emit(state.copyWith(dragging: false, blocks: blocks));
  }

  void removeBlock(LayoutBlock block) {
    final blocks = List<LayoutBlock>.from(state.blocks);
    blocks.remove(block);
    emit(state.copyWith(blocks: blocks));
  }

  Future<void> save() async {
    try {
      if (state.selectedTab != null) {
        await MagazineTabService(serverUrl!).setTabLayout(state.selectedTab!.id!, state.blocks);
        return;
      }
      if (state.valid) {
        await LayoutService(serverUrl!).setLayout(state.blocks);
      }
    } catch (e, s) {
      emit(state.copyWith(error: e, stackTrace: s));
      rethrow;
    }
  }

  void updateBlock(LayoutBlock oldBlock, LayoutBlock newBlock) {
    final blocks = List<LayoutBlock>.from(state.blocks);

    final index = blocks.indexOf(oldBlock);

    blocks[index] = newBlock;

    emit(state.copyWith(blocks: blocks));
  }

  void onReorder(int oldIndex, int newIndex) {
    final blocks = List<LayoutBlock>.from(state.blocks);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, item);

    for (int i = 0; i < blocks.length; i++) {
      blocks[i] = blocks[i].copyWith(order: i);
    }

    emit(state.copyWith(blocks: blocks));
  }
}

@freezed
sealed class LayoutState with _$LayoutState implements WithError {
  @Implements<WithError>()
  const factory LayoutState({
    @Default(false) bool dragging,
    @Default([]) List<LayoutBlock> blocks,
    @Default([]) List<FeedCategory> categories,
    @Default([]) List<MagazineTab> magazineTabs,
    MagazineTab? selectedTab,
    @Default(true) bool loading,
    dynamic error,
    StackTrace? stackTrace,
  }) = _LayoutState;

  const LayoutState._();

  bool get valid => blocks.isNotEmpty && !blocks.last.type.fixedSize;
}
