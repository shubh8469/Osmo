// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/utils/uiUtils.dart';

class CustomNetworkImage extends StatelessWidget {
  final String networkImageUrl;
  final double? width, height;
  final BoxFit? fit;
  final bool? isVideo;

  const CustomNetworkImage({Key? key, required this.networkImageUrl, this.width, this.height, this.fit, this.isVideo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
        fadeInDuration: const Duration(milliseconds: 150),
        image: NetworkImage(
          networkImageUrl,
        ),
        width: width ?? 100,
        height: height ?? 100,
        fit: fit ?? BoxFit.contain,
        placeholder: isVideo! ? AssetImage(UiUtils.getImagePath("Placeholder_video.jpg")) : AssetImage(UiUtils.getImagePath("placeholder.png")),
        imageErrorBuilder: ((context, error, stackTrace) {
          return Image.asset(
                  UiUtils.getImagePath("placeholder.png"),
                  width: width ?? 100,
                  height: height ?? 100,
                  fit: fit ?? BoxFit.contain,
                );
        }),
        placeholderErrorBuilder: ((context, error, stackTrace) {
          return isVideo!
              ? Image.asset(
                  UiUtils.getImagePath("Placeholder_video.jpg"),
                  width: width ?? 100,
                  height: height ?? 100,
                  fit: fit ?? BoxFit.contain,
                )
              : Image.asset(
                  UiUtils.getImagePath("placeholder.png"),
                  width: width ?? 100,
                  height: height ?? 100,
                  fit: fit ?? BoxFit.contain,
                );
        }));
  }
}
