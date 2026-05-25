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
  StrategyCacheService({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _StrategyCacheEntry> _items = {};

  StrategyState? get(String key) {
    final entry = _items[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.cachedAt) > ttl) {
      _items.remove(key);
      return null;
    }
    return entry.state;
  }

  void put(String key, StrategyState state) {
    _items[key] = _StrategyCacheEntry(
      state: state.copyWith(isLoading: false),
      cachedAt: DateTime.now(),
    );
  }

  void clear() => _items.clear();
}

class _StrategyCacheEntry {
  const _StrategyCacheEntry({required this.state, required this.cachedAt});

  final StrategyState state;
  final DateTime cachedAt;
}
