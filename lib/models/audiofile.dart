import 'package:flutter/material.dart';

class AudioFile {
  String path;
  String uri;
  String title;
  Color color;
  int colorIndex;

  AudioFile({this.path, this.uri, this.title, this.color, this.colorIndex});

  update({String newPath, String newUri, String newTitle, Color color, int colorIndex}) {
    if (newPath != null) {
      this.path = newPath;
    }
    if (newUri != null) {
      this.uri = newUri;
    }
    if (newTitle != null) {
      this.title = newTitle;
    }
    if (color != null) {
      this.color = color;
    }
    if (colorIndex != null) {
      this.colorIndex = colorIndex;
    }
  }
}
