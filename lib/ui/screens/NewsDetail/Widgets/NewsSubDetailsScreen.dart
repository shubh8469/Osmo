// ignore_for_file: file_names

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news/cubits/adSpacesNewsDetailsCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/commentNewsCubit.dart';
import 'package:news/cubits/relatedNewsCubit.dart';
import 'package:news/cubits/setNewsViewsCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/ImageView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/horizontalBtnList.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/relatedNewsList.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/setBannderAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/tagView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/titleView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/videoBtn.dart';
import 'package:news/ui/widgets/adSpaces.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/CommentView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/ReplyCommentView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/RerwardAds/fbRewardAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/backBtn.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/dateView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/descView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/likeBtn.dart';

import '../../../../app/routes.dart';
import '../../../../cubits/Bookmark/UpdateBookmarkCubit.dart';
import '../../../../cubits/Bookmark/bookmarkCubit.dart';
import '../../../styles/colors.dart';
import '../../../widgets/circularProgressIndicator.dart';
import '../../../widgets/customTextLabel.dart';
import '../../../widgets/loginRequired.dart';

class NewsSubDetails extends StatefulWidget {
  final NewsModel? model;
  final BreakingNewsModel? breakModel;
  final bool fromShowMore;
  final bool isFromBreak;

  const NewsSubDetails({Key? key, this.model, this.breakModel, required this.fromShowMore, required this.isFromBreak}) : super(key: key);

  @override
  NewsSubDetailsState createState() => NewsSubDetailsState();
}

class NewsSubDetailsState extends State<NewsSubDetails> {
  bool comEnabled = false;
  bool isReply = false;
  int? replyComIndex;
  int fontValue = 15;
  FlutterTts? _flutterTts;
  bool isPlaying = false;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  BannerAd? _bannerAd;
  NewsModel? newsModel;
  late final ScrollController controller = ScrollController()..addListener(hasMoreCommScrollListener);
  ScreenshotController screenshotController = ScreenshotController();

  bool showw = true;

