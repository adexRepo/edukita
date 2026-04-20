import 'package:edukita/features/common/feature_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatureCubit<T> extends Cubit<FeatureState<T>> {
  FeatureCubit() : super(const FeatureState());

  Future<void> load(Future<T> Function() fetch) async {
    emit(state.copyWith(loading: true, data: null));

    try {
      final result = await fetch();
      emit(state.copyWith(data: result, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, message: e.toString()));
    }
  }
}
