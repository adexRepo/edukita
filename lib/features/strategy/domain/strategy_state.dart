part of 'strategy_cubit.dart';

class StrategyState {
  final List<Strategy> strategies;
  final bool isLoading;
  final String? error;

  const StrategyState({
    this.strategies = const [],
    this.isLoading = false,
    this.error,
  });

  StrategyState copyWith({
    List<Strategy>? strategies,
    bool? isLoading,
    String? error,
  }) {
    return StrategyState(
      strategies: strategies ?? this.strategies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
