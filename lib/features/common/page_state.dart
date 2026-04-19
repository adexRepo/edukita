class PageState<T> {
  final List<T> items;
  final bool loading;
  final String? message;
  PageState({this.items = const [], this.loading = false, this.message});

  PageState<T> copyWith({List<T>? items, bool? loading, String? message}) {
    return PageState<T>(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      message: message ?? this.message,
    );
  }
}
