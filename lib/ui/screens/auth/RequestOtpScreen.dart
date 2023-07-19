// ignore_for_file: file_names, use_build_context_synchronously

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';

import 'package:news/app/routes.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/utils/validators.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';

import '../../../cubits/Auth/authCubit.dart';
import '../../../cubits/Auth/soicalSignUpCubit.dart';
import '../../../cubits/Auth/updateFCMCubit.dart';
import '../../../cubits/settingCubit.dart';
import 'Widgets/setDivider.dart';

class RequestOtp extends StatefulWidget {
  const RequestOtp({super.key});

  @override
  RequestOtpState createState() => RequestOtpState();
}

class RequestOtpState extends State<RequestOtp> {
  TextEditingController phoneC = TextEditingController();
  String? phone, conCode, conName;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  CountryCode? code;
  String? verificationId;
  String errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        SafeArea(
          child: Stack(
          children: [
            // Image.asset(
            //   UiUtils.getImagePath("background.png"),
            //   height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            //   fit: BoxFit.fill,
            // ),
            showContent(),
          ],
        )
        ),
        showCircularProgress(isLoading, Theme.of(context).primaryColor)
      ],
    ));
  }

  //show form content
  showContent() {
    return BlocConsumer<SocialSignUpCubit, SocialSignUpState>(
      bloc: context.read<SocialSignUpCubit>(),
      listener: (context, state) async {
        if (state is SocialSignUpFailure) {
          showSnackBar(
            state.errorMessage,
            context,
          );
        }
        if (state is SocialSignUpSuccess) {
          context.read<AuthCubit>().checkAuthStatus();
          if (context.read<AuthCubit>().getStatus() == "0") {
            showSnackBar(UiUtils.getTranslatedLabel(context, 'deactiveMsg'), context);
          } else {
            FirebaseMessaging.instance.getToken().then((token) async {
              if (token != context.read<SettingsCubit>().getSettings().token && token != null) {
                context.read<UpdateFcmIdCubit>().updateFcmId(userId: context.read<AuthCubit>().getUserId(), fcmId: token, context: context);
              }
            });
            if (context.read<AuthCubit>().getIsFirstLogin() == "1") {
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.managePref, (route) => false, arguments: {"from": 2});
            }
            // else if (widget.isFromApp == true) {
            //   Navigator.pop(context);
            // }
            else {
              // print("---->> ${state.authModel.name}");
              if(state.authModel.name!.isEmpty || state.authModel.name == null){
                print("1st phase");
                Navigator.pushNamedAndRemoveUntil(context, Routes.signUp, (route) => false);
              }
              else
                Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"isFromBreak": false, "fromShowMore": false});
            }
          }
        }
      },
      builder: (context, state){
        return Container(
          padding: const EdgeInsetsDirectional.all(20.0),
          child: SingleChildScrollView(
              child: Form(
                  key: _formkey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    // Align(
                    //     //backButton
                    //     alignment: Alignment.topLeft,
                    //     child: InkWell(
                    //       onTap: () {
                    //         Navigator.of(context).pop();
                    //       },
                    //       splashColor: Colors.transparent,
                    //       child: const Icon(Icons.keyboard_backspace_rounded),
                    //     )),
                    Align(
                      //backButton
                        alignment: Alignment.topCenter,
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            splashColor: Colors.transparent,
                            child: Text("OSMO KIDS" , style: GoogleFonts.aBeeZee(color: Colors.grey.shade800, fontSize: MediaQuery.of(context).size.height * 0.035, fontWeight: FontWeight.w800),)
                        )),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                    otpVerifySet(),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                    Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          UiUtils.getImagePath("splash_Icon.png"),
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.42,
                          fit: BoxFit.fill,
                        )
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    // enterMblSet(),
                    // receiveDigitSet(),
                    Container(
                      alignment: Alignment.center,
                      child: setCodeWithMono(),
                    ),
                    reqOtpBtn(),
                    setDividerOr(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GoogleButton(),
                        FacebookButton(),
                      ],
                    )
                  ]))),
        );
      },
      // child:
    );
  }

  otpVerifySet() {
    return Center(
        child: CustomTextLabel(
      text: 'loginLbl',
      textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      textAlign: TextAlign.center,
    ));
  }

  enterMblSet() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 35.0),
        child: CustomTextLabel(
          text: 'enterMblLbl',
          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: UiUtils.getColorScheme(context).primaryContainer,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  receiveDigitSet() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      alignment: Alignment.center,
      child: CustomTextLabel(
        text: 'receiveDigitLbl',
        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  setCodeWithMono() {
    return Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Container(
          // alignment: Alignment.c,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.background,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                setCountryCode(),
                setMono(),
              ],
            )));
  }

  setCountryCode() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
        height: 45,
        width: MediaQuery.of(context).size.width * 0.2,
        child: CountryCodePicker(
            boxDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            searchDecoration: InputDecoration(
              hintStyle: TextStyle(color: UiUtils.getColorScheme(context).primaryContainer),
              fillColor: UiUtils.getColorScheme(context).primaryContainer,
            ),
            initialSelection: yourCountryCode,
            // dialogSize: Size(width - 50, height - 50),
            builder: (CountryCode? code) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Padding(
                  //     padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0, start: 10.0, end: 4.0),
                  //     child: ClipRRect(
                  //         borderRadius: BorderRadius.circular(5.0),
                  //         child: Image.asset(
                  //           code!.flagUri.toString(),
                  //           package: 'country_code_picker',
                  //           height: 40,
                  //           width: 40,
                  //           fit: BoxFit.cover,
                  //         )
                  //     )),
                  // Icon(
                  //   Icons.arrow_drop_down,
                  //   size: 21,
                  //   color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7),
                  // ),
                  // SizedBox(
                  //     //divider
                  //     width: 5.0,
                  //     height: 35.0,
                  //     child: VerticalDivider(
                  //       color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7),
                  //       thickness: 2.0,
                  //     )),
                  Container(
                      //CountryCode
                      width: 55.0,
                      height: 55.0,
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      alignment: Alignment.center,
                      child: Text(
                        code!.dialCode.toString(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7),
                            ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      )),
                  SizedBox(
                    //divider
                      width: 0.0,
                      height: 20.0,
                      child: VerticalDivider(
                        color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7),
                        thickness: 2.0,
                      )),
                  SizedBox(width: 20,)
                ],
              );
            },
            onChanged: (CountryCode countryCode) {
              conCode = countryCode.dialCode;
              conName = countryCode.name;
            },
            onInit: (CountryCode? code) {
              conCode = code?.dialCode;
            }));
  }

  setMono() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 5.0, bottom: 5.0),
      child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.65,
          alignment: Alignment.center,
          child: TextFormField(
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            controller: phoneC,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7),
                ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (val) => Validators.mobValidation(val!, context),
            onSaved: (String? value) {
              phone = value;
            },
            decoration: InputDecoration(
              hintText: '   9 9 9 - 9 9 9 - 9 9 9 9',
              hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5),
                  ),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          )),
    );
  }

  Future<void> verifyPhone(BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+$conCode${phoneC.text.trim()}",
        verificationCompleted: (AuthCredential phoneAuthCredential) {
          showSnackBar(phoneAuthCredential.toString(), context);
        },
        verificationFailed: (FirebaseAuthException exception) {
          setState(() {
            isLoading = false;
          });
          if (exception.code == "invalidPhoneNumber") {
            showSnackBar(UiUtils.getTranslatedLabel(context, 'invalidPhoneNumber'), context);
          } else {
            showSnackBar('${exception.message}', context);
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        codeSent: processCodeSent(),
        //smsOTPSent,
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (authError) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(authError.message!, context);
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(e.toString(), context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(e.toString(), context);
    }
  }

  processCodeSent() {
    smsOTPSent(String? verId, [int? forceCodeResend]) async {
      verificationId = verId;
      setState(() {
        isLoading = false;
      });

      showSnackBar(UiUtils.getTranslatedLabel(context, 'codeSent'), context);

      await Navigator.of(context).pushNamed(Routes.verifyOtp, arguments: {"verifyId": verificationId, "countryCode": conCode, "mono": phoneC.text.trim()});
    }

    return smsOTPSent;
  }

  reqOtpBtn() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 20.0),
      child: InkWell(
        child: Container(
          height: 45.0,
          width: MediaQuery.of(context).size.width * 0.85,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
          child: CustomTextLabel(
            text: 'Send Code',
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5, fontSize: 18),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus(); //dismiss keyboard
          if (validateAndSave()) {
            if (await InternetConnectivity.isNetworkAvailable()) {
              setState(() {
                isLoading = true;
              });
              verifyPhone(context);
            } else {
              showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
            }
          }
        },
      ),
    );
  }

  FacebookButton() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 20.0),
      child: InkWell(
        child: Container(
          height: 45.0,
          width: MediaQuery.of(context).size.width * 0.4,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.blueGrey.shade400 , borderRadius: BorderRadius.circular(15)),
          child: CustomTextLabel(
            text: 'Facebook',
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5, fontSize: 21),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus(); //dismiss keyboard
          if (validateAndSave()) {
            if (await InternetConnectivity.isNetworkAvailable()) {
              setState(() {
                isLoading = true;
              });
              verifyPhone(context);
            } else {
              showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
            }
          }
        },
      ),
    );
  }

  GoogleButton() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 20.0),
      child: InkWell(
        child: Container(
          height: 45.0,
          width: MediaQuery.of(context).size.width * 0.4,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
          child: CustomTextLabel(
            text: 'Google',
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5, fontSize: 21),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus(); //dismiss keyboard
          if (validateAndSave()) {
            if (await InternetConnectivity.isNetworkAvailable()) {
              setState(() {
                isLoading = true;
              });
              verifyPhone(context);
            } else {
              showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
            }
          }
        },
      ),
    );
  }
  //check validation of form data
  bool validateAndSave() {
    final form = _formkey.currentState;
    form!.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }
}
