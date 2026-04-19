import 'package:edukita/features/common/page_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageCubit<T> extends Cubit<PageState<T>> {
  PageCubit() : super(PageState<T>());

  Future<void> loadItems(Future<List<T>> Function() fetchItems) async {
    emit(state.copyWith(loading: true));
    try {
      final items = await fetchItems();
      emit(state.copyWith(items: items, loading: false));
    } catch (exception) {
      emit(state.copyWith(loading: false, message: exception.toString()));
    }
  }

  Future<void> refreshItems(Future<List<T>> Function() fetchItems) async {
    await loadItems(fetchItems);
  }

  Future<void> addItem(
    Future<void> Function() addItem,
    Future<List<T>> Function() fetchItems,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      await addItem();
      await loadItems(fetchItems);
      emit(state.copyWith(loading: false));
    } catch (exception) {
      emit(state.copyWith(loading: false, message: exception.toString()));
    }
  }

  Future<void> updateItem(
    Future<void> Function() updateItem,
    Future<List<T>> Function() fetchItems,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      await updateItem();
      await loadItems(fetchItems);
      emit(state.copyWith(loading: false));
    } catch (exception) {
      emit(state.copyWith(loading: false, message: exception.toString()));
    }
  }

  Future<void> deleteItem(
    Future<void> Function() deleteItem,
    Future<List<T>> Function() fetchItems,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      await deleteItem();
      await loadItems(fetchItems);
      emit(state.copyWith(loading: false));
    } catch (exception) {
      emit(state.copyWith(loading: false, message: exception.toString()));
    }
  }
}
