import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:news/ui/screens/AddNews.dart';
import 'package:news/ui/screens/BookmarkScreen.dart';
import 'package:news/ui/screens/HomePage/NewHomePage.dart';
import 'package:news/ui/screens/ImagePreviewScreen.dart';
import 'package:news/ui/screens/LiveStreaming.dart';
import 'package:news/ui/screens/NewsDetail/NewsDetailScreen.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/ShowMoreNewsList.dart';
import 'package:news/ui/screens/NewsVideo.dart';
import 'package:news/ui/screens/PayMent.dart';
import 'package:news/ui/screens/PrivacyPolicyScreen.dart';
import 'package:news/ui/screens/Search.dart';
import 'package:news/ui/screens/ShowUserRolesNews.dart';
import 'package:news/ui/screens/SubCategory/SubCategoryScreen.dart';
import 'package:news/ui/screens/TagNewsScreen.dart';
import 'package:news/ui/screens/UserProfile.dart';
import 'package:news/ui/screens/auth/ForgotPassword.dart';
import 'package:news/ui/screens/auth/RequestOtpScreen.dart';
import 'package:news/ui/screens/auth/SignUp.dart';
import 'package:news/ui/screens/auth/VerifyOtpScreen.dart';
import 'package:news/ui/screens/dashBoard/dashBoardScreen.dart';
import 'package:news/ui/screens/introSlider.dart';
import 'package:news/ui/screens/languageList.dart';
import 'package:news/ui/screens/splashScreen.dart';
import 'package:news/ui/screens/ManagePreference.dart';
import 'package:news/ui/screens/SectionMoreNews/SectionMoreBreakNewsList.dart';
import 'package:news/ui/screens/SectionMoreNews/SectionMoreNewsList.dart';
import 'package:news/ui/screens/auth/loginScreen.dart';

import '../ui/screens/Profile/ProfileScreen.dart';
import '../ui/screens/auth/SignUp.dart';

class Routes {
  static const String splash = "splash";
  static const String home = "/";
  static const String introSlider = "introSlider";
  static const String languageList = "languageList";
  static const String login = "login";
  static const String privacy = "privacy";
  static const String search = "search";
  static const String live = "live";
  static const String subCat = "subCat";
  static const String payment = "payment";
  static const String requestOtp = "requestOtp";
  static const String verifyOtp = "verifyOtp";
  static const String signUp = "signUp";
  static const String managePref = "managePref";
  static const String newsVideo = "newsVideo";
  static const String bookmark = "bookmark";
  static const String Userprofile = "Userprofile";
  static const String profileMenu = "profileMenu";
  static const String newsDetails = "newsDetails";
  static const String NewHome = "NewHomePage";
  static const String imagePreview = "imagePreview";
  static const String tagScreen = "tagScreen";
  static const String addNews = "AddNews";
  static const String editNews = "editNews";
  static const String showNews = "showNews";
  static const String forgotPass = "forgotPass";
  static const String sectionNews = "sectionNews";
  static const String sectionBreakNews = "sectionBreakNews";
  static const String showMoreRelatedNews = "showMoreRelatedNews";

  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    currentRoute = routeSettings.name ?? "";
    switch (routeSettings.name) {
      case splash:
        {
          return CupertinoPageRoute(builder: (_) => const Splash());
        }
      case NewHome:
        {
          return CupertinoPageRoute(builder: (_) => const NewHomePage());
        }
      case signUp:
        {
          return CupertinoPageRoute(builder: (_) => SignUp());
        }
      case home:
        {
          return DashBoard.route(routeSettings);
        }
      case introSlider:
        {
          return CupertinoPageRoute(builder: (_) => const IntroSliderScreen());
        }
      case payment:
        {
          return CupertinoPageRoute(builder: (_) => const Payment());
        }
      case login:
        {
          return LoginScreen.route(routeSettings);
        }
      case languageList:
        {
          return LanguageList.route(routeSettings);
        }
      case privacy:
        {
          return PrivacyPolicy.route(routeSettings);
        }
      case search:
        {
          return CupertinoPageRoute(builder: (_) => const Search());
        }
      case live:
        {
          return LiveStreaming.route(routeSettings);
        }
      case subCat:
        {
          return SubCategoryScreen.route(routeSettings);
        }
      case requestOtp:
        {
          return CupertinoPageRoute(builder: (_) => const RequestOtp());
        }
      case verifyOtp:
        {
          return VerifyOtp.route(routeSettings);
        }
      case managePref:
        {
          return ManagePref.route(routeSettings);
        }
      case newsVideo:
        {
          return NewsVideo.route(routeSettings);
        }
      case bookmark:
        {
          return CupertinoPageRoute(builder: (_) => const BookmarkScreen());
        }
      case Userprofile:
        {
          return CupertinoPageRoute(builder: (_) => const UserProfileScreen());
        }
      case profileMenu:
        {
          return CupertinoPageRoute(builder: (_) => const ProfileScreen());
        }
      case newsDetails:
        {
          return NewsDetailScreen.route(routeSettings);
        }
      case imagePreview:
        {
          return ImagePreview.route(routeSettings);
        }
      case tagScreen:
        {
          return NewsTag.route(routeSettings);
        }
      case addNews:
        {
          return AddNews.route(routeSettings);
        }
      case showNews:
        {
          return CupertinoPageRoute(builder: (_) => const ShowNews());
        }
      case forgotPass:
        {
          return CupertinoPageRoute(builder: (_) => const ForgotPassword());
        }

      case sectionNews:
        {
          return SectionMoreNewsList.route(routeSettings);
        }
      case sectionBreakNews:
        {
          return SectionMoreBreakingNewsList.route(routeSettings);
        }
      case showMoreRelatedNews:
        {
          return ShowMoreNewsList.route(routeSettings);
        }
      default:
        {
          return CupertinoPageRoute(builder: (context) => const Scaffold());
        }
    }
  }
}
