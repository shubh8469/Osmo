// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:news/app/app.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Auth/deleteUserCubit.dart';
import 'package:news/cubits/Auth/updateUserCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/otherPagesCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/showUploadImageBottomsheet.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/utils/validators.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news/cubits/themeCubit.dart';
import 'package:news/utils/constant.dart';
import 'package:news/ui/styles/appTheme.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const ProfileScreen(),
    );
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  File? image;
  String? name, mobile, email, profile;
  TextEditingController? nameC, monoC, emailC = TextEditingController();
  bool isEditMono = false;
  bool isEditEmail = false;
  final GlobalKey<FormState> _formkey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    getOtherPagesData();
    super.initState();
  }

  getUserData() {
    if (context.read<AuthCubit>().getUserId() != "0") {
      nameC = TextEditingController(text: context.read<AuthCubit>().getUserName());
      name = context.read<AuthCubit>().getUserName();
      monoC = TextEditingController(text: context.read<AuthCubit>().getMobile());
      mobile = context.read<AuthCubit>().getMobile();
      emailC = TextEditingController(text: context.read<AuthCubit>().getEmail());
      email = context.read<AuthCubit>().getEmail();
      profile = context.read<AuthCubit>().getProfile();
    }
  }

  getOtherPagesData() {
    Future.delayed(Duration.zero, () {
      context.read<OtherPageCubit>().getOtherPage(context: context, langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  Widget pagesBuild() {
    return BlocBuilder<OtherPageCubit, OtherPageState>(builder: (context, state) {
      if (state is OtherPageFetchSuccess) {
        return ScrollConfiguration(
          behavior: GlobalScrollBehavior(),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.otherPage.length,
            itemBuilder: ((context, index) =>
                setDrawerItem(state.otherPage[index].title!, Icons.info_rounded, false, true, false, 7, image: state.otherPage[index].image!, desc: state.otherPage[index].pageContent)),
          ),
        );
      } else {
        //state is OtherPageFetchInProgress || state is OtherPageInitial || state is OtherPageFetchFailure
        return const SizedBox.shrink();
      }
    });
  }

  switchTheme(bool value) async {
    if (value) {
      if (await InternetConnectivity.isNetworkAvailable()) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        context.read<ThemeCubit>().changeTheme(AppTheme.Dark);
        UiUtils.setUIOverlayStyle(appTheme: AppTheme.Dark);
        //for non-appbar screens
      } else {
        showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
      }
    } else {
      if (await InternetConnectivity.isNetworkAvailable()) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        context.read<ThemeCubit>().changeTheme(AppTheme.Light);
        UiUtils.setUIOverlayStyle(appTheme: AppTheme.Light);
        //for non-appbar screens
      } else {
        showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
      }
    }
  }

  bool getTheme() {
    return (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark) ? true : false;
  }

  bool getNotification() {
    if (context.read<SettingsCubit>().state.settingsModel!.notification == true) {
      return true;
    } else {
      return false;
    }
  }

  switchNotification(bool value) {
    context.read<SettingsCubit>().changeNotification(value);
    setState(() {});
  }

  //set drawer item list press
  Widget setDrawerItem(String title, IconData? icon, bool isTrailing, bool isNavigate, bool isSwitch, int id, {String? image, String? desc}) {
    return ListTile(
      dense: true,
      leading: (image != null && image != "")
          ? Image.network(
              image,
              width: 25,
              height: 25,
              color: UiUtils.getColorScheme(context).primaryContainer,
              errorBuilder: (context, error, stackTrace) {
                return Icon(icon);
              },
            )
          : Icon(
              icon,
              size: 25,
            ),
      iconColor: UiUtils.getColorScheme(context).primaryContainer,
      trailing: (isTrailing)
          ? SizedBox(
              height: 45,
              width: 55,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Switch.adaptive(
                  onChanged: (id == 0) ? switchTheme : switchNotification,
                  value: (id == 0) ? getTheme() : getNotification(),
                  activeColor: Theme.of(context).primaryColor,
                  activeTrackColor: Theme.of(context).primaryColor,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey,
                ),
              ))
          : const SizedBox.shrink(),
      title: CustomTextLabel(text: title, textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
      onTap: () {
        if (isNavigate) {
          switch (id) {
            case 2:
              Navigator.of(context).pushNamed(Routes.languageList, arguments: {"from": 2});
              break;
            case 3:
              Navigator.of(context).pushNamed(Routes.bookmark);
              break;
            case 4:
              Navigator.of(context).pushNamed(Routes.addNews, arguments: {"isEdit": false, "from": "profile"});
              break;
            case 5:
              Navigator.of(context).pushNamed(Routes.showNews);
              break;
            case 6:
              Navigator.of(context).pushNamed(Routes.managePref, arguments: {"from": 1});
              break;
            case 7:
              Navigator.of(context).pushNamed(Routes.privacy, arguments: {"from": "setting", "title": title, "desc": desc});
              break;
            case 8:
              _openStoreListing();
              break;
            case 9:
              var str = "$appName\n\n${UiUtils.getTranslatedLabel(context, 'appFindLbl')}\n\n$androidLbl\n$androidLink$packageName\n\n$iosLbl\n$iosLink";
              Share.share(str);
              break;
            case 10:
              logOutDailog();
              break;
            case 11:
              deleteAccount();
              break;
            default:
              break;
          }
        }
      },
    );
  }

  logOutDailog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              backgroundColor: UiUtils.getColorScheme(context).background,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: CustomTextLabel(
                text: 'logoutTxt',
                textStyle: Theme.of(this.context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
              ),
              actions: <Widget>[
                TextButton(
                    child: CustomTextLabel(
                      text: 'noLbl',
                      textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                    child: CustomTextLabel(
                      text: 'yesLbl',
                      textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      UiUtils.userLogOut(contxt: context);
                    })
              ],
            );
          });
        });
  }

  //set Delete dialogue
  deleteAccount() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              backgroundColor: UiUtils.getColorScheme(context).background,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: CustomTextLabel(
                text: (_auth.currentUser != null) ? 'deleteConfirm' : 'deleteRelogin',
                textStyle: Theme.of(this.context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
              ),
              title: (_auth.currentUser != null) ? const CustomTextLabel(text: 'deleteAcc') : const CustomTextLabel(text: 'deleteAlertTitle'),
              titleTextStyle: Theme.of(this.context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: UiUtils.getColorScheme(context).primaryContainer),
              actions: <Widget>[
                TextButton(
                    child: CustomTextLabel(
                      text: (_auth.currentUser != null) ? 'noLbl' : 'cancelBtn',
                      textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                    child: CustomTextLabel(
                      text: (_auth.currentUser != null) ? 'yesLbl' : 'logoutLbl',
                      textStyle: Theme.of(this.context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      (_auth.currentUser != null) ? proceedToDeleteProfile() : askToLoginAgain();
                    })
              ],
            );
          });
        });
  }

  askToLoginAgain() {
    showSnackBar(UiUtils.getTranslatedLabel(context, 'loginReqMsg'), context);
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }

  proceedToDeleteProfile() async {
    //delete user from firebase
    try {
      await _auth.currentUser!.delete().then((value) {
        //delete user prefs from App-local
        context.read<DeleteUserCubit>().setDeleteUser(userId: context.read<AuthCubit>().getUserId(), context: context).then((value) {
          showSnackBar(value["message"], context);
          for (int i = 0; i < AuthProvider.values.length; i++) {
            if (AuthProvider.values[i].name == context.read<AuthCubit>().getType()) {
              context.read<AuthCubit>().signOut(AuthProvider.values[i]).then((value) {
                Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
              });
            }
          }
        });
      });
    } on FirebaseAuthException catch (error) {
      if (error.code == "requires-recent-login") {
        for (int i = 0; i < AuthProvider.values.length; i++) {
          if (AuthProvider.values[i].name == context.read<AuthCubit>().getType()) {
            context.read<AuthCubit>().signOut(AuthProvider.values[i]).then((value) {
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
            });
          }
        }
      } else {
        throw showSnackBar('${error.message}', context);
      }
    } catch (e) {
      debugPrint("unable to delete user - ${e.toString()}");
    }
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: appStoreId,
        microsoftStoreId: 'microsoftStoreId',
      );

  userNameContainer() {
    return Padding(
      padding: EdgeInsets.only(top: (email != "") ? 0.0 : 30.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 20,
            width: 20,
            child: Icon(Icons.person_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
          ),
          Padding(
              padding: const EdgeInsetsDirectional.only(start: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomTextLabel(
                      text: 'nameLbl',
                      textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: UiUtils.getColorScheme(context).primaryContainer,
                          )),
                  if (name != "" && name != null) Text(name!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
                ],
              )),
          const Spacer(),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 15),
            child: InkWell(
              child: Icon(Icons.edit_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
              onTap: () {
                //show bottomsheet to edit name
                editNameBottomSheet();
              },
            ),
          )
        ],
      ),
    );
  }

  editNameBottomSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 3.0,
        //it will be closed only when user click On Save button & not by clicking anywhere else in screen
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        enableDrag: false,
        builder: (BuildContext context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
                padding: const EdgeInsetsDirectional.only(bottom: 20.0, top: 5.0, start: 20.0, end: 20.0),
                decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: UiUtils.getColorScheme(context).background),
                child: Form(
                    key: _nameFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                              padding: const EdgeInsetsDirectional.all(10.0),
                              child: CustomTextLabel(
                                text: 'updateName',
                                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: UiUtils.getColorScheme(context).primaryContainer,
                                    ),
                              )),
                          Padding(
                              padding: const EdgeInsetsDirectional.only(top: 10.0),
                              child: TextFormField(
                                autofocus: true,
                                textInputAction: TextInputAction.done,
                                controller: nameC,
                                onSaved: (newVal) {
                                  setState(() {
                                    name = newVal;
                                    nameC!.text = newVal!;
                                  });
                                },
                                validator: (val) => Validators.nameValidation(val!, context),
                                style: Theme.of(this.context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
                                decoration: InputDecoration(
                                  hintText: UiUtils.getTranslatedLabel(context, 'nameLbl'),
                                  hintStyle: Theme.of(this.context).textTheme.titleMedium?.copyWith(color: darkBackgroundColor),
                                  filled: true,
                                  fillColor: UiUtils.getColorScheme(context).background,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6)),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.6), width: 1.5),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 10),
                          BlocListener<UpdateUserCubit, UpdateUserState>(
                              bloc: context.read<UpdateUserCubit>(),
                              listener: (context, state) {
                                if (state is UpdateUserFetchSuccess) {
                                  context.read<AuthCubit>().updateUserName(nameC!.text);
                                  setState(() {
                                    showSnackBar(UiUtils.getTranslatedLabel(context, 'profileUpdateMsg'), context);
                                    Navigator.pop(context);
                                  });
                                }
                                if (state is UpdateUserFetchFailure) {
                                  showSnackBar(state.errorMessage, context);
                                }
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
                                    ),
                                    child: Container(
                                      height: 55.0,
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      alignment: Alignment.center,
                                      child: CustomTextLabel(
                                        text: 'saveLbl',
                                        textStyle: Theme.of(this.context).textTheme.titleLarge?.copyWith(color: secondaryColor, fontWeight: FontWeight.w500, fontSize: 16, letterSpacing: 0.6),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final form = _nameFormKey.currentState;
                                      if (form!.validate()) {
                                        form.save();
                                        context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, name: nameC!.text);
                                      }
                                    },
                                  )))
                        ],
                      ),
                    )))));
  }

  userMobileContainer() {
    return Padding(
        padding: const EdgeInsets.only(top: 7.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 20,
              width: 20,
              child: Icon(Icons.phone_iphone_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
            ),
            Padding(
                padding: const EdgeInsetsDirectional.only(start: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomTextLabel(text: 'mobileLbl', textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
                    Form(
                        key: _formkey1,
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.7,
                            child: TextFormField(
                              readOnly: isEditMono ? false : true,
                              onSaved: (newValue) {
                                setState(() {
                                  mobile = newValue;
                                });
                              },
                              validator: (val) => Validators.mobValidation(val!, context),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                              ),
                              controller: monoC,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
                            ))),
                  ],
                )),
            const Spacer(),
            if (context.read<AuthCubit>().getType() != loginMbl)
              !isEditMono
                  ? InkWell(
                      child: Icon(Icons.edit_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
                      onTap: () {
                        setState(() {
                          isEditMono = true;
                        });
                      },
                    )
                  : BlocListener<UpdateUserCubit, UpdateUserState>(
                      bloc: context.read<UpdateUserCubit>(),
                      listener: (context, state) {
                        if (state is UpdateUserFetchSuccess) {
                          setState(() {
                            mobile = monoC!.text;
                            isEditMono = false;
                            showSnackBar(UiUtils.getTranslatedLabel(context, 'profileUpdateMsg'), context);
                          });
                          context.read<AuthCubit>().updateUserMobile(mobile!);
                        }
                        if (state is UpdateUserFetchFailure) {
                          showSnackBar(state.errorMessage, context);
                        }
                      },
                      child: InkWell(
                        child: Icon(
                          Icons.check_box,
                          size: 20,
                          color: UiUtils.getColorScheme(context).primaryContainer,
                        ),
                        onTap: () {
                          final form = _formkey1.currentState;
                          if (form!.validate()) {
                            form.save();
                            context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, mobile: monoC!.text);
                          }
                        },
                      ))
          ],
        ));
  }

  userEmailContainer() {
    return Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          SizedBox(
            height: 20,
            width: 20,
            child: Icon(Icons.email_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 20.0),
            child: Form(
                key: _formkey2,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.7,
                    child: TextFormField(
                      readOnly: isEditEmail ? false : true,
                      onSaved: (val) {
                        setState(() {
                          email = val;
                        });
                      },
                      validator: (val) => Validators.emailValidation(val!, context),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      controller: emailC,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
                    ))),
          ),
          const Spacer(),
          if (context.read<AuthCubit>().getType() != loginEmail && context.read<AuthCubit>().getType() != loginFb && context.read<AuthCubit>().getType() != loginGmail)
            !isEditEmail
                ? InkWell(
                    child: Icon(Icons.edit_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
                    onTap: () {
                      setState(() {
                        isEditEmail = true;
                      });
                    },
                  )
                : BlocListener<UpdateUserCubit, UpdateUserState>(
                    bloc: context.read<UpdateUserCubit>(),
                    listener: (context, state) {
                      if (state is UpdateUserFetchSuccess) {
                        setState(() {
                          isEditEmail = false;
                          email = emailC!.text;
                          showSnackBar(UiUtils.getTranslatedLabel(context, 'profileUpdateMsg'), context);
                        });
                        context.read<AuthCubit>().updateUserEmail(email!);
                      }
                      if (state is UpdateUserFetchFailure) {
                        showSnackBar(state.errorMessage, context);
                      }
                    },
                    child: InkWell(
                      child: Icon(
                        Icons.check_box,
                        size: 20,
                        color: UiUtils.getColorScheme(context).primaryContainer,
                      ),
                      onTap: () {
                        final form = _formkey2.currentState;
                        if (form!.validate()) {
                          form.save();

                          context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, email: emailC!.text);
                        }
                      },
                    ))
        ]));
  }

  Widget setHeader() {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, authState) {
      if (authState is Authenticated && context.read<AuthCubit>().getUserId() != "0") {
        getUserData();
        return Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Stack(children: [
              BlocConsumer<UpdateUserCubit, UpdateUserState>(
                  bloc: context.read<UpdateUserCubit>(),
                  listener: (context, state) {
                    if (state is UpdateUserFetchSuccess) {
                      //update profile image path
                      context.read<AuthCubit>().updateUserProfileUrl(Hive.box(authBoxKey).get(userProfileKey));
                      profile = context.read<AuthCubit>().getProfile();
                    }
                    if (state is UpdateUserFetchFailure) {
                      showSnackBar(state.errorMessage, context);
                    }
                  },
                  builder: (context, state) {
                    return Container(
                      height: 110,
                      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer)),
                      alignment: Alignment.center,
                      child: (state is UpdateUserFetchInProgress)
                          ? Center(child: showCircularProgress(true, Theme.of(context).primaryColor))
                          : ClipOval(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: (profile!.toString().trim().isNotEmpty || profile != null)
                                  ? Image.network(
                                      profile!,
                                      fit: BoxFit.fill,
                                      width: 80,
                                      height: 80,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.person);
                                      },
                                    )
                                  : Icon(
                                      Icons.person,
                                      color: UiUtils.getColorScheme(context).primaryContainer,
                                    ),
                            ),
                    );
                  }),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                      onTap: () async {
                        showUploadImageBottomsheet(context: context, onCamera: getFromCamera, onGallery: _getFromGallery);
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer)),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: UiUtils.getColorScheme(context).primaryContainer,
                              size: 20,
                            )),
                      )))
            ]),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20),
            width: double.infinity,
            color: Colors.transparent,
            height: email != ""
                ? MediaQuery.of(context).size.height / 8
                : name != ""
                    ? MediaQuery.of(context).size.height / 8
                    : MediaQuery.of(context).size.height / 8.5,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (name != "" && name != null) userNameContainer(),
                  if (mobile != "" && mobile != null) userMobileContainer(),
                  if (email != "" && email != null) userEmailContainer(),
                ],
              ),
            ),
          ),
        ]);
      } else {
        return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          //For Guest User
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer)),
              alignment: Alignment.center,
              child: Icon(
                Icons.person,
                size: 50.0,
                color: UiUtils.getColorScheme(context).primaryContainer,
              ),
            ),
          ),
          Container(
              padding: const EdgeInsetsDirectional.only(bottom: 12.0, start: 12, end: 12, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextLabel(
                        text: 'plzLbl',
                        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: UiUtils.getColorScheme(context).primaryContainer,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CustomTextLabel(
                            text: 'loginBtn',
                            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              Navigator.of(context).pushNamed(Routes.login);
                            });
                          });
                        },
                      ),
                      CustomTextLabel(
                        text: 'firstAccLbl',
                        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: UiUtils.getColorScheme(context).primaryContainer,
                            ),
                      ),
                    ],
                  ),
                  CustomTextLabel(
                    text: 'allFunLbl',
                    textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: UiUtils.getColorScheme(context).primaryContainer,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ],
              )),
        ]);
      }
    });
  }

  //set image camera
  getFromCamera() async {
    try {
      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        Navigator.of(context).pop(); //pop dialog
        setState(() {
          image = File(pickedFile.path);
        });
        context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, filePath: image!.path);
      }
    } catch (e) {
      debugPrint("camera-err-${e.toString()}");
    }
  }

