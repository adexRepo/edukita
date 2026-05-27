import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:edukita/features/strategy/data/strategy_model.dart';
import 'package:edukita/features/strategy/domain/strategy_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'strategy_state.dart';

class StrategyCubit extends Cubit<StrategyState> {
  final StrategyRepository _repository;
  final StrategyCacheService _cacheService;

  StrategyCubit(this._repository, this._cacheService)
    : super(const StrategyState());

  void _safeEmit(StrategyState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadStrategies({bool forceRefresh = false}) async {
    const cacheKey = 'all';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final strategies = await _repository.getAllStrategies();
      final nextState = state.copyWith(
        isLoading: false,
        strategies: strategies,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addStrategy(Strategy strategy) async {
    try {
      await _repository.insertStrategy(strategy);
      _cacheService.clear();
      await loadStrategies(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateStrategy(Strategy strategy) async {
    try {
      await _repository.updateStrategy(strategy);
      _cacheService.clear();
      await loadStrategies(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteStrategy(String id) async {
    try {
      await _repository.deleteStrategy(id);
      _cacheService.clear();
      await loadStrategies(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }
}

class StrategyCacheService {
  StrategyCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxEntries = 2,
  }) : _items = AppMemoryCache<StrategyState>(
         ttl: ttl,
         maxEntries: maxEntries,
       );

  final AppMemoryCache<StrategyState> _items;

  StrategyState? get(String key) => _items.get(key);

  void put(String key, StrategyState state) {
    _items.put(key, state.copyWith(isLoading: false));
  }

  void clear() => _items.clear();
}
