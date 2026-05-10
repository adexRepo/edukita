part of 'schedule_cubit.dart';

class ScheduleState {
  final List<Schedule> schedules;
  final List<ScheduleEvent> events;
  final bool isLoading;
  final String? error;

  const ScheduleState({
    this.schedules = const [],
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  ScheduleState copyWith({
    List<Schedule>? schedules,
    List<ScheduleEvent>? events,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
