// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/AuthModel.dart';
import '../../data/repositories/Auth/authRepository.dart';
import 'authCubit.dart';

@immutable
abstract class SocialSignUpState {}

class SocialSignUpInitial extends SocialSignUpState {}

class SocialSignUpProgress extends SocialSignUpState {}

class SocialSignUpSuccess extends SocialSignUpState {
  final AuthModel authModel;

  SocialSignUpSuccess({required this.authModel});
}

class SocialSignUpFailure extends SocialSignUpState {
  final String errorMessage;

  SocialSignUpFailure(this.errorMessage);
}

class SocialSignUpCubit extends Cubit<SocialSignUpState> {
  final AuthRepository _authRepository;

  SocialSignUpCubit(this._authRepository) : super(SocialSignUpInitial());

  //to socialSocialSignUp user
  void socialSignUpUser({required AuthProvider authProvider, required BuildContext context, String? email, String? password, String? otp, String? verifiedId}) {
    emit(SocialSignUpProgress());
    _authRepository.signInUser(email: email, otp: otp, password: password, verifiedId: verifiedId, authProvider: authProvider, context: context).then((result) {
      //success
      emit(SocialSignUpSuccess(
        authModel: AuthModel.fromJson(result["data"]),
      ));
    }).catchError((e) {
      //failure
      emit(SocialSignUpFailure(e.toString()));
    });
  }

  void socialSignUpUserSignUp({AuthProvider? authProvider, required BuildContext context, String? email, String? mobile, String? displayName, String? photo, String? firebaseId}) {
    emit(SocialSignUpProgress());
    _authRepository.signInUserSignUp(email: email, context: context, mobile:  mobile, displayName:  displayName, photo: photo, firebaseId: firebaseId).then((result) {
      //success
      emit(SocialSignUpSuccess(
        authModel: AuthModel.fromJson(result["data"]),
      ));
    }).catchError((e) {
      //failure
      emit(SocialSignUpFailure(e.toString()));
    });
  }
}
