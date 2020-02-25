class AudioFile {
  String path;
  String uri;
  String title;

  AudioFile({this.path, this.uri, this.title});

  update({String newPath, String newUri, String newTitle}) {
    if (newPath != null) {
      this.path = newPath;
    }
    if (newUri != null) {
      this.uri = newUri;
    }
    if (newTitle != null) {
      this.title = newTitle;
    }
  }
}
