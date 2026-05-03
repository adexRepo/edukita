import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/management/guardian_model.dart';
import 'package:edukita/features/management/guardian_repository.dart';

part 'guardian_state.dart';

class GuardianCubit extends Cubit<GuardianState> {
  final GuardianRepository _repository;

  GuardianCubit(this._repository) : super(const GuardianState());

  Future<void> loadGuardians() async {
    emit(state.copyWith(isLoading: true));
    try {
      final guardians = await _repository.getAllGuardians();
      emit(state.copyWith(isLoading: false, guardians: guardians, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addGuardian(Guardian guardian) async {
    try {
      await _repository.insertGuardian(guardian);
      await loadGuardians();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateGuardian(Guardian guardian) async {
    try {
      await _repository.updateGuardian(guardian);
      await loadGuardians();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteGuardian(String id) async {
    try {
      await _repository.deleteGuardian(id);
      await loadGuardians();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadStudentGuardians(String studentId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final guardians = await _repository.getGuardiansByStudent(studentId);
      emit(state.copyWith(isLoading: false, guardians: guardians, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> linkGuardian(StudentGuardian studentGuardian) async {
    try {
      await _repository.linkStudentGuardian(studentGuardian);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> unlinkGuardian(String studentId, String guardianId) async {
    try {
      await _repository.unlinkStudentGuardian(studentId, guardianId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }
}
