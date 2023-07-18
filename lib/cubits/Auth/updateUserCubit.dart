// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/repositories/Auth/authRepository.dart';

abstract class UpdateUserState {}

class UpdateUserInitial extends UpdateUserState {}

class UpdateUserFetchInProgress extends UpdateUserState {}

class UpdateUserFetchSuccess extends UpdateUserState {
  dynamic updateUser;

  UpdateUserFetchSuccess({
    required this.updateUser,
  });
}

class UpdateUserFetchFailure extends UpdateUserState {
  final String errorMessage;

  UpdateUserFetchFailure(this.errorMessage);
}

class UpdateUserCubit extends Cubit<UpdateUserState> {
  final AuthRepository _updateUserRepository;

  UpdateUserCubit(this._updateUserRepository) : super(UpdateUserInitial());

  Future<dynamic> setUpdateUser({required String userId, String? name, String? mobile, String? email, String? filePath, required BuildContext context}) async {
    try {
      emit(UpdateUserFetchInProgress());
      final result = await _updateUserRepository.updateUserData(context: context, userId: userId, mobile: mobile, name: name, email: email, filePath: filePath);
      emit(
        UpdateUserFetchSuccess(
          updateUser: result,
        ),
      );
      return result;
    } catch (e) {
      emit(UpdateUserFetchFailure(e.toString()));
    }
  }
}
