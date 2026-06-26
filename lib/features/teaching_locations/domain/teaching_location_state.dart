part of 'teaching_location_cubit.dart';

class TeachingLocationState {
  const TeachingLocationState({
    this.locations = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.isActive,
  });

  final List<TeachingLocation> locations;
  final bool isLoading;
  final String? error;
  final String query;
  final bool? isActive;

  bool get hasFilters => query.trim().isNotEmpty || isActive != null;

  TeachingLocationState copyWith({
    List<TeachingLocation>? locations,
    bool? isLoading,
    String? error,
    String? query,
    bool? isActive,
    bool clearStatus = false,
  }) {
    return TeachingLocationState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      isActive: clearStatus ? null : isActive ?? this.isActive,
    );
  }
}
