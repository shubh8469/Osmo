// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/Auth/authRepository.dart';

@immutable
abstract class RegisterTokenState {}

class RegisterTokenInitial extends RegisterTokenState {}

class RegisterTokenProgress extends RegisterTokenState {
  RegisterTokenProgress();
}

class RegisterTokenSuccess extends RegisterTokenState {
  RegisterTokenSuccess();
}

class RegisterTokenFailure extends RegisterTokenState {
  final String errorMessage;

  RegisterTokenFailure(this.errorMessage);
}

class RegisterTokenCubit extends Cubit<RegisterTokenState> {
  final AuthRepository _authRepository;

  RegisterTokenCubit(this._authRepository) : super(RegisterTokenInitial());

  //to update fcmId
  void registerToken({required String fcmId, required BuildContext context}) {
    //emitting registerTokenProgress state
    emit(RegisterTokenProgress());
    //update fcmId of user with given provider and also update user fcmId in api
    _authRepository
        .registerToken(
      fcmId: fcmId,
      context: context,
    )
        .then((result) {
      emit(RegisterTokenSuccess());
    }).catchError((e) {
      emit(RegisterTokenFailure(e.toString()));
    });
  }
}
