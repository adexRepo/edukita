class FeatureState<T> {
  const FeatureState({
    this.items = const [],
    this.loading = false,
    this.message,
  });

  final List<T> items;
  final bool loading;
  final String? message;

  FeatureState<T> copyWith({
    List<T>? items,
    bool? loading,
    String? message,
  }) {
    return FeatureState<T>(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      message: message ?? this.message,
    );
  }
}