  @override
  void initState() {

    super.initState();
    newsModel = widget.model;
    getComments();
    getRelatedNews();
    initializeTts();
    if (context.read<AuthCubit>().getUserId() != "0") setNewsViews(isBreakingNews: (widget.isFromBreak) ? true : false);
    if (context.read<AppConfigurationCubit>().getInAppAdsMode() == "1") bannerAdsInitialized();
    Future.delayed(Duration.zero, () {
      context.read<AdSpacesNewsDetailsCubit>().getAdspaceForNewsDetails(langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  setNewsViews({required bool isBreakingNews}) {
    Future.delayed(Duration.zero, () {
      context
          .read<SetNewsViewsCubit>()
          .setSetNewsViews(userId: context.read<AuthCubit>().getUserId(), newsId: (isBreakingNews) ? widget.breakModel!.id! : newsModel!.newsId!, isBreakingNews: isBreakingNews);
    });
  }

  getComments() {
    if (!widget.isFromBreak && context.read<AppConfigurationCubit>().getCommentsMode() == "1") {
      Future.delayed(Duration.zero, () {
        context.read<CommentNewsCubit>().getCommentNews(context: context, newsId: newsModel!.id!, userId: context.read<AuthCubit>().getUserId());
      });
    }
  }

  getRelatedNews() {
    if (!widget.isFromBreak) {
      Future.delayed(Duration.zero, () {
        context.read<RelatedNewsCubit>().getRelatedNews(
            userId: context.read<AuthCubit>().getUserId(),
            langId: context.read<AppLocalizationCubit>().state.id,
            catId: (newsModel!.categoryId == "0" || newsModel!.categoryId == '') ? newsModel!.categoryId : null,
            subCatId: (newsModel!.subCatId != "0" || newsModel!.subCatId != '') ? newsModel!.subCatId : null);
      });
    }
  }

  @override
  void dispose() {
    _flutterTts!.stop();
    controller.dispose();
    super.dispose();
  }

  updateFontVal(int fontVal) {
    setState(() {
      fontValue = fontVal;
    });
  }

  initializeTts() {
    _flutterTts = FlutterTts();

    _flutterTts!.setStartHandler(() async {
      if (mounted) {
        setState(() {
          isPlaying = true;
        });
      }
    });

    _flutterTts!.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });

    _flutterTts!.setErrorHandler((err) {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  bannerAdsInitialized() {
    if (context.read<AppConfigurationCubit>().checkAdsType() == "unity") {
      UnityAds.init(
          gameId: context.read<AppConfigurationCubit>().unityGameId()!,
          testMode: true, //set it to false @Deployment
          onComplete: () {
            debugPrint('Initialization Complete');
          },
          onFailed: (error, message) {
            debugPrint('Initialization Failed: $error $message');
          });
    }

    if (context.read<AppConfigurationCubit>().checkAdsType() == "fb") {
      fbInit();
    }
    if (context.read<AppConfigurationCubit>().checkAdsType() == "google") {
      _createBottomBannerAd();
    }
  }

  void _createBottomBannerAd() {
    if (context.read<AppConfigurationCubit>().bannerId() != "") {
      _bannerAd = BannerAd(
        adUnitId: context.read<AppConfigurationCubit>().bannerId()!,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {},
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
          },
        ),
      );

      _bannerAd!.load();
    }
  }

  speak(String description) async {
    if (description.isNotEmpty) {
      await _flutterTts!.setVolume(volume);
      await _flutterTts!.setSpeechRate(rate);
      await _flutterTts!.setPitch(pitch);
      await _flutterTts!.getLanguages;
      await _flutterTts!.setLanguage(() {
        return context.read<AppLocalizationCubit>().state.languageCode;
      }());
      int length = description.length;
      if (length < 4000) {
        setState(() {
          isPlaying = true;
        });
        await _flutterTts!.speak(description);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            _flutterTts!.stop();
            isPlaying = false;
          });
        });
      } else if (length < 8000) {
        String temp1 = description.substring(0, length ~/ 2);
        await _flutterTts!.speak(temp1);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = true;
          });
        });

        String temp2 = description.substring(temp1.length, description.length);
        await _flutterTts!.speak(temp2);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = false;
          });
        });
      } else if (length < 12000) {
        String temp1 = description.substring(0, 3999);
        await _flutterTts!.speak(temp1);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = true;
          });
        });
        String temp2 = description.substring(temp1.length, 7999);
        await _flutterTts!.speak(temp2);
        _flutterTts!.setCompletionHandler(() {
          setState(() {});
        });
        String temp3 = description.substring(temp2.length, description.length);
        await _flutterTts!.speak(temp3);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = false;
          });
        });
      }
    }
  }

  stop() async {
    var result = await _flutterTts!.stop();
    if (result == 1) {
      setState(() {
        isPlaying = false;
      });
    }
  }

  Future<bool> onBackPress() {
    if (widget.fromShowMore == true) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  Widget showViews() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.remove_red_eye_rounded, size: 17, color: UiUtils.getColorScheme(context).primaryContainer),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(((!widget.isFromBreak) ? newsModel!.totalViews : widget.breakModel!.totalViews) ?? '0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ),
      ],
    );
  }

  otherMainDetails() {
    return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.7),
        child: Container(
          padding: const EdgeInsetsDirectional.only(top: 20.0, start: 20.0, end: 20.0),
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: UiUtils.getColorScheme(context).secondary),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            // allRowBtn(
            //     isFromBreak: widget.isFromBreak,
            //     context: context,
            //     breakModel: widget.isFromBreak ? widget.breakModel : null,
            //     model: !widget.isFromBreak ? newsModel! : null,
            //     fontVal: fontValue,
            //     updateFont: updateFontVal,
            //     isPlaying: isPlaying,
            //     speak: speak,
            //     stop: stop,
            //     updateComEnabled: updateCommentshow),
            BlocBuilder<AdSpacesNewsDetailsCubit, AdSpacesNewsDetailsState>(
              builder: (context, state) {
                if (state is AdSpacesNewsDetailsFetchSuccess && state.adSpaceTopData != null) {
                  return AdSpaces(adsModel: state.adSpaceTopData!);
                }
                return const SizedBox.shrink();
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isFromBreak) tagView(model: newsModel!, context: context, isFromDetailsScreen: true),
                if (!isReply && !comEnabled)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [if (!widget.isFromBreak) dateView(context, newsModel!.date!), if (!widget.isFromBreak) const SizedBox(width: 20), showViews()],
                    ),
                  ),
                if (!isReply && !comEnabled) titleView(title: widget.isFromBreak ? widget.breakModel!.title! : newsModel!.title!, context: context),
                if (!isReply && !comEnabled) descView(desc: widget.isFromBreak ? widget.breakModel!.desc! : newsModel!.desc!, context: context, fontValue: fontValue.toDouble()),
              ],
            ),
            if (!widget.isFromBreak && !isReply && comEnabled) CommentView(newsId: newsModel!.id!, updateComFun: updateCommentshow, updateIsReplyFun: updateComReply),
            if (!widget.isFromBreak && isReply && comEnabled) ReplyCommentView(replyComIndex: replyComIndex!, replyComFun: updateComReply, newsId: newsModel!.id!),
            BlocBuilder<AdSpacesNewsDetailsCubit, AdSpacesNewsDetailsState>(
              builder: (context, state) {
                if (state is AdSpacesNewsDetailsFetchSuccess && state.adSpaceBottomData != null) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 5),
                    child: AdSpaces(adsModel: state.adSpaceBottomData!),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (!widget.isFromBreak && !isReply && !comEnabled && newsModel != null) RelatedNewsList(model: newsModel!),
          ]),
        ));
  }

  updateCommentshow(bool comEnabledUpdate) {
    setState(() {
      comEnabled = comEnabledUpdate;
    });
  }

  updateComReply(bool comReplyUpdate, int comIndex) {
    setState(() {
      isReply = comReplyUpdate;
      replyComIndex = comIndex;
    });
  }

  void hasMoreCommScrollListener() {
    if (!widget.isFromBreak && comEnabled && !isReply) {
      if (controller.position.maxScrollExtent == controller.offset) {
        if (context.read<CommentNewsCubit>().hasMoreCommentNews()) {
          context.read<CommentNewsCubit>().getMoreCommentNews(context: context, newsId: newsModel!.id!, userId: context.read<AuthCubit>().getUserId());
        } else {
          debugPrint("No more Comments");
        }
      }
    }
  }

  double? height,width;

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(child: Image.memory(capturedImage)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var container = ScreenshotWidget(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: onBackPress,
      child: Screenshot(
        controller: screenshotController,
        child: Container(
          color: Colors.grey.shade200,
          child: Padding(//bottom: height! * 0.1,
            padding: EdgeInsets.only(top: height! * 0.01 , left: width! * 0.02, right: width! * 0.02),
            child: Column(
                children: [
              ListTile(
                leading: Image.asset(UiUtils.getImagePath("osmosplash.png"), height: 40, width: 50,),
                title: Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 0),
                    child: Text("Kids News", style: GoogleFonts.aBeeZee(color: darkSecondaryColor, fontSize: MediaQuery.of(context).size.height * 0.028, fontWeight: FontWeight.w600),),
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.profileMenu);
                  },
                  icon: Icon(Ionicons.menu, size: 30,),color: darkSecondaryColor,),
                // actions: [skipBtn()],
              ),
              SizedBox(height: 15,),
              Expanded(
                flex: (Platform.isAndroid) ? 17 : 9,
                child: SingleChildScrollView(
                    controller: !widget.isFromBreak && comEnabled && !isReply ? controller : null,
                    child: Stack(children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ImageView(
                            isFromBreak: widget.isFromBreak,
                            model: newsModel,
                            breakModel: widget.breakModel,
                          ),
                        ),
                      ),
                      // backBtn(context, widget.fromShowMore),
                      // videoBtn(context: context, isFromBreak: widget.isFromBreak, model: !widget.isFromBreak ? newsModel! : null, breakModel: widget.isFromBreak ? widget.breakModel! : null),
                      otherMainDetails(),
                      // if (!widget.isFromBreak) likeBtn(context, newsModel!),
                    ])),
              ),
              Visibility(
                visible: showw,
                child: Expanded(
                  flex: 2,
                  child: Container(
                    // height: 50,
                    // width: 10,
                    color: Colors.grey.shade300,
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        InkWell(
                          onTap: (){
                            Navigator.of(context).pushNamed(Routes.managePref, arguments: {"from": 2});
                          },

                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  UiUtils.getImagePath("Category.png",),
                                  fit: BoxFit.cover,
                                  height: height! * 0.055,
                                  width: width! * 0.112,
                                  // height: 50,
                                  // width: 50,
                                ),
                                // ),
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(top: 4.0),
                                    child: CustomTextLabel(
                                      text: 'Category',
                                      maxLines: 2,
                                      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), fontSize: 13.0, fontWeight: FontWeight.w500),
                                    ))
                              ]),
                        ),

                        InkWell(
                          onTap: () {
                            setState(() {
                              showw = false;
                            });
                            // var container = ScreenshotWidget(context);
                            screenshotController
                                .capture(delay: Duration(seconds: 1)).then((capturedImage) async {
                                  setState(() {
                                    showw = true;
                                  });

                                  var inviteMessage = "Unlock endless learning possibilities with osmo!"
                                      " \n Download the app now and watch your child's imagination life."
                                      "Get the app here ---> link";

                                  var image = capturedImage;

                                  final dir = await getApplicationDocumentsDirectory();
                                  final imagePath = await File('${dir.path}/captured.png').create();
                                  await imagePath.writeAsBytes(image!);

                                  XFile file = new XFile(imagePath.path);

                                  // await Share.shareFiles([imagePath.path]);

                                  Share.shareXFiles([file], text: inviteMessage);

                              // ShowCapturedWidget(context, capturedImage!);
                            });


                            // screenshotController
                            //     .capture().then((capturedImage) {
                            //   ShowCapturedWidget(context, capturedImage!);
                            // });

                          },

                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  UiUtils.getImagePath("Share.png",),
                                  fit: BoxFit.cover,
                                  height: height! * 0.055,
                                  width: width! * 0.112,
                                  // height: 50,
                                  // width: 50,
                                ),
                                // ),
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(top: 4.0),
                                    child: CustomTextLabel(
                                      text: 'Share',
                                      maxLines: 2,
                                      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), fontSize: 13.0, fontWeight: FontWeight.w500),
                                    ))
                              ]),
                        ),

                        BlocBuilder<BookmarkCubit, BookmarkState>(
                            bloc: context.read<BookmarkCubit>(),
                            builder: (context, bookmarkState) {
                              bool isBookmark = context.read<BookmarkCubit>().isNewsBookmark(newsModel!.id!);
                              print("checkkkkk ---> $isBookmark ${newsModel!.id!}");
                              return BlocConsumer<UpdateBookmarkStatusCubit, UpdateBookmarkStatusState>(
                                  bloc: context.read<UpdateBookmarkStatusCubit>(),
                                  listener: ((context, state) {
                                    if (state is UpdateBookmarkStatusSuccess) {
                                      if (state.wasBookmarkNewsProcess) {
                                        context.read<BookmarkCubit>().addBookmarkNews(state.news);
                                      } else {
                                        context.read<BookmarkCubit>().removeBookmarkNews(state.news);
                                      }
                                    }
                                  }),
                                  builder: (context, state) {
                                    return InkWell(
                                        onTap: () {
                                          print("pressed--> ");
                                          if (context.read<AuthCubit>().getUserId() != "0") {
                                            if (state is UpdateBookmarkStatusInProgress) {
                                              return;
                                            }
                                            context.read<UpdateBookmarkStatusCubit>().setBookmarkNews(
                                              context: context,
                                              userId: context.read<AuthCubit>().getUserId(),
                                              news: newsModel!,
                                              status: (isBookmark) ? "0" : "1",
                                            );
                                          } else {
                                            loginRequired(context);
                                          }
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                          state is UpdateBookmarkStatusInProgress
                                              ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: showCircularProgress(true, Theme.of(context).primaryColor),
                                          )
                                              // : Icon(
                                            : isBookmark ? Image.asset(
                                            UiUtils.getImagePath("Bookmark_On.png",),
                                            fit: BoxFit.cover,
                                            height: height! * 0.056,
                                            width: width! * 0.112,
                                            // height: 50,
                                            // width: 50,
                                          ) : Image.asset(
                                            UiUtils.getImagePath("Bookmark_off.png",),
                                            fit: BoxFit.cover,
                                            // height: height! * 0.075,
                                            // width: width! * 0.15,
                                            height: height! * 0.055,
                                            width: width! * 0.112,
                                          ),
                                          // ),
                                          Padding(
                                              padding: const EdgeInsetsDirectional.only(top: 4.0),
                                              child: CustomTextLabel(
                                                text: 'BookMarks',
                                                maxLines: 2,
                                                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8), fontSize: 13.0, fontWeight: FontWeight.w500),
                                              ))
                                        ]));
                                  });
                            }),

                        // Image.asset(UiUtils.getImagePath("Share.png")),
                        // Image.asset(UiUtils.getImagePath("Share.png")),
                      ],
                    ),
                  ),
                ),
              ),
              if ((context.read<AppConfigurationCubit>().getInAppAdsMode() == "1") || _bannerAd != null) Flexible(child: setBannerAd(context, _bannerAd))
            ]),
          ),
        ),
      ),
    );
  }
}
