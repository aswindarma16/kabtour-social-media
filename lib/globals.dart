import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// used for technical error that user doesn't need to know so the security risk of the technical error message used by others will be minimized
final String generalErrorMessage = "Oops, something went wrong, please try again";

// primary color
const Color kabtourGreen = Color(0xFF00C853);

// primary loading indicator
CircularProgressIndicator loadingProgressIndicator = CircularProgressIndicator(
  backgroundColor: Colors.white,
  valueColor: const AlwaysStoppedAnimation<Color>(
    kabtourGreen,
  ),
);

// format date if today show hour and minute, if not today show date dd/MM/yyyy
String formatPostDate(DateTime date) {
  final now = DateTime.now();
  final isToday = now.year == date.year &&
                  now.month == date.month &&
                  now.day == date.day;

  if (isToday) {
    return DateFormat('HH:mm').format(date);
  } else {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

List<String> availableVideoFormat = ['.mp4', '.mov', '.avi', '.mkv', '.3gp', '.temp'];

Future<File?> generateThumbnail(String videoPath) async {
  final thumbData = await VideoThumbnail.thumbnailData(
    video: videoPath,
    imageFormat: ImageFormat.PNG,
    maxWidth: 200,
    quality: 75,
  );

  if (thumbData == null) return null;

  final tempDir = Directory.systemTemp;
  final thumbFile = await File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(thumbData);
  return thumbFile;
}