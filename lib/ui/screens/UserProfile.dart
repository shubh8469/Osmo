// ignore_for_file: file_names

// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customAppBar.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/errorContainerWidget.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/widgets/shimmerNewsList.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';

import '../../cubits/Auth/updateUserCubit.dart';
import '../../utils/hiveBoxKeys.dart';
import '../widgets/SnackBarWidget.dart';
import '../widgets/showUploadImageBottomsheet.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  late final ScrollController _controller = ScrollController()
    ..addListener(hasMoreUserNotiScrollListener);

  // File? image;
  String? name, mobile, email, profile;
  TextEditingController? nameC, monoC, emailC = TextEditingController();

  @override
  void initState() {
    super.initState();
    getBookMark();
  }

  getBookMark() async {
    if (await InternetConnectivity.isNetworkAvailable()) {
      Future.delayed(Duration.zero, () {
        context.read<BookmarkCubit>().getBookmark(
              context: context,
              langId: context.read<AppLocalizationCubit>().state.id,
              userId: context.read<AuthCubit>().getUserId(),
            );
      });
    }
  }

  void hasMoreUserNotiScrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (context.read<BookmarkCubit>().hasMoreBookmark()) {
        context.read<BookmarkCubit>().getMoreBookmark(
            context: context,
            langId: context.read<AppLocalizationCubit>().state.id,
            userId: context.read<AuthCubit>().getUserId());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getUserData() {
    if (context.read<AuthCubit>().getUserId() != "0") {
      nameC =
          TextEditingController(text: context.read<AuthCubit>().getUserName());
      name = context.read<AuthCubit>().getUserName();
      monoC =
          TextEditingController(text: context.read<AuthCubit>().getMobile());
      mobile = context.read<AuthCubit>().getMobile();
      emailC =
          TextEditingController(text: context.read<AuthCubit>().getEmail());
      email = context.read<AuthCubit>().getEmail();
      profile = context.read<AuthCubit>().getProfile();
    }
  }

  Widget setHeader() {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, authState) {
      if (authState is Authenticated &&
          context.read<AuthCubit>().getUserId() != "0") {
        getUserData();
        return Container(
          decoration: BoxDecoration(
              // border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)),
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.89,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 25),
                      child: BlocConsumer<UpdateUserCubit, UpdateUserState>(
                          bloc: context.read<UpdateUserCubit>(),
                          listener: (context, state) {
                            if (state is UpdateUserFetchSuccess) {
                              //update profile image path
                              context.read<AuthCubit>().updateUserProfileUrl(
                                  Hive.box(authBoxKey).get(userProfileKey));
                              profile = context.read<AuthCubit>().getProfile();
                            }
                            if (state is UpdateUserFetchFailure) {
                              showSnackBar(state.errorMessage, context);
                            }
                          },
                          builder: (context, state) {
                            return Container(
                              decoration: BoxDecoration(
                                  // border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer),
                                  color: Colors.white),
                              child: (state is UpdateUserFetchInProgress)
                                  ? Center(
                                      child: showCircularProgress(
                                          true, Theme.of(context).primaryColor))
                                  //     : ClipOval(
                                  //       clipBehavior: Clip.antiAliasWithSaveLayer,
                                  //       child: (profile!.toString().trim().isNotEmpty || profile != null)
                                  //       ? Image.network(
                                  //           profile!,
                                  //           fit: BoxFit.fill,
                                  //           width: 80,
                                  //           height: 80,
                                  //           filterQuality: FilterQuality.high,
                                  //           errorBuilder: (context, error, stackTrace) {
                                  //           return const Icon(Icons.person);
                                  //       },
                                  //     )
                                  //       : Icon(
                                  //     Icons.person,
                                  //     color: UiUtils.getColorScheme(context).primaryContainer,
                                  //   ),
                                  // ),
                                  : ClipOval(
                                      child: FadeInImage(
                                          fadeInDuration:
                                              const Duration(milliseconds: 150),
                                          image: NetworkImage(
                                            profile!,
                                          ),
                                          // width: width! * 0.13,
                                          // height: height! * 0.03,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.fill,
                                          placeholder: AssetImage(
                                              UiUtils.getImagePath(
                                                  "placeholder.png")),
                                          imageErrorBuilder:
                                              ((context, error, stackTrace) {
                                            return ClipOval(
                                              child: Container(
                                                color: Colors.grey.shade200,
                                                child: Image.asset(
                                                  UiUtils.getImagePath(
                                                      "placeholder.png"),
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            );
                                          }),
                                          placeholderErrorBuilder:
                                              ((context, error, stackTrace) {
                                            return Image.asset(
                                              UiUtils.getImagePath(
                                                  "placeholder.png"),
                                              //  width: width ?? 100,
                                              // height: height ?? 100,
                                              fit: BoxFit.contain,
                                            );
                                          })),
                                    ),
                            );
                          }),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.08,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  nameC!.text,
                                  style: GoogleFonts.aBeeZee(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w700,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.023),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(emailC!.text,
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.grey,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.014)),
                              ],
                            ),
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.04,
                                child: VerticalDivider(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  thickness: 2,
                                  color: Colors.orange.shade300,
                                )),
                            Column(
                              children: [
                                Text(
                                  "9",
                                  style: GoogleFonts.aBeeZee(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w700,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.023),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text("Age",
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.grey,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.014)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(15)),
                          width: MediaQuery.of(context).size.width * 0.48,
                          height: MediaQuery.of(context).size.height * 0.032,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text("Edit"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    MaterialStateColor.resolveWith((states) {
                                  return Colors.orange.shade300;
                                }),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ]),
        );
      } else {
        return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          //For Guest User
          // Padding(
          //   padding: const EdgeInsets.only(top: 10.0),
          //   child: Container(
          //     margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          //     padding: const EdgeInsets.all(20),
          //     decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer)),
          //     alignment: Alignment.center,
          //     child: Icon(
          //       Icons.person,
          //       size: 50.0,
          //       color: UiUtils.getColorScheme(context).primaryContainer,
          //     ),
          //   ),
          // ),
          // Container(
          //     padding: const EdgeInsetsDirectional.only(bottom: 12.0, start: 12, end: 12, top: 12),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Row(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             CustomTextLabel(
          //               text: 'plzLbl',
          //               textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          //                 color: UiUtils.getColorScheme(context).primaryContainer,
          //                 overflow: TextOverflow.ellipsis,
          //               ),
          //             ),
          //             InkWell(
          //               child: Padding(
          //                 padding: const EdgeInsets.symmetric(horizontal: 4),
          //                 child: CustomTextLabel(
          //                   text: 'loginBtn',
          //                   textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
          //                 ),
          //               ),
          //               onTap: () {
          //                 Future.delayed(const Duration(milliseconds: 500), () {
          //                   setState(() {
          //                     Navigator.of(context).pushNamed(Routes.login);
          //                   });
          //                 });
          //               },
          //             ),
          //             CustomTextLabel(
          //               text: 'firstAccLbl',
          //               textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          //                 color: UiUtils.getColorScheme(context).primaryContainer,
          //               ),
          //             ),
          //           ],
          //         ),
          //         CustomTextLabel(
          //           text: 'allFunLbl',
          //           textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          //             color: UiUtils.getColorScheme(context).primaryContainer,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //         ),
          //       ],
          //     )),
        ]);
      }
    });
  }

  userNameContainer() {
    return Padding(
      padding: EdgeInsets.only(top: (email != "") ? 0.0 : 30.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 20,
            width: 20,
            child: Icon(Icons.person_rounded,
                color: UiUtils.getColorScheme(context).primaryContainer),
          ),
          Padding(
              padding: const EdgeInsetsDirectional.only(start: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomTextLabel(
                      text: 'nameLbl',
                      textStyle:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: UiUtils.getColorScheme(context)
                                    .primaryContainer,
                              )),
                  if (name != "" && name != null)
                    Text(name!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: UiUtils.getColorScheme(context)
                                    .primaryContainer)),
                ],
              )),
          const Spacer(),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 15),
            child: InkWell(
              child: Icon(Icons.edit_rounded,
                  color: UiUtils.getColorScheme(context).primaryContainer),
              onTap: () {
                //show bottomsheet to edit name
                // editNameBottomSheet();
              },
            ),
          )
        ],
      ),
    );
  }
  // userMobileContainer() {
  //   return Padding(
  //       padding: const EdgeInsets.only(top: 7.0),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           SizedBox(
  //             height: 20,
  //             width: 20,
  //             child: Icon(Icons.phone_iphone_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
  //           ),
  //           Padding(
  //               padding: const EdgeInsetsDirectional.only(start: 20.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: <Widget>[
  //                   CustomTextLabel(text: 'mobileLbl', textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer)),
  //                   Form(
  //                       key: _formkey1,
  //                       child: SizedBox(
  //                           width: MediaQuery.of(context).size.width / 1.7,
  //                           child: TextFormField(
  //                             readOnly: isEditMono ? false : true,
  //                             onSaved: (newValue) {
  //                               setState(() {
  //                                 mobile = newValue;
  //                               });
  //                             },
  //                             validator: (val) => Validators.mobValidation(val!, context),
  //                             decoration: const InputDecoration(
  //                               border: InputBorder.none,
  //                               focusedBorder: InputBorder.none,
  //                               enabledBorder: InputBorder.none,
  //                               errorBorder: InputBorder.none,
  //                               disabledBorder: InputBorder.none,
  //                               isDense: true,
  //                               contentPadding: EdgeInsets.all(0),
  //                             ),
  //                             controller: monoC,
  //                             style: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
  //                           ))),
  //                 ],
  //               )),
  //           const Spacer(),
  //           if (context.read<AuthCubit>().getType() != loginMbl)
  //             !isEditMono
  //                 ? InkWell(
  //               child: Icon(Icons.edit_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
  //               onTap: () {
  //                 setState(() {
  //                   isEditMono = true;
  //                 });
  //               },
  //             )
  //                 : BlocListener<UpdateUserCubit, UpdateUserState>(
  //                 bloc: context.read<UpdateUserCubit>(),
  //                 listener: (context, state) {
  //                   if (state is UpdateUserFetchSuccess) {
  //                     setState(() {
  //                       mobile = monoC!.text;
  //                       isEditMono = false;
  //                       showSnackBar(UiUtils.getTranslatedLabel(context, 'profileUpdateMsg'), context);
  //                     });
  //                     context.read<AuthCubit>().updateUserMobile(mobile!);
  //                   }
  //                   if (state is UpdateUserFetchFailure) {
  //                     showSnackBar(state.errorMessage, context);
  //                   }
  //                 },
  //                 child: InkWell(
  //                   child: Icon(
  //                     Icons.check_box,
  //                     size: 20,
  //                     color: UiUtils.getColorScheme(context).primaryContainer,
  //                   ),
  //                   onTap: () {
  //                     final form = _formkey1.currentState;
  //                     if (form!.validate()) {
  //                       form.save();
  //                       context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, mobile: monoC!.text);
  //                     }
  //                   },
  //                 ))
  //         ],
  //       ));
  // }
  // userEmailContainer() {
  //   return Padding(
  //       padding: const EdgeInsets.only(top: 5.0),
  //       child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
  //         SizedBox(
  //           height: 20,
  //           width: 20,
  //           child: Icon(Icons.email_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
  //         ),
  //         Padding(
  //           padding: const EdgeInsetsDirectional.only(start: 20.0),
  //           child: Form(
  //               key: _formkey2,
  //               child: SizedBox(
  //                   width: MediaQuery.of(context).size.width / 1.7,
  //                   child: TextFormField(
  //                     readOnly: isEditEmail ? false : true,
  //                     onSaved: (val) {
  //                       setState(() {
  //                         email = val;
  //                       });
  //                     },
  //                     validator: (val) => Validators.emailValidation(val!, context),
  //                     decoration: const InputDecoration(
  //                       border: InputBorder.none,
  //                       focusedBorder: InputBorder.none,
  //                       enabledBorder: InputBorder.none,
  //                       errorBorder: InputBorder.none,
  //                       disabledBorder: InputBorder.none,
  //                       isDense: true,
  //                       contentPadding: EdgeInsets.all(0),
  //                     ),
  //                     controller: emailC,
  //                     style: Theme.of(context).textTheme.titleMedium?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer),
  //                   ))),
  //         ),
  //         const Spacer(),
  //         if (context.read<AuthCubit>().getType() != loginEmail && context.read<AuthCubit>().getType() != loginFb && context.read<AuthCubit>().getType() != loginGmail)
  //           !isEditEmail
  //               ? InkWell(
  //             child: Icon(Icons.edit_rounded, color: UiUtils.getColorScheme(context).primaryContainer),
  //             onTap: () {
  //               setState(() {
  //                 isEditEmail = true;
  //               });
  //             },
  //           )
  //               : BlocListener<UpdateUserCubit, UpdateUserState>(
  //               bloc: context.read<UpdateUserCubit>(),
  //               listener: (context, state) {
  //                 if (state is UpdateUserFetchSuccess) {
  //                   setState(() {
  //                     isEditEmail = false;
  //                     email = emailC!.text;
  //                     showSnackBar(UiUtils.getTranslatedLabel(context, 'profileUpdateMsg'), context);
  //                   });
  //                   context.read<AuthCubit>().updateUserEmail(email!);
  //                 }
  //                 if (state is UpdateUserFetchFailure) {
  //                   showSnackBar(state.errorMessage, context);
  //                 }
  //               },
  //               child: InkWell(
  //                 child: Icon(
  //                   Icons.check_box,
  //                   size: 20,
  //                   color: UiUtils.getColorScheme(context).primaryContainer,
  //                 ),
  //                 onTap: () {
  //                   final form = _formkey2.currentState;
  //                   if (form!.validate()) {
  //                     form.save();
  //
  //                     context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, email: emailC!.text);
  //                   }
  //                 },
  //               ))
  //       ]));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: setCustomAppBar(height: 45, isBackBtn: true, label: 'bookmarkLbl', context: context, horizontalPad: 15, isConvertText: true),
        body: Stack(
      children: [
        // Image.asset(
        //   UiUtils.getImagePath("background.png"),
        //   height: MediaQuery.of(context).size.height,
        //   width: MediaQuery.of(context).size.width,
        //   fit: BoxFit.fill,
        // ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 25,
              ),
              ListTile(
                leading: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Icon(
                      Icons.arrow_back,
                      color: darkSecondaryColor,
                    )),
                // titleSpacing: 0.0,
                // centerTitle: true,
                // backgroundColor: Colors.transparent,
                title: Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 0),
                    child: CustomTextLabel(
                      text: 'User Profiles',
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                              color: darkSecondaryColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              fontSize: 25),
                    ),
                  ),
                ),
                trailing: SizedBox(
                  width: 10,
                ),
                // actions: [skipBtn()],
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                    right: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: setHeader()),

              SizedBox(
                height: 30,
              ),

              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05,
                ),
                child: Text(
                  "Become A Premium Member",
                  style: GoogleFonts.aBeeZee(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              // Subscribe(context),

              RenewSubs(context),

              // Subscribed(context),

              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05,
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.053,
                  width: MediaQuery.of(context).size.width * 0.89,
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    "Favourites",
                    style: GoogleFonts.aBeeZee(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).size.height * 0.023),
                  ),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
                  child: context.read<AuthCubit>().getUserId() != "0"
                      ? BlocBuilder<BookmarkCubit, BookmarkState>(
                          builder: (context, state) {
                            if (state is BookmarkFetchSuccess &&
                                state.bookmark.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 15.0,
                                    end: 15.0,
                                    top: 0.0,
                                    bottom: 10.0),
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    getBookMark();
                                  },
                                  child: GridView.count(
                                    // scrollDirection: Axis.vertical,
                                    controller: _controller,
                                    crossAxisCount: 2,
                                    mainAxisSpacing:
                                        MediaQuery.of(context).size.height / 40,
                                    crossAxisSpacing:
                                        MediaQuery.of(context).size.width / 40,
                                    childAspectRatio: 0.8,
                                    // physics: const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.only(
                                        top: 25,
                                        bottom:
                                            MediaQuery.of(context).size.height /
                                                10.0,
                                        left: 10,
                                        right: 10),
                                    shrinkWrap: true,
                                    children: List.generate(
                                        state.bookmark.length, (index) {
                                      return _buildBookmarkContainer(
                                        model: state.bookmark[index],
                                        hasMore: state.hasMore,
                                        hasMoreBookFetchError:
                                            state.hasMoreFetchError,
                                        index: index,
                                        totalCurrentBook: state.bookmark.length,
                                      );
                                    }),
                                  ),
                                ),
                              );
                            } else if (state is BookmarkFetchFailure ||
                                ((state is! BookmarkFetchInProgress))) {
                              if (state is BookmarkFetchFailure) {
                                return ErrorContainerWidget(
                                    errorMsg: (state.errorMessage.contains(
                                            ErrorMessageKeys.noInternet))
                                        ? UiUtils.getTranslatedLabel(
                                            context, 'internetmsg')
                                        : state.errorMessage,
                                    onRetry: getBookMark());
                              } else {
                                return const Center(
                                    child: CustomTextLabel(
                                  text: 'bookmarkNotAvail',
                                  textAlign: TextAlign.center,
                                ));
                              }
                            }
                            //default/Processing state
                            return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10.0, left: 10.0, right: 10.0),
                                child: shimmerNewsList(context));
                          },
                        )
                      : loginMsg()),
            ],
          ),
        ),
      ],
    ));
  }

  Center Subscribed(BuildContext context) {
    return Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05,
                ),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.115,
                      width: MediaQuery.of(context).size.width * 0.89,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                  UiUtils.getImagePath("premiem.png")),
                              Column(
                                children: [
                                  Text(
                                    "You Are A Premium Member",
                                    style: GoogleFonts.aBeeZee(
                                        color: secondaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.0214),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width *
                                            0.014,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height:
                                        MediaQuery.of(context).size.height *
                                            0.033,
                                    // width: MediaQuery.of(context).size.width * 0.5,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade500,
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                      child: Text(
                                        " Next Renewal : 12/03/2024 ",
                                        style: GoogleFonts.saira(
                                            color: secondaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.015),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.014,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
  }

  Center Subscribe(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.186,
              width: MediaQuery.of(context).size.width * 0.89,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Colors.pink.shade200],
                      tileMode: TileMode.clamp),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(UiUtils.getImagePath("premiem black.png")),
                      Column(
                        children: [
                          Text(
                            "Premium Membership",
                            style: GoogleFonts.aBeeZee(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.0215),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.014,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height * 0.033,
                            // width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                                color: Colors.pink.shade100,
                                borderRadius: BorderRadius.circular(25)),
                            child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Text(
                                "Your free trial: 29 Days",
                                style: GoogleFonts.saira(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.015),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.014,
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: Divider(
                        color: Colors.grey.shade100.withOpacity(0.5),
                        thickness: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.017,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // SizedBox(width: MediaQuery.of(context).size.width * 0.08,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Yearly",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.aBeeZee(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018,
                                letterSpacing: 0.2),
                          ),
                          Text(
                            "Rs.449/",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.saira(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022),
                          ),
                        ],
                      ),

                      Container(
                        height: MediaQuery.of(context).size.height * 0.044,
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              backgroundColor: Colors.black),
                          child: Text("Subscribe Now",
                              style: GoogleFonts.aBeeZee(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.018,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Center RenewSubs(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.186,
              width: MediaQuery.of(context).size.width * 0.89,
              decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(UiUtils.getImagePath("premiem.png")),
                      Column(
                        children: [
                          Text(
                            "Premium Membership",
                            style: GoogleFonts.aBeeZee(
                                color: secondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.0215),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.014,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height * 0.033,
                            // width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(25)),
                            child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Text(
                                "Premium Ends in : 30 Days",
                                style: GoogleFonts.saira(
                                    color: secondaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.015),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.014,
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: Divider(
                        color: Colors.grey.shade100.withOpacity(0.5),
                        thickness: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.017,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // SizedBox(width: MediaQuery.of(context).size.width * 0.08,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Yearly",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.aBeeZee(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018,
                                letterSpacing: 0.2),
                          ),
                          Text(
                            "Rs.449/",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.saira(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.022),
                          ),
                        ],
                      ),

                      Container(
                        height: MediaQuery.of(context).size.height * 0.044,
                        width: MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.purple.shade300,
                              Colors.pink.shade200
                            ], tileMode: TileMode.clamp),
                            borderRadius: BorderRadius.circular(20)),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text("Renew",
                              style: GoogleFonts.aBeeZee(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.018,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBookmarkContainer({
    required NewsModel model,
    required int index,
    required int totalCurrentBook,
    required bool hasMoreBookFetchError,
    required bool hasMore,
  }) {
    if (index == totalCurrentBook - 1 && index != 0) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreBookFetchError) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: IconButton(
                  onPressed: () {
                    context.read<BookmarkCubit>().getMoreBookmark(
                        context: context,
                        langId: context.read<AppLocalizationCubit>().state.id,
                        userId: context.read<AuthCubit>().getUserId());
                  },
                  icon: Icon(
                    Icons.error,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          );
        } else {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0),
                  child: showCircularProgress(
                      true, Theme.of(context).primaryColor)));
        }
      }
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 15.0),
      child: InkWell(
        child: Stack(
          children: [
            Container(
              // color: Col,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CustomNetworkImage(
                      networkImageUrl: model.image!,
                      width: double.maxFinite,
                      fit: BoxFit.fill,
                      isVideo: false)),
            ),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 0,
                start: 0,
                end: 0,
                height: MediaQuery.of(context).size.height * 0.12,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            darkSecondaryColor.withOpacity(0.01),
                            darkSecondaryColor.withOpacity(0.75)
                          ]).createShader(bounds);
                    },
                    blendMode: BlendMode.overlay,
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 10, end: 10),
                          child: Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  UiUtils.convertToAgo(
                                      context, DateTime.parse(model.date!), 0)!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: Colors.black,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      model.title!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              height: 1.0,
                                              letterSpacing: 0.5),
                                      maxLines: 3,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ],
                            ),
                          )),
                    ),
                  ),
                )),
          ],
        ),
        onTap: () async {
          Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {
            "model": model,
            "isFromBreak": false,
            "fromShowMore": false
          });
        },
      ),
    );
  }

//user not login then show this function used to navigate login screen
  Widget loginMsg() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextLabel(
              text: 'bookmarkLogin',
              textStyle: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            InkWell(
                child: CustomTextLabel(
                  text: 'loginNowLbl',
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.login);
                }),
          ],
        ));
  }
}
