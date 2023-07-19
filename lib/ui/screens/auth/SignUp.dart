// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:news/ui/screens/auth/Widgets/SetAge.dart';
// import 'package:news/utils/hiveBoxKeys.dart';
// import 'package:path_provider/path_provider.dart';
//
// import '../../../app/routes.dart';
// import '../../../cubits/Auth/authCubit.dart';
// import '../../../cubits/Auth/soicalSignUpCubit.dart';
// import '../../../cubits/Auth/updateFCMCubit.dart';
// import '../../../cubits/settingCubit.dart';
// import '../../../utils/internetConnectivity.dart';
// import '../../../utils/uiUtils.dart';
// import '../../widgets/SnackBarWidget.dart';
// import 'Widgets/setEmail.dart';
// import 'Widgets/setName.dart';
// import 'dart:io';
//
// class SignUp extends StatefulWidget {
//    SignUp({super.key});
//
//    // final String mobile;
//    // final AuthProvider authProvider;
//    // final String firebaseId;
//
//   @override
//   State<SignUp> createState() => _SignUpState();
// }
//
// class _SignUpState extends State<SignUp> {
//
//   @override
//   void initState(){
//     selectedDate = DateFormat("dd/MM/yyyy").format(DateTime(2000));
//     assignAllTextController();
//   }
//
//   List<String> Images = [
//     "1.png",
//     "2.png",
//     "3.png",
//     "4.png",
//     "5.png",
//     "6.png",
//     "7.png",
//     "8.png",
//   ];
//
//   String? selectedDate;
//
//   FocusNode emailFocus = FocusNode();
//   FocusNode passFocus = FocusNode();
//   FocusNode nameFocus = FocusNode();
//   FocusNode emailSFocus = FocusNode();
//   FocusNode AgeFocus = FocusNode();
//
//   double? height,width;
//
//   TextEditingController? emailC, passC, sEmailC, sPassC, sNameC, sConfPassC, ageC;
//
//   assignAllTextController() {
//     emailC = TextEditingController();
//     passC = TextEditingController();
//     sEmailC = TextEditingController();
//     sPassC = TextEditingController();
//     sNameC = TextEditingController();
//     ageC = TextEditingController();
//     sConfPassC = TextEditingController();
//   }
//
//   final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
//
//
//   int selected = -1;
//
//   @override
//   Widget build(BuildContext context) {
//     width = MediaQuery.of(context).size.width;
//     height = MediaQuery.of(context).size.height;
//     return BlocConsumer<SocialSignUpCubit, SocialSignUpState>(
//       bloc: context.read<SocialSignUpCubit>(),
//       listener: (context, state) async {
//         if (state is SocialSignUpFailure) {
//           showSnackBar(
//             state.errorMessage,
//             context,
//           );
//         }
//         if (state is SocialSignUpSuccess) {
//           context.read<AuthCubit>().checkAuthStatus();
//           if (context.read<AuthCubit>().getStatus() == "0") {
//             showSnackBar(UiUtils.getTranslatedLabel(context, 'deactiveMsg'), context);
//           } else {
//             FirebaseMessaging.instance.getToken().then((token) async {
//               if (token != context.read<SettingsCubit>().getSettings().token && token != null) {
//                 context.read<UpdateFcmIdCubit>().updateFcmId(userId: context.read<AuthCubit>().getUserId(), fcmId: token, context: context);
//               }
//             });
//             if (context.read<AuthCubit>().getIsFirstLogin() == "1") {
//               Navigator.of(context).pushNamedAndRemoveUntil(Routes.managePref, (route) => false, arguments: {"from": 2});
//             }
//             // else if (widget.isFromApp == true) {
//             //   Navigator.pop(context);
//             // }
//             else {
//               // print("---->> ${state.authModel.name}");
//               if(state.authModel.name!.isEmpty || state.authModel.name == null){
//                 print("hhhhh--> ${state.authModel.name}");
//                 // Navigator.pushNamedAndRemoveUntil(context, Routes.signUp, (route) => false);
//               }
//               else
//                 Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
//             }
//           }
//         }
//       },
//       builder: (context, state){
//         return SafeArea(
//           child: Scaffold(
//             body: Stack(
//               children: [
//                 // Image.asset(
//                 //   UiUtils.getImagePath("background.png"),
//                 //   height: double.infinity,
//                 //   width: double.infinity,
//                 //   fit: BoxFit.fill,
//                 // ),
//                 SingleChildScrollView(
//                   child: Form(
//                     key: _formkey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 20,),
//                         ListTile(
//                             leading: InkWell(
//                                 onTap: () => Navigator.of(context).pop(),
//                                 splashColor: Colors.transparent,
//                                 highlightColor: Colors.transparent,
//                                 child: Icon(Icons.arrow_back, color: Colors.grey.shade800,)
//                             ),
//                             title: Center(
//                               child: Padding(
//                                 padding: const EdgeInsetsDirectional.only(start: 0),
//                                 child: Text("Edit Profile", style: GoogleFonts.aBeeZee(color: Colors.grey.shade800, fontSize: MediaQuery.of(context).size.height * 0.028, fontWeight: FontWeight.w600),),
//                               ),
//                             ),
//                             trailing: Container(
//                               width: 20,
//                             )
//                           // actions: [skipBtn()],
//                         ),
//
//                         Padding(
//                           padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
//                           child: Text("Choose Avatar", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.023),),
//                         ),
//
//                         Center(
//                           child: Container(
//                             height: MediaQuery.of(context).size.height * 0.17,
//                             width: MediaQuery.of(context).size.width * 0.94,
//                             decoration: BoxDecoration(
//                               // border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer),
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10)
//                             ),
//                             // child: Wrap(
//                             //   children: List.generate(Images.length, (index) => Avatars(index)),
//                             // ),
//                             child: GridView.count(
//                               crossAxisCount: 4,
//                               childAspectRatio: 1.55,
//                               children: List.generate(Images.length, (index) => Avatars(index)),
//                             ),
//                           ),
//                         ),
//
//                         Padding(
//                           padding: EdgeInsets.only(left: 20, top: 30, bottom: 0),
//                           child: Text("Name", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.023),),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
//                           child: SetName(currFocus: nameFocus, nextFocus: AgeFocus, nameC: sNameC!, name: sNameC!.text),
//                         ),
//
//
//                         Padding(
//                           padding: EdgeInsets.only(left: 20, top: 30, bottom: 0),
//                           child: Text("Age", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.023),),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
//                           child: SetAge(currFocus: AgeFocus, nextFocus: emailFocus, AgeC: ageC!, name: ageC!.text,
//                             datePicker: dateSelector,),
//                         ),
//
//
//                         Padding(
//                           padding: EdgeInsets.only(left: 20, top: 30, bottom: 0),
//                           child: Text("Email Id", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.023),),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
//                           child: SetEmail(currFocus: emailSFocus, nextFocus: emailSFocus, emailC: sEmailC!, email: sEmailC!.text, topPad: 20),
//                         ),
//
//                         SizedBox(height: 25,),
//                         Center(
//                           child: Container(
//                             decoration: BoxDecoration(
//                                 color: Colors.grey.shade700,
//                                 borderRadius: BorderRadius.circular(30)
//                             ),
//                             width: MediaQuery.of(context).size.width * 0.8,
//                             height: MediaQuery.of(context).size.height * 0.05,
//                             child: ElevatedButton(
//                               onPressed: () async {
//
//                                 // print("---->>> ${context.read<AuthCubit>().FirebaseID()}");
//                                 // context.read<AuthCubit>().
//
//                                 FocusScope.of(context).unfocus(); //dismiss keyboard
//                                 final form = _formkey.currentState;
//                                 if (form!.validate()) {
//                                   form.save();
//                                   if (await InternetConnectivity.isNetworkAvailable()) {
//                                     print("ssss--> ${sEmailC!.text} -- ${sNameC!.text}");
//                                     context.read<SocialSignUpCubit>().socialSignUpUserSignUp(email: sEmailC!.text.trim(), displayName: sNameC!.text, context: context, mobile: context.read<AuthCubit>().getMobile(), firebaseId: "JQwsEAv6u9TMyTkr5VZTkiAGwvm2");//context.read<AuthCubit>().FirebaseID());
//                                   } else {
//                                     showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
//                                   }
//                                 }
//                               },
//
//                               child: Text("Save" ,style:  TextStyle(fontSize: MediaQuery.of(context).size.height * 0.027,),),
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: MaterialStateColor.resolveWith((states) {
//                                     return Colors.orange.shade600;
//                                   }),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(30)
//                                   )
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: 20,),
//                         Center(
//                           child: Container(
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(30)
//                             ),
//                             width: MediaQuery.of(context).size.width * 0.8,
//                             height: MediaQuery.of(context).size.height * 0.05,
//                             child: ElevatedButton(
//                               onPressed: () {  },
//
//                               child: Text("Cancel" ,style:  TextStyle( color: Colors.orange.shade600 ,fontSize: MediaQuery.of(context).size.height * 0.027,),),
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: MaterialStateColor.resolveWith((states) {
//                                     return Colors.white;
//                                   }),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(30)
//                                   )
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//       // child:
//     );
//   }
//
//   Future<void> dateSelector() async {
//     DateTime? date = await showDatePicker(
//         context: context,
//         initialDate: DateTime(2000),
//         firstDate: DateTime(1975),
//         lastDate: DateTime(2013),
//         builder: (BuildContext context, Widget? child){
//           return Theme(
//               data: ThemeData.light().copyWith(
//                   colorScheme: ColorScheme.light(
//                     primary: Colors.orange,
//                     onPrimary: Colors.white,
//                     surface: Colors.pink,
//                     onSurface: Colors.black54,
//                   )
//               ),
//               child: child!
//           );
//         }
//     );
//     setState(() {
//       selectedDate = DateFormat("dd-MM-yyyy").format(date!);
//       ageC!.text = selectedDate!;
//     });
//   }
//
//   Future<File> getImageFileFromAssets(String path) async {
//     final byteData = await rootBundle.load('assets/$path');
//
//     final file = File('${(await getTemporaryDirectory()).path}/$path');
//     await file.create(recursive: true);
//     await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//
//     return file;
//   }
//
//
//   Widget Avatars(int index){
//     return InkWell(
//       onTap: () async {
//           selected = index;
//           File f = await getImageFileFromAssets('images/${Images[index]}');
//           XFile file = new XFile(f.path);
//           setState(() {});
//           print("-----> $f ----  ${file.path}");
//
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(4.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: selected == index ? Colors.orange : Colors.transparent,
//             shape: BoxShape.circle
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(2.0),
//             child: CircleAvatar(
//               backgroundColor: Colors.orange,
//               child: ClipOval(
//                   child: Image.asset(UiUtils.getImagePath(Images[index]))
//               ),
//               radius: MediaQuery.of(context).size.height * 0.02,
//             ),
//           ),
//         ),
//       ),
//     );
//     return Image.asset("assets/images/profile/1.png");
//   }
// }


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:news/ui/screens/auth/Widgets/SetAge.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/routes.dart';
import '../../../cubits/Auth/authCubit.dart';
import '../../../cubits/Auth/soicalSignUpCubit.dart';
import '../../../cubits/Auth/updateFCMCubit.dart';
import '../../../cubits/Auth/updateUserCubit.dart';
import '../../../cubits/settingCubit.dart';
import '../../../utils/internetConnectivity.dart';
import '../../../utils/uiUtils.dart';
import '../../widgets/SnackBarWidget.dart';
import 'Widgets/setEmail.dart';
import 'Widgets/setName.dart';
import 'dart:io';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  // final String mobile;
  // final AuthProvider authProvider;
  // final String firebaseId;

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  @override
  void initState(){
    selectedDate = DateFormat("dd/MM/yyyy").format(DateTime(2000));
    assignAllTextController();
  }

  List<String> Images = [
    "1.png",
    "2.png",
    "3.png",
    "4.png",
    "5.png",
    "6.png",
    "7.png",
    "8.png",
  ];

  String? selectedDate;

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode emailSFocus = FocusNode();
  FocusNode AgeFocus = FocusNode();

  double? height,width;

  TextEditingController? emailC, passC, sEmailC, sPassC, sNameC, sConfPassC, ageC;

  assignAllTextController() {
    emailC = TextEditingController();
    passC = TextEditingController();
    sEmailC = TextEditingController();
    sPassC = TextEditingController();
    sNameC = TextEditingController();
    ageC = TextEditingController();
    sConfPassC = TextEditingController();
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();


  int selected = -1;

  bool navigate = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return BlocConsumer<UpdateUserCubit, UpdateUserState>(
      bloc: context.read<UpdateUserCubit>(),
      listener: (context, state) {
        if (state is UpdateUserFetchSuccess) {
          context.read<AuthCubit>().updateUserName(sNameC!.text);
          context.read<AuthCubit>().updateUserEmail(sEmailC!.text);
          //update profile image path
          context.read<AuthCubit>().updateUserProfileUrl(Hive.box(authBoxKey).get(userProfileKey));

          print("finally Success ${context.read<AuthCubit>().getProfile()}");
          // profile = context.read<AuthCubit>().getProfile();
          if(navigate) {
            print("herrrr");
            Navigator.of(context).pushNamedAndRemoveUntil(Routes.managePref, (route) => false, arguments: {"from": 2});
            // Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
          }
        }
        if (state is UpdateUserFetchFailure) {
          showSnackBar(state.errorMessage, context);
        }
      },
      builder: (context, state){
        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                // Image.asset(
                //   UiUtils.getImagePath("background.png"),
                //   height: double.infinity,
                //   width: double.infinity,
                //   fit: BoxFit.fill,
                // ),
                SingleChildScrollView(
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20,),
                        ListTile(
                            leading: InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Icon(Icons.arrow_back, color: Colors.grey.shade800,)
                            ),
                            title: Center(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(start: 0),
                                child: Text("Edit Profile", style: GoogleFonts.aBeeZee(color: Colors.grey.shade800, fontSize: MediaQuery.of(context).size.height * 0.028, fontWeight: FontWeight.w600),),
                              ),
                            ),
                            trailing: Container(
                              width: 20,
                            )
                          // actions: [skipBtn()],
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                          child: Text("Choose Avatar", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.023),),
                        ),

                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.17,
                            width: MediaQuery.of(context).size.width * 0.94,
                            decoration: BoxDecoration(
                              // border: Border.all(color: UiUtils.getColorScheme(context).primaryContainer),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            // child: Wrap(
                            //   children: List.generate(Images.length, (index) => Avatars(index)),
                            // ),
                            child: GridView.count(
                              crossAxisCount: 4,
                              childAspectRatio: 1.55,
                              children: List.generate(Images.length, (index) => Avatars(index)),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 30, bottom: 0),
                          child: Text("Name", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.023),),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
                          child: SetName(currFocus: nameFocus, nextFocus: AgeFocus, nameC: sNameC!, name: sNameC!.text),
                        ),


                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 30, bottom: 0),
                          child: Text("Age", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.023),),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
                          child: SetAge(currFocus: AgeFocus, nextFocus: emailFocus, AgeC: ageC!, name: ageC!.text,
                            datePicker: dateSelector,),
                        ),


                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 30, bottom: 0),
                          child: Text("Email Id", style: GoogleFonts.aBeeZee(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.height * 0.023),),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
                          child: SetEmail(currFocus: emailSFocus, nextFocus: emailSFocus, emailC: sEmailC!, email: sEmailC!.text, topPad: 20),
                        ),

                        SizedBox(height: 25,),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.05,
                            child: ElevatedButton(
                              onPressed: () async {

                                // print("---->>> ${context.read<AuthCubit>().FirebaseID()}");
                                // context.read<AuthCubit>().

                                setState(() {
                                  navigate = true;
                                });

                                FocusScope.of(context).unfocus(); //dismiss keyboard
                                final form = _formkey.currentState;
                                if (form!.validate()) {
                                  form.save();
                                  if (await InternetConnectivity.isNetworkAvailable()) {
                                    print("ssss--> ${sEmailC!.text} -- ${sNameC!.text}");
                                    context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, email: sEmailC!.text, name: sNameC!.text);
                                  } else {
                                    showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
                                  }
                                }
                              },

                              child: Text("Save" ,style:  TextStyle(fontSize: MediaQuery.of(context).size.height * 0.027,),),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: MaterialStateColor.resolveWith((states) {
                                    return Colors.orange.shade600;
                                  }),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)
                                  )
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20,),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.05,
                            child: ElevatedButton(
                              onPressed: () {  },

                              child: Text("Cancel" ,style:  TextStyle( color: Colors.orange.shade600 ,fontSize: MediaQuery.of(context).size.height * 0.027,),),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: MaterialStateColor.resolveWith((states) {
                                    return Colors.white;
                                  }),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)
                                  )
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
      // child:
    );
  }

  Future<void> dateSelector() async {
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1975),
        lastDate: DateTime(2013),
        builder: (BuildContext context, Widget? child){
          return Theme(
              data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                    surface: Colors.pink,
                    onSurface: Colors.black54,
                  )
              ),
              child: child!
          );
        }
    );
    setState(() {
      selectedDate = DateFormat("dd-MM-yyyy").format(date!);
      ageC!.text = selectedDate!;
    });
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  late XFile file;

  Widget Avatars(int index){
    return InkWell(
      onTap: () async {
        navigate = false;
        selected = index;
        File f = await getImageFileFromAssets('images/${Images[index]}');
        file = new XFile(f.path);
        setState(() {});
        print("-----> $f ----  ${file.path}");
        context.read<UpdateUserCubit>().setUpdateUser(userId: context.read<AuthCubit>().getUserId(), context: context, filePath: file.path);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
              color: selected == index ? Colors.orange : Colors.transparent,
              shape: BoxShape.circle
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: CircleAvatar(
              backgroundColor: Colors.orange,
              child: ClipOval(
                  child: Image.asset(UiUtils.getImagePath(Images[index]))
              ),
              radius: MediaQuery.of(context).size.height * 0.02,
            ),
          ),
        ),
      ),
    );
    return Image.asset("assets/images/profile/1.png");
  }
}