// set image gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        Navigator.of(context).pop(); //pop dialog
      });
      context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, filePath: image!.path);
    }
  }

  Widget setBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
          padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: Theme.of(context).colorScheme.background),
          child: ScrollConfiguration(
            behavior: GlobalScrollBehavior(),
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsetsDirectional.only(top: 10.0),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    setDrawerItem('darkModeLbl', Icons.swap_horizontal_circle, true, false, true, 0),
                    setDrawerItem('notificationLbl', Icons.notifications_rounded, true, false, true, 1),
                    setDrawerItem('changeLang', Icons.g_translate_rounded, false, true, false, 2),
                    if (context.read<AuthCubit>().getUserId() != "0") setDrawerItem('bookmarkLbl', Icons.bookmarks_rounded, false, true, false, 3),
                    if (context.read<AuthCubit>().getUserId() != "0" && context.read<AuthCubit>().getRole() != "0") setDrawerItem('createNewsLbl', Icons.add_box_outlined, false, true, false, 4),
                    if (context.read<AuthCubit>().getUserId() != "0" && context.read<AuthCubit>().getRole() != "0") setDrawerItem('manageNewsLbl', Icons.edit_note, false, true, false, 5),
                    if (context.read<AuthCubit>().getUserId() != "0") setDrawerItem('managePreferences', Icons.thumbs_up_down_rounded, false, true, false, 6),
                    pagesBuild(),
                    setDrawerItem('rateUs', Icons.stars_sharp, false, true, false, 8),
                    setDrawerItem('shareApp', Icons.share_rounded, false, true, false, 9),
                    if (context.read<AuthCubit>().getUserId() != "0") setDrawerItem('logoutLbl', Icons.logout_rounded, false, true, false, 10),
                    if (context.read<AuthCubit>().getUserId() != "0") setDrawerItem('deleteAcc', Icons.delete_forever_rounded, false, true, false, 11),
                  ],
                );
              },
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
      children: [
        SingleChildScrollView(
            padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 25.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                setHeader(),
                setBody(),
              ],
            )),
      ],
    )));
  }
}
