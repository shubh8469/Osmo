// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/NewsModel.dart';
import '../data/repositories/EditNews/editNewsRepository.dart';

abstract class EditNewsState {}

class EditNewsInitial extends EditNewsState {}

class EditNewsFetchInProgress extends EditNewsState {}

class EditNewsFetchSuccess extends EditNewsState {
  var editNews;

  EditNewsFetchSuccess({
    required this.editNews,
  });
}

class EditNewsFetchFailure extends EditNewsState {
  final String errorMessage;

  EditNewsFetchFailure(this.errorMessage);
}

class EditNewsCubit extends Cubit<EditNewsState> {
  final EditNewsRepository _editNewsRepository;

  EditNewsCubit(this._editNewsRepository) : super(EditNewsInitial());

  void editNews(
      {required BuildContext context,
      required String userId,
      required String newsId,
      required String catId,
      required String title,
      required String conTypeId,
      required String conType,
      required NewsModel model,
      File? image,
      required String langId,
      String? subCatId,
      String? showTill,
      String? tagId,
      String? url,
      File? videoUpload,
      String? desc,
      List<File>? otherImage}) async {
    try {
      emit(EditNewsFetchInProgress());
      final result = await _editNewsRepository.editNews(
          context: context,
          userId: userId,
          title: title,
          image: image,
          conTypeId: conTypeId,
          conType: conType,
          langId: langId,
          catId: catId,
          videoUpload: videoUpload,
          url: url,
          tagId: tagId,
          otherImage: otherImage,
          desc: desc,
          showTill: showTill,
          subCatId: subCatId,
          newsID: newsId,
          model: model);

      emit(EditNewsFetchSuccess(editNews: result));
    } catch (e) {
      emit(EditNewsFetchFailure(e.toString()));
    }
  }
}
