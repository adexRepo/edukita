import 'package:edukita/features/strategy/data/strategy_model.dart';
import 'package:edukita/features/strategy/domain/strategy_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'strategy_state.dart';

class StrategyCubit extends Cubit<StrategyState> {
  final StrategyRepository _repository;

  StrategyCubit(this._repository) : super(const StrategyState());

  Future<void> loadStrategies() async {
    emit(state.copyWith(isLoading: true));
    try {
      final strategies = await _repository.getAllStrategies();
      emit(
        state.copyWith(isLoading: false, strategies: strategies, error: null),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addStrategy(Strategy strategy) async {
    try {
      await _repository.insertStrategy(strategy);
      await loadStrategies();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateStrategy(Strategy strategy) async {
    try {
      await _repository.updateStrategy(strategy);
      await loadStrategies();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteStrategy(String id) async {
    try {
      await _repository.deleteStrategy(id);
      await loadStrategies();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }
}
