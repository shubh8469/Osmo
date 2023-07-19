// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lottie/lottie.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/InterstitialAds/googleInterstitialAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/InterstitialAds/unityInterstitialAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/RerwardAds/fbRewardAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/RerwardAds/googleRewardAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/RerwardAds/unityRewardAds.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/InterstitialAds/fbInterstitialAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/NewsSubDetailsScreen.dart';

import '../../../app/routes.dart';
import '../../../cubits/Auth/authCubit.dart';
import '../../../cubits/Bookmark/bookmarkCubit.dart';
import '../../../cubits/appLocalizationCubit.dart';
import '../../../cubits/getUserDataByIdCubit.dart';
import '../../../data/models/FeatureSectionModel.dart';
import '../../../utils/api.dart';
import '../../../utils/strings.dart';
import '../../styles/colors.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsModel? model;
  final List<NewsModel>? newsList;
  final BreakingNewsModel? breakModel;
  final List<BreakingNewsModel>? breakNewsList;
  final bool isFromBreak;
  final bool fromShowMore;
  final String? from;

  const NewsDetailScreen({
    Key? key,
    this.model,
    this.breakModel,
    this.breakNewsList,
    this.newsList,
    required this.isFromBreak,
    required this.fromShowMore, this.from,
  }) : super(key: key);

  @override
  NewsDetailsState createState() => NewsDetailsState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
        builder: (_) => NewsDetailScreen(
              model: arguments['model'],
              breakModel: arguments['breakModel'],
              breakNewsList: arguments['breakNewsList'],
              newsList: arguments['newsList'],
              isFromBreak: arguments['isFromBreak'],
              fromShowMore: arguments['fromShowMore'],
              from: arguments['from'],
            ));
  }
}

class NewsDetailsState extends State<NewsDetailScreen> {
  List<FeatureSectionModel> section = [];
  List<NewsModel> newsList = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  int? limit = 3, offset = 0;
  PageController pageController = PageController();
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool _isFirstLoadRunning = false;

  @override
  void initState() {

    // if (context.read<AuthCubit>().getUserId() != "0") {
    //   getUserData();
    // }
    //
    // getSections();

    getBookMark();

    print("shshsh ${widget.from}");

    _firstLoad();

    pageController = PageController()
      ..addListener(() {
        _loadMore();
      });

    if (context.read<AppConfigurationCubit>().getInAppAdsMode() == "1") {
      if (context.read<AppConfigurationCubit>().checkAdsType() == "google") {
        createGoogleInterstitialAd(context);
        createGoogleRewardedAd(context);
      } else if (context.read<AppConfigurationCubit>().checkAdsType() == "fb") {
        fbInit();
        loadFbInterstitialAd(context);
        loadFbRewardedAd(context);
      } else {
        if (context.read<AppConfigurationCubit>().unityGameId() != null) {
          UnityAds.init(
            gameId: context.read<AppConfigurationCubit>().unityGameId()!,
            testMode: true, //set it to False @Deployement
            onComplete: () {
              loadUnityInterAd(
                  context.read<AppConfigurationCubit>().interstitialId()!);
              loadUnityRewardAd(
                  context.read<AppConfigurationCubit>().rewardId()!);
            },
            onFailed: (error, message) =>
                debugPrint('Initialization Failed: $error $message'),
          );
        }
      }
    }

    super.initState();
  }

