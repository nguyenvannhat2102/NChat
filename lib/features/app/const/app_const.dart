import 'package:chat/features/app/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';

void toast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
    backgroundColor: tabColor,
    textColor: whiteColor,
    fontSize: 16.0,
  );
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  GiphyGif? gif;
  try {
    gif = await GiphyPicker.pickGif(
        context: context, apiKey: 'XaQkXN5C6WHhqxWXDl4HTGPtNBf8jyJH');
  } catch (e) {
    toast(e.toString());
  }

  return gif;
}
