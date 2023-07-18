// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/Auth/authCubit.dart';
import '../../../../cubits/NewsComment/deleteCommentCubit.dart';
import '../../../../cubits/NewsComment/flagCommentCubit.dart';
import '../../../../cubits/commentNewsCubit.dart';
import '../../../../data/models/CommentModel.dart';
import '../../../../utils/uiUtils.dart';
import '../../../widgets/SnackBarWidget.dart';
import '../../../widgets/customTextLabel.dart';
import '../../../widgets/loginRequired.dart';

delAndReportCom(
    {required int index,
    required CommentModel model,
    required BuildContext context,
    required TextEditingController reportC,
    required String newsId,
    required StateSetter setState,
    Function? isReplyUpdate}) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            elevation: 2.0,
            backgroundColor: UiUtils.getColorScheme(context).background,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (context.read<AuthCubit>().getUserId() == model.userId!)
                  Row(
                    children: <Widget>[
                      CustomTextLabel(
                        text: 'deleteTxt',
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      BlocConsumer<DeleteCommCubit, DeleteCommState>(
                          bloc: context.read<DeleteCommCubit>(),
                          listener: (context, state) {
                            if (state is DeleteCommSuccess) {
                              context.read<CommentNewsCubit>().deleteComment(index);
                              showSnackBar(state.message, context);
                              if (isReplyUpdate != null) {
                                isReplyUpdate(false, index);
                              }
                              Navigator.pop(context);
                            }
                          },
                          builder: (context, state) {
                            return InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Image.asset(
                                "assets/images/delete_icon.png",
                                color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8),
                                height: 20,
                                width: 20,
                              ),
                              onTap: () async {
                                if (context.read<AuthCubit>().getUserId() != "0") {
                                  context.read<DeleteCommCubit>().setDeleteComm(userId: context.read<AuthCubit>().getUserId(), commId: model.id!);
                                }
                              },
                            );
                          }),
                    ],
                  ),
                if (context.read<AuthCubit>().getUserId() != model.userId!)
                  Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: <Widget>[
                          CustomTextLabel(
                            text: 'reportTxt',
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Image.asset(
                            "assets/images/flag_icon.png",
                            color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8),
                            height: 20,
                            width: 20,
                          ),
                        ],
                      )),
                if (context.read<AuthCubit>().getUserId() != model.userId!)
                  Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                        controller: reportC,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6),
                            ),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), width: 0.5),
                          ),
                        ),
                      )),
                if (context.read<AuthCubit>().getUserId() != model.userId!)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: CustomTextLabel(
                            text: 'cancelBtn',
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontWeight: FontWeight.bold),
                          )),
                      BlocConsumer<SetFlagCubit, SetFlagState>(
                          bloc: context.read<SetFlagCubit>(),
                          listener: (context, state) {
                            if (state is SetFlagFetchSuccess) {
                              setState(() {
                                reportC.text = "";
                              });

                              showSnackBar(state.message, context);
                              Navigator.pop(context);
                            }
                          },
                          builder: (context, state) {
                            return TextButton(
                                onPressed: () {
                                  if (context.read<AuthCubit>().getUserId() != "0") {
                                    if (reportC.text.trim().isNotEmpty) {
                                      context.read<SetFlagCubit>().setFlag(userId: context.read<AuthCubit>().getUserId(), commId: model.id!, newsId: newsId, message: reportC.text);
                                    } else {
                                      showSnackBar(UiUtils.getTranslatedLabel(context, 'firstFillData'), context);
                                    }
                                  } else {
                                    loginRequired(context);
                                  }
                                },
                                child: CustomTextLabel(
                                  text: 'submitBtn',
                                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontWeight: FontWeight.bold),
                                ));
                          })
                    ],
                  ),
              ],
            )));
      });
}