  void getUserData() {
    Future.delayed(Duration.zero, () {
      context.read<GetUserByIdCubit>().getUserById(context: context, userId: context.read<AuthCubit>().getUserId());
    });
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

  Widget showBreakingNews() {
    return PageView.builder(
        controller: pageController,
        onPageChanged: (index) async {
          if (await InternetConnectivity.isNetworkAvailable()) {
            if (context.read<AppConfigurationCubit>().getInAppAdsMode() ==
                    "1" &&
                (index % rewardAdsIndex == 0)) {
              if (context.read<AppConfigurationCubit>().checkAdsType() ==
                  "google") {
                showGoogleRewardedAd(context);
              } else if (context.read<AppConfigurationCubit>().checkAdsType() ==
                  "fb") {
                showFbRewardedAd();
              } else {
                showUnityRewardAds(
                    context.read<AppConfigurationCubit>().rewardId()!);
              }
            }

            if (context.read<AppConfigurationCubit>().getInAppAdsMode() ==
                    "1" &&
                (index % interstitialAdsIndex == 0)) {
              if (context.read<AppConfigurationCubit>().checkAdsType() ==
                  "google") {
                showGoogleInterstitialAd(context);
              } else if (context.read<AppConfigurationCubit>().checkAdsType() ==
                  "fb") {
                showFBInterstitialAd();
              } else {
                showUnityInterstitialAds(
                    context.read<AppConfigurationCubit>().interstitialId()!);
              }
            }
          }
        },
        itemCount:
            (widget.breakNewsList == null || widget.breakNewsList!.isEmpty)
                ? 1
                : widget.breakNewsList!.length + 1,
        itemBuilder: (context, index) {
          return NewsSubDetails(
            breakModel: (index == 0)
                ? widget.breakModel
                : widget.breakNewsList![index - 1],
            fromShowMore: widget.fromShowMore,
            isFromBreak: widget.isFromBreak,
            model: widget.model,
          );
        });
  }

  Widget getSectionList() {
    return
      // newsList.length > 0 ?
    PageView.builder(
            controller: pageController,
            onPageChanged: (index) async {
              if (await InternetConnectivity.isNetworkAvailable()) {
                if (context.read<AppConfigurationCubit>().getInAppAdsMode() ==
                        "1" &&
                    (index % rewardAdsIndex == 0)) {
                  if (context.read<AppConfigurationCubit>().checkAdsType() ==
                      "google") {
                    showGoogleRewardedAd(context);
                  } else if (context
                          .read<AppConfigurationCubit>()
                          .checkAdsType() ==
                      "fb") {
                    showFbRewardedAd();
                  } else {
                    showUnityRewardAds(
                        context.read<AppConfigurationCubit>().rewardId()!);
                  }
                }

                if (context.read<AppConfigurationCubit>().getInAppAdsMode() ==
                        "1" &&
                    (index % interstitialAdsIndex == 0)) {
                  if (context.read<AppConfigurationCubit>().checkAdsType() ==
                      "google") {
                    showGoogleInterstitialAd(context);
                  } else if (context
                          .read<AppConfigurationCubit>()
                          .checkAdsType() ==
                      "fb") {
                    showFBInterstitialAd();
                  } else {
                    showUnityInterstitialAds(context
                        .read<AppConfigurationCubit>()
                        .interstitialId()!);
                  }
                }
              }
            },
            itemCount:
                (newsList == null || newsList.isEmpty) ? 1 : newsList.length,
            itemBuilder: (context, index) {
              return NewsSubDetails(
                model: newsList[index],
                fromShowMore: false,
                isFromBreak: false,
                // breakModel: widget.breakModel,
              );
            });
        // : Center(
        //   child: Container(
        //     color: Colors.grey.shade200,
        //     child: Column(
        //     // mainAxisAlignment: MainAxisAlignment.center,
        //     // crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       ListTile(
        //         leading: Image.asset(UiUtils.getImagePath("osmosplash.png"), height: 40, width: 50,),
        //         title: Center(
        //           child: Padding(
        //             padding: const EdgeInsetsDirectional.only(start: 0),
        //             child: Text("Kids News", style: GoogleFonts.aBeeZee(color: darkSecondaryColor, fontSize: MediaQuery.of(context).size.height * 0.028, fontWeight: FontWeight.w600),),
        //           ),
        //         ),
        //         trailing: IconButton(
        //           onPressed: () {
        //             Navigator.of(context).pushNamed(Routes.profileMenu);
        //           },
        //           icon: Icon(Ionicons.menu, size: 30,),color: darkSecondaryColor,),
        //         // actions: [skipBtn()],
        //       ),
        //       // Text("no data available"),
        //       SizedBox(
        //         height: MediaQuery.of(context).size.height * 0.8,
        //         child: Align(
        //           alignment: Alignment.center,
        //           child: Container(
        //             height: MediaQuery.of(context).size.height * 0.07,
        //             width: MediaQuery.of(context).size.width * 0.6,
        //             child: ElevatedButton(
        //               onPressed: () {
        //                 Navigator.of(context).pushNamedAndRemoveUntil(Routes.managePref, (route) => false, arguments: {"from": 2});
        //               },
        //               style: ElevatedButton.styleFrom(
        //                   shape: RoundedRectangleBorder(
        //                       borderRadius:
        //                       BorderRadius.circular(20)),
        //                   backgroundColor: Colors.orange),
        //               child: Text("Select Preference",
        //                   style: GoogleFonts.aBeeZee(
        //                       color: Colors.white,
        //                       fontSize: 21,
        //                       fontWeight: FontWeight.w600)),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        //     ),
        // );
        // : Navigator.of(context).pushNamedAndRemoveUntil(Routes.managePref, (route) => false, arguments: {"from": 2});
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        newsList.length - pageController.page! <= 4) {
      setState(() {
        _isLoadMoreRunning = true;
        offset = offset! + 5; // Display a progress indicator at the bottom
      });
      // _page += 1; // Increase _page by 1
      try {
        List<FeatureSectionModel> tempSection = [];
        final result = await getSections();
        print("artleast heresss --a $_hasNextPage ");
        tempSection.addAll((result['data'] as List)
            .map((e) => FeatureSectionModel.fromJson(e))
            .toList());
        if (tempSection[0].news!.isNotEmpty) {
          print("artleast heresss ---1");
          setState(() {
            // section.addAll((result['data'] as List).map((e) => FeatureSectionModel.fromJson(e)).toList());
            newsList.addAll(tempSection[0].news!);
          });
        } else {
          print("artleast heresss ---2");
          // This means there is no more data
          // and therefore, we will not send another GET request
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        // if (kDebugMode) {
        print('Something went wrong! balle balle');
        // }
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  Future<Map<String, dynamic>> getSections() async {
    try {
      final body = {
        LANGUAGE_ID: context.read<AppLocalizationCubit>().state.id,
        USER_ID: context.read<AuthCubit>().getUserId(),
        'offset': offset.toString(),
        'limit': limit.toString()
      };
      final result = await Api.post(body: body, url: Api.getFeatureSectionApi);

      return result;
      section.addAll((result['data'] as List)
          .map((e) => FeatureSectionModel.fromJson(e))
          .toList());

      newsList = section![0].news!;

      // return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      final result = await getSections();
      setState(() {
        section.addAll((result['data'] as List)
            .map((e) => FeatureSectionModel.fromJson(e))
            .toList());
        // print("${section[0]}");
        newsList.addAll(section[0].news!);
        if(newsList.length <= 0){
          Navigator.of(context).pushNamedAndRemoveUntil(Routes.managePref, (route) => false, arguments: {"from": 2});
        }
      });
    } catch (err) {
      // if (kDebugMode) {
      print('$err --- HEllO  Something went wrong');
      // }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  Widget showNews() {
    return PageView.builder(
        controller: pageController,
        onPageChanged: (index) async {
          if (await InternetConnectivity.isNetworkAvailable()) {
            if (context.read<AppConfigurationCubit>().getInAppAdsMode() ==
                    "1" &&
                (index % rewardAdsIndex == 0)) {
              if (context.read<AppConfigurationCubit>().checkAdsType() ==
                  "google") {
                showGoogleRewardedAd(context);
              } else if (context.read<AppConfigurationCubit>().checkAdsType() ==
                  "fb") {
                showFbRewardedAd();
              } else {
                showUnityRewardAds(
                    context.read<AppConfigurationCubit>().rewardId()!);
              }
            }

            if (context.read<AppConfigurationCubit>().getInAppAdsMode() ==
                    "1" &&
                (index % interstitialAdsIndex == 0)) {
              if (context.read<AppConfigurationCubit>().checkAdsType() ==
                  "google") {
                showGoogleInterstitialAd(context);
              } else if (context.read<AppConfigurationCubit>().checkAdsType() ==
                  "fb") {
                showFBInterstitialAd();
              } else {
                showUnityInterstitialAds(
                    context.read<AppConfigurationCubit>().interstitialId()!);
              }
            }
          }
        },
        itemCount: (widget.newsList == null || widget.newsList!.isEmpty)
            ? 1
            : widget.newsList!.length + 1,
        itemBuilder: (context, index) {
          return NewsSubDetails(
            model: (index == 0) ? widget.model : widget.newsList![index - 1],
            fromShowMore: widget.fromShowMore,
            isFromBreak: widget.isFromBreak,
            breakModel: widget.breakModel,
          );
        });
  }

  Future<void> Subscripion() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              // shadowColor: Colors.red,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.75,
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.56,
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 7)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.09,
                            ),
                            Lottie.asset(
                              "assets/animations/asronaut.json",
                              // height: MediaQuery.of(context).size.height * 0.4,
                              width: MediaQuery.of(context).size.width * 0.35,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text(
                              "Trial Period Ended",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text(
                              "Become A Premium Member",
                              style: GoogleFonts.aBeeZee(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400),
                            ),
                            // SizedBox(
                            //   height: MediaQuery.of(context).size.height * 0.03,
                            // ),
                            // Text("Become A Premium Member" ,style: TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.w600),)
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "Yearly ",
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w400)),
                                TextSpan(
                                    text: "Rs 499/ ",
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600))
                              ]),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    backgroundColor: Colors.white),
                                child: Text("Subscribe Now",
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
    // return showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return Dialog(
    //         shape: RoundedRectangleBorder(
    //             borderRadius:
    //             BorderRadius.circular(20.0)), //this right here
    //         child: Container(
    //           height: 200,
    //           child: Padding(
    //             padding: const EdgeInsets.all(12.0),
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 TextField(
    //                   decoration: InputDecoration(
    //                       border: InputBorder.none,
    //                       hintText: 'What do you want to remember?'),
    //                 ),
    //                 SizedBox(
    //                   width: 320.0,
    //                   child: ElevatedButton(
    //                     onPressed: () {},
    //                     child: Text(
    //                       "Save",
    //                       style: TextStyle(color: Colors.white),
    //                     ),
    //                     // color: const Color(0xFF1BC0C5),
    //                   ),
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //       );
    //     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UiUtils.getColorScheme(context).secondary,
        // body: widget.isFromBreak ? showBreakingNews() : showNews(),
        body: widget.from == "bookmark"
        ? showNews()
        : _isFirstLoadRunning
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
              )
            : SafeArea(child: getSectionList()));
  }
}
