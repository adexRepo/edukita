import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/features/teaching_locations/domain/teaching_location_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'teaching_location_state.dart';

class TeachingLocationCubit extends Cubit<TeachingLocationState> {
  TeachingLocationCubit(this._repository, this._cacheService)
    : super(const TeachingLocationState());

  final TeachingLocationRepository _repository;
  final TeachingLocationCacheService _cacheService;

  void _safeEmit(TeachingLocationState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadLocations({bool forceRefresh = false}) async {
    final cacheKey = _cacheKey(state);
    if (!forceRefresh) {
      final cachedState = _cacheService.get(cacheKey);
      if (cachedState != null) {
        _safeEmit(cachedState.copyWith(isLoading: false, error: null));
        return;
      }
    }

    _safeEmit(state.copyWith(isLoading: true, error: null));
    try {
      final locations = await _repository.getLocations(
        query: state.query,
        isActive: state.isActive,
      );
      final nextState = state.copyWith(
        isLoading: false,
        locations: locations,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setSearch(String query) async {
    _safeEmit(state.copyWith(query: query));
    await loadLocations();
  }

  Future<void> setStatus(bool? isActive) async {
    _safeEmit(
      state.copyWith(isActive: isActive, clearStatus: isActive == null),
    );
    await loadLocations();
  }

  Future<void> clearFilters() async {
    _safeEmit(
      state.copyWith(
        query: '',
        clearStatus: true,
      ),
    );
    await loadLocations();
  }

  Future<void> saveLocation(TeachingLocation location) async {
    try {
      await _repository.saveLocation(location);
      _cacheService.clear();
      await loadLocations(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> setActive(TeachingLocation location, bool isActive) async {
    try {
      await _repository.setActive(location.id, isActive);
      _cacheService.clear();
      await loadLocations(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  String _cacheKey(TeachingLocationState state) {
    return [
      state.query.trim().toLowerCase(),
      state.isActive?.toString() ?? '',
    ].join('|');
  }
}

class TeachingLocationCacheService {
  TeachingLocationCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxEntries = 3,
  }) : _items = AppMemoryCache<TeachingLocationState>(
         ttl: ttl,
         maxEntries: maxEntries,
       );

  final AppMemoryCache<TeachingLocationState> _items;

  TeachingLocationState? get(String key) => _items.get(key);

  void put(String key, TeachingLocationState state) {
    _items.put(key, state.copyWith(isLoading: false, error: null));
  }

  void clear() => _items.clear();
}
