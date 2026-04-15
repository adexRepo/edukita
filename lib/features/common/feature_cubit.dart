import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/common/feature_repository.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/dashboard/dashboard_cubit.dart';

class FeatureCubit<T> extends Cubit<FeatureState<T>> {
  FeatureCubit({required this.repository}) : super(FeatureState<T>());

  final FeatureRepository<T> repository;

  Future<void> loadItems() async {
    emit(state.copyWith(loading: true));
    try {
      final items = await repository.getAll();
      emit(state.copyWith(items: items, loading: false));
    } catch (exception) {
      emit(state.copyWith(loading: false, message: exception.toString()));
    }
  }

  Future<void> addItem(T item, BuildContext context) async {
    emit(state.copyWith(loading: true));
    try {
      await repository.insert(item);
      await loadItems();
      // Refresh dashboard counters
      if (context.mounted) {
        await context.read<DashboardCubit>().refreshCounters();
      }
      emit(state.copyWith(loading: false));
    } catch (exception) {
      emit(state.copyWith(loading: false, message: exception.toString()));
    }
  }

  Future<void> updateItem(
    String id,
    Map<String, Object?> values,
    BuildContext context,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      await repository.update(id, values);
      await loadItems();
      if (context.mounted) {
        await context.read<DashboardCubit>().refreshCounters();
      }
      emit(state.copyWith(loading: false));
    } catch (exception) {
      emit(state.copyWith(loading: false, message: exception.toString()));
    }
  }

  Future<void> deleteItem(String id) async {
    emit(state.copyWith(loading: true));
    try {
      await repository.delete(id);
      await loadItems();
      emit(state.copyWith(loading: false));
    } catch (exception) {
      emit(state.copyWith(loading: false, message: exception.toString()));
    }
  }
}
