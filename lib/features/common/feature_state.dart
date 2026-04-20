class FeatureState<T> {
  final T? data;
  final bool loading;
  final String? message;

  const FeatureState({this.data, this.loading = false, this.message});

  FeatureState<T> copyWith({T? data, bool? loading, String? message}) {
    return FeatureState<T>(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      message: message,
    );
  }
}
