import 'package:flutter/material.dart';

class AudioFile {
  String path;
  String uri;
  String title;
  Color color;
  int colorIndex;
  String background;

  AudioFile({
    String path,
    String uri,
    String title,
    Color color,
    int colorIndex,
    String background,
  }) {
    this.path = path;
    this.uri = uri;
    this.title = Uri.decodeComponent(title);
    this.color = color;
    this.colorIndex = colorIndex;
    this.background = background;
  }

  update({
    String newPath,
    String newUri,
    String newTitle,
    Color color,
    int colorIndex,
    String background,
  }) {
    if (newPath != null) {
      this.path = newPath;
    }
    if (newUri != null) {
      this.uri = newUri;
    }
    if (newTitle != null) {
      this.title = Uri.decodeComponent(newTitle);
    }
    if (color != null) {
      this.color = color;
    }
    if (background != null) {
      this.background = background;
    }
    if (colorIndex != null) {
      this.colorIndex = colorIndex;
    }
  }
}
