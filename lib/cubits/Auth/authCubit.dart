// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/AuthModel.dart';
import '../../data/repositories/Auth/authRepository.dart';

const String loginEmail = "email";
const String loginGmail = "gmail";
const String loginFb = "fb";
const String loginMbl = "mobile";

enum AuthProvider { gmail, fb, apple, mobile, email }

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  //to store authDetails
  final AuthModel authModel;

  Authenticated({required this.authModel});
}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    checkAuthStatus();
  }

  AuthRepository get authRepository => _authRepository;

  void checkAuthStatus() {
    //authDetails is map. keys are isLogin,userId,authProvider,jwtToken
    final authDetails = _authRepository.getLocalAuthDetails();

    if (authDetails['isLogIn']) {
      emit(Authenticated(authModel: AuthModel.fromJson(authDetails)));
    } else {
      emit(Unauthenticated());
    }
  }

  String getUserId() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.id!;
    }
    return "0";
  }

  String getUserName() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.name!;
    }
    return "";
  }

  String getEmail() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.email!;
    }
    return "";
  }

  String getProfile() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.profile!;
    }
    return "";
  }

  String getMobile() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.mobile!;
    }
    return "";
  }

  String getType() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.type!;
    }
    return "";
  }

  String getStatus() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.status!;
    }
    return "";
  }

  String getIsFirstLogin() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.isFirstLogin!;
    }
    return "";
  }

  String getRole() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.role!;
    }
    return "";
  }

  void updateUserProfileUrl(String profileUrl) {
    final oldUserDetails = (state as Authenticated).authModel;
    _authRepository.authLocalDataSource.setProfile(profileUrl);

    emit((Authenticated(authModel: oldUserDetails.copyWith(profile: profileUrl))));
  }

  void updateDetails({required AuthModel authModel}) {
    emit(Authenticated(authModel: authModel));
  }

  void updateUserId(String id) {
    final oldUserDetails = (state as Authenticated).authModel;
    _authRepository.authLocalDataSource.setId(id);
    emit((Authenticated(authModel: oldUserDetails.copyWith(id: id))));
  }

  void updateUserName(String name) {
    final oldUserDetails = (state as Authenticated).authModel;
    _authRepository.authLocalDataSource.setName(name);

    emit((Authenticated(authModel: oldUserDetails.copyWith(name: name))));
  }

  void updateUserMobile(String mobile) {
    final oldUserDetails = (state as Authenticated).authModel;
    _authRepository.authLocalDataSource.setMobile(mobile);

    emit((Authenticated(authModel: oldUserDetails.copyWith(mobile: mobile))));
  }

  void updateUserEmail(String email) {
    final oldUserDetails = (state as Authenticated).authModel;
    _authRepository.authLocalDataSource.setEmail(email);

    emit((Authenticated(authModel: oldUserDetails.copyWith(email: email))));
  }

  //to signOut
  Future signOut(AuthProvider authProvider) async {
    if (state is Authenticated) {
      _authRepository.signOut(authProvider);
      emit(Unauthenticated());
    }
  }
}
