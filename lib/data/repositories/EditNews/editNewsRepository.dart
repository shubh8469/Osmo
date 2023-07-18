// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/EditNews/editNewsRemoteDataSource.dart';

class EditNewsRepository {
  static final EditNewsRepository _editNewsRepository = EditNewsRepository._internal();

  late EditNewsRemoteDataSource _editNewsRemoteDataSource;

  factory EditNewsRepository() {
    _editNewsRepository._editNewsRemoteDataSource = EditNewsRemoteDataSource();
    return _editNewsRepository;
  }

  EditNewsRepository._internal();

  Future<Map<String, dynamic>> editNews({
    required BuildContext context,
    required String userId,
    required String newsID,
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
    List<File>? otherImage,
  }) async {
    final result = await _editNewsRemoteDataSource.editNewsData(
        context: context,
        userId: userId,
        catId: catId,
        langId: langId,
        conType: conType,
        conTypeId: conTypeId,
        image: image,
        title: title,
        subCatId: subCatId,
        showTill: showTill,
        desc: desc,
        otherImage: otherImage,
        tagId: tagId,
        url: url,
        videoUpload: videoUpload,
        newsId: newsID,
        model: model);

    return result;
  }
}
