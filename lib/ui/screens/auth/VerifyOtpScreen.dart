// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison, must_be_immutable, file_names, use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news/cubits/Auth/soicalSignUpCubit.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';

class VerifyOtp extends StatefulWidget {
  String? verifyId, countryCode, mono;

  VerifyOtp({Key? key, this.verifyId, this.countryCode, this.mono}) : super(key: key);

  @override
  VerifyOtpState createState() => VerifyOtpState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
        builder: (_) => VerifyOtp(
              verifyId: arguments['verifyId'],
              countryCode: arguments['countryCode'],
              mono: arguments['mono'],
            ));
  }
}

class VerifyOtpState extends State<VerifyOtp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController phoneC = TextEditingController();
  String? phone, otp;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  int secondsRemaining = 60;
  bool enableResend = false;
  Timer? timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? id, name, email, pass, mobile, type, status, profile, confpass, verifId;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _resendCode() {
    otp = "";
    _onVerifyCode();
    setState(() {
      secondsRemaining = 60;
      enableResend = false;
    });
  }

  void _onVerifyCode() async {
    verificationCompleted(AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential).then((UserCredential value) {
        if (value.user != null) {
          showSnackBar(UiUtils.getTranslatedLabel(context, 'otpMsg'), context);
        } else {
          showSnackBar(UiUtils.getTranslatedLabel(context, 'otpError'), context);
        }
      }).catchError((error) {
        showSnackBar(error.toString(), context);
      });
    }

    verificationFailed(FirebaseAuthException authException) {
      if (authException.code == 'invalidVerificationCode') {
        showSnackBar(UiUtils.getTranslatedLabel(context, 'invalidVerificationCode'), context);
      } else {
        showSnackBar(authException.message.toString(), context);
      }
    }

    codeSent(String? verificationId, [int? forceResendingToken]) async {
      verifId = verificationId;
      if (mounted) {
        setState(() {
          verifId = verificationId;
        });
      }
    }

    codeAutoRetrievalTimeout(String verificationId) {
      verifId = verificationId;
      setState(() {
        verifId = verificationId;
      });
      showSnackBar(UiUtils.getTranslatedLabel(context, 'otpTimeoutLbl'), context);
    }

    await _auth.verifyPhoneNumber(
        phoneNumber: "+${widget.countryCode}${widget.mono}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: BlocConsumer<SocialSignUpCubit, SocialSignUpState>(
            bloc: context.read<SocialSignUpCubit>(),
            listener: (context, state) async {
              if (state is SocialSignUpFailure) {
                showSnackBar(
                  state.errorMessage,
                  context,
                );
              }
            },
            builder: (context, state) {
              return Stack(
                children: <Widget>[
                  // Image.asset(
                  //   UiUtils.getImagePath("background.png"),
                  //   height: MediaQuery.of(context).size.height,
                  //   width: MediaQuery.of(context).size.width,
                  //   fit: BoxFit.fill,
                  // ),
                  SafeArea(
                      child: showContent()
                  ), if (state is SocialSignUpProgress) Center(child: showCircularProgress(true, Theme.of(context).primaryColor))],
              );
            }));
  }

  //show form content
  showContent() {
    return Container(
      padding: const EdgeInsetsDirectional.all(20.0),
      child: SingleChildScrollView(
          child: Form(
              key: _formkey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
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

                otpSentSet(),
                // mblSet(),
                otpFillSet(),
                buildTimer(),
                submitBtn(),
              ]))),
    );
  }

  otpVerifySet() {
    return Align(
        alignment: Alignment.center,
        child: CustomTextLabel(
          text: 'Verification',
          textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          textAlign: TextAlign.center,
        ));
  }

  otpSentSet() {
    return Padding(
      padding:  EdgeInsets.only(top: 55.0, left: MediaQuery.of(context).size.width * 0.15, right: MediaQuery.of(context).size.width * 0.15),
      child: Text(
        'Enter the verification code we just sent to your Phone',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: UiUtils.getColorScheme(context).primaryContainer,
          fontWeight: FontWeight.w600,
        ),
        // textAlign: textAlign,
      )
      // child: CustomTextLabel(
      //   text: 'Enter the verification code we just sent',
      //   textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
      //         color: UiUtils.getColorScheme(context).primaryContainer,
      //         fontWeight: FontWeight.w600,
      //       ),
      // ),
    );
  }

  mblSet() {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Text(
        "${widget.countryCode} ${widget.mono}",
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8),
            ),
      ),
    );
  }

  otpFillSet() {
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 30.0, left: 15, right: 15),
        child: PinFieldAutoFill(
            decoration: BoxLooseDecoration(
                strokeColorBuilder: PinListenColorBuilder(Theme.of(context).colorScheme.background, Theme.of(context).colorScheme.background),
                bgColorBuilder: PinListenColorBuilder(Theme.of(context).colorScheme.background, Theme.of(context).colorScheme.background),
                gapSpace: 4.0),
            currentCode: otp,
            codeLength: 6,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            onCodeChanged: (String? code) {
              otp = code;
            },
            onCodeSubmitted: (String code) {
              otp = code;
            }));
  }

  buildTimer() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 25.0),
      child: secondsRemaining != 0
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomTextLabel(
                    text: 'resendCodeLbl',
                    textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8),
                        )),
                Text(' 00:$secondsRemaining',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        )),
              ],
            )
          : TextButton(
              onPressed: enableResend ? _resendCode : null,
              child: CustomTextLabel(
                  text: 'resendLbl',
                  textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      )),
            ),
    );
  }

  submitBtn() {
    return Container(
      alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 30.0),
        child: InkWell(
            child: Container(
              height: 49.0,
              width: MediaQuery.of(context).size.width * 0.75,
              alignment: Alignment.center,
              decoration: BoxDecoration(color:Colors.black, borderRadius: BorderRadius.circular(13)),
              child: CustomTextLabel(
                text: 'Verify',
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: secondaryColor, fontWeight: FontWeight.w600, fontSize: 21, letterSpacing: 0.6),
              ),
            ),
            onTap: () async {
              FocusScope.of(context).unfocus(); //dismiss keyboard

              if (validateAndSave()) {
                print("atleast Here ");
                if (await InternetConnectivity.isNetworkAvailable()) {
                  context.read<SocialSignUpCubit>().socialSignUpUser(authProvider: AuthProvider.mobile, verifiedId: widget.verifyId, otp: otp, context: context);
                } else {
                  showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
                }
              }

            }));
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
