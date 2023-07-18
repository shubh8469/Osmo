import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../cubits/Auth/authCubit.dart';
import '../../../cubits/appLocalizationCubit.dart';
import '../../../cubits/appSystemSettingCubit.dart';
import '../../../cubits/featureSectionCubit.dart';
import '../../../data/models/FeatureSectionModel.dart';
import '../../../data/models/NewsModel.dart';
import '../../../utils/ErrorMessageKeys.dart';
import '../../../utils/api.dart';
import '../../../utils/constant.dart';
import '../../../utils/internetConnectivity.dart';
import '../../../utils/strings.dart';
import '../../../utils/uiUtils.dart';
import '../../widgets/errorContainerWidget.dart';
import '../NewsDetail/Widgets/InterstitialAds/fbInterstitialAds.dart';
import '../NewsDetail/Widgets/InterstitialAds/googleInterstitialAds.dart';
import '../NewsDetail/Widgets/InterstitialAds/unityInterstitialAds.dart';
import '../NewsDetail/Widgets/NewsSubDetailsScreen.dart';
import '../NewsDetail/Widgets/RerwardAds/fbRewardAds.dart';
import '../NewsDetail/Widgets/RerwardAds/googleRewardAds.dart';
import '../NewsDetail/Widgets/RerwardAds/unityRewardAds.dart';
import 'Widgets/SectionShimmer.dart';
import 'package:ionicons/ionicons.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {

  List<FeatureSectionModel> section = [];
  List<NewsModel> newsList = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  int? limit = 3, offset = 0;
  PageController pageController = PageController();
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  bool _isFirstLoadRunning = false;

  @override
  void initState(){
    _firstLoad();
    pageController = PageController()..addListener(() {
      _loadMore();
    });

    // pageController.addListener(() { });
  }

  Future<void> Subscripion(){
    return showDialog(
        context: context, builder: (context){
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
                          border: Border.all(color: Colors.white, width: 7)
                      ),
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
                              Lottie.asset("assets/animations/asronaut.json",
                                // height: MediaQuery.of(context).size.height * 0.4,
                                width: MediaQuery.of(context).size.width * 0.35,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.03,
                              ),
                              Text("Trial Period Ended" ,style: TextStyle(color: Colors.black, fontSize: 15),),

                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.03,
                              ),
                              Text("Become A Premium Member" ,style: GoogleFonts.aBeeZee(color: Colors.black, fontSize: 19, fontWeight: FontWeight.w400),),
                              // SizedBox(
                              //   height: MediaQuery.of(context).size.height * 0.03,
                              // ),
                              // Text("Become A Premium Member" ,style: TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.w600),)
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Yearly ",
                                      style: GoogleFonts.aBeeZee(color: Colors.black, fontSize: 19, fontWeight: FontWeight.w400)
                                    ),
                                    TextSpan(
                                        text: "Rs 499/ ",
                                        style: GoogleFonts.aBeeZee(color: Colors.black, fontSize: 19, fontWeight: FontWeight.w600)
                                    )
                                  ]
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.03,
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height * 0.05,
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: ElevatedButton(
                                  onPressed: (){},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    backgroundColor: Colors.white
                                  ),
                                  child: Text(
                                      "Subscribe Now",
                                      style: GoogleFonts.aBeeZee(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400)
                                  ),
                                ),
                              )
                            ],
                          ),
                      ),
                    ),
                    Center(
                      child: IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.cancel_outlined, size: 50, color: Colors.white,),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }
    );
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

  Future<Map<String, dynamic>> getSections() async {
    try {
      final body = {LANGUAGE_ID: context.read<AppLocalizationCubit>().state.id, USER_ID: context.read<AuthCubit>().getUserId(), 'offset': offset.toString(), 'limit': limit.toString()};
      final result = await Api.post(body: body, url: Api.getFeatureSectionApi);

      return result;
      section.addAll((result['data'] as List).map((e) => FeatureSectionModel.fromJson(e)).toList());

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
        section.addAll((result['data'] as List).map((e) => FeatureSectionModel.fromJson(e)).toList());
        // print("${section[0]}");
        newsList.addAll(section[0].news!);
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

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        newsList.length - pageController.page! <= 4) {
      setState(() {
        _isLoadMoreRunning = true;
        offset = offset! + 5;// Display a progress indicator at the bottom
      });
      // _page += 1; // Increase _page by 1
      try {
        List<FeatureSectionModel> tempSection = [];
        final result = await getSections();
        print("artleast heresss --a $_hasNextPage ");
        tempSection.addAll((result['data'] as List).map((e) => FeatureSectionModel.fromJson(e)).toList());
        if (tempSection[0].news!.isNotEmpty) {
          print("artleast heresss ---1");
          setState(() {
            // section.addAll((result['data'] as List).map((e) => FeatureSectionModel.fromJson(e)).toList());
            newsList.addAll(tempSection[0].news!);
          });
        }
        else {
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


  Future<void> _refresh() async {
    // if (context.read<AuthCubit>().getUserId() != "0") {
    //   getUserData();
    //   getBookmark();
    //   getLikeNews();
    // }
    // getLiveStreamData();
    // if (isWeatherDataShow) {
    //   setState(() {
    //     weatherLoad = true;
    //     weatherData = null;
    //   });
    //   getWeatherData();
    // }
    // getSections();
  }


  Widget getSectionList() {
    return PageView.builder(
        controller: pageController,
        onPageChanged: (index) async {
          if (await InternetConnectivity.isNetworkAvailable()) {
            if (context.read<AppConfigurationCubit>().getInAppAdsMode() == "1" && (index % rewardAdsIndex == 0)) {
              if (context.read<AppConfigurationCubit>().checkAdsType() == "google") {
                showGoogleRewardedAd(context);
              } else if (context.read<AppConfigurationCubit>().checkAdsType() == "fb") {
                showFbRewardedAd();
              } else {
                showUnityRewardAds(context.read<AppConfigurationCubit>().rewardId()!);
              }
            }

            if (context.read<AppConfigurationCubit>().getInAppAdsMode() == "1" && (index % interstitialAdsIndex == 0)) {
              if (context.read<AppConfigurationCubit>().checkAdsType() == "google") {
                showGoogleInterstitialAd(context);
              } else if (context.read<AppConfigurationCubit>().checkAdsType() == "fb") {
                showFBInterstitialAd();
              } else {
                showUnityInterstitialAds(context.read<AppConfigurationCubit>().interstitialId()!);
              }
            }
          }
        },
        itemCount: (newsList == null || newsList.isEmpty) ? 1 : newsList.length,
        itemBuilder: (context, index) {
          return NewsSubDetails(
            model: newsList[index],
            fromShowMore: false,
            isFromBreak: false,
            // breakModel: widget.breakModel,
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(title:  Text("heeee ${newsList.length} ---- ${newsList.length - pageController.page!}",style: TextStyle(color: Colors.black),),),
        body: RefreshIndicator(
          onRefresh: () => _refresh(),
          key: _refreshIndicatorKey,
          // child: Container(
          //   height: double.infinity,
          //   width: double.infinity,
          //   color: Colors.red,
          //   child: Center(
          //     child: ElevatedButton(
          //       child: Text("Show Dialog"),
          //       onPressed: (){
          //         Subscripion();
          //       },
          //     ),
          //   ),
          // ),
          child: _isFirstLoadRunning ? Container(child: Center(child: Text("heeee"),),) : getSectionList()
        ),
      ),
    );
  }
}
