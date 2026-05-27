import 'dart:collection';

class AppMemoryCache<T> {
  AppMemoryCache({
    this.ttl = const Duration(minutes: 2),
    this.maxEntries = 12,
  }) : assert(maxEntries > 0);

  final Duration ttl;
  final int maxEntries;
  final LinkedHashMap<String, _AppMemoryCacheEntry<T>> _items =
      LinkedHashMap<String, _AppMemoryCacheEntry<T>>();

  T? get(String key) {
    final entry = _items.remove(key);
    if (entry == null) return null;
    if (_isExpired(entry.cachedAt)) return null;

    _items[key] = entry;
    return entry.value;
  }

  void put(String key, T value) {
    _items.remove(key);
    _items[key] = _AppMemoryCacheEntry<T>(
      value: value,
      cachedAt: DateTime.now(),
    );
    _trim();
  }

  void remove(String key) => _items.remove(key);

  void clear() => _items.clear();

  bool _isExpired(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) > ttl;
  }

  void _trim() {
    _items.removeWhere((_, entry) => _isExpired(entry.cachedAt));
    while (_items.length > maxEntries) {
      _items.remove(_items.keys.first);
    }
  }
}

class _AppMemoryCacheEntry<T> {
  const _AppMemoryCacheEntry({
    required this.value,
    required this.cachedAt,
  });

  final T value;
  final DateTime cachedAt;
}
