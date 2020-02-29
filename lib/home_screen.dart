import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:pay_attention_to_me/util/commonFileFunc.dart';
import 'package:pay_attention_to_me/widgets/recorder.dart';
import 'package:reorderables/reorderables.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'constants.dart' as Constants;
import 'models/audiofile.dart';
import './settings_page.dart';
import './widgets/edit_color_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterSound flutterSound;
  // AssetsAudioPlayer assetsAudioPlayer;
  // List<FileSystemEntity> _audioFileList = new List();
  List<AudioFile> _audioFileList = new List();
  int _currentPageIndex = 0;
  PageController _pageController;
  TextEditingController _fileNameTextFieldController;
  final SlidableController _slidableController = SlidableController();
  var _theme = Constants.ColorTheme_sunset;
  int _itemFontSize = Constants.defaultFontSize;
  int _lastColorIndex = 0;

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSound();
    _pageController = PageController();
    _fileNameTextFieldController = TextEditingController();

    _fileNameTextFieldController.addListener(isFileNameEditTextFieldEmpty);

    _getListOfFiles();
  }

  @override
  void dispose() {
    // if (_recorderStatus == RecorderState.PLAYING) {
    //   flutterSound.stopPlayer();
    // }
    _pageController.dispose();
    _fileNameTextFieldController.dispose();
    super.dispose();
  }

  void isFileNameEditTextFieldEmpty() {

  }

  Widget _getVoiceItem(BuildContext context, int index) {
    AudioFile audioFile = _audioFileList[index];
    File file = File(audioFile.path);

    return Slidable(
      key: Key(audioFile.uri),
      controller: _slidableController,
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () => startPlayer(audioFile.path),
        child: Container(
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: audioFile.color,
              borderRadius: BorderRadius.circular(15),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.red,
              //     blurRadius: 20.0, // has the effect of softening the shadow
              //     spreadRadius: 5.0, // has the effect of extending the shadow
              //     offset: Offset(
              //       10.0, // horizontal, move right 10
              //       10.0, // vertical, move down 10
              //     ),
              //   )
              // ],
            ),
            margin: const EdgeInsets.only(top: 6, left: 6, right: 6),
            // padding: const EdgeInsets.only(left: 10),
            height: 100,
            child: Row(
              children: <Widget>[
                SizedBox(width: 10),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      audioFile.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _itemFontSize.toDouble(),
                        color: Colors.white,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                Icon(Octicons.chevron_left, color: Colors.white, size: 25,),
                SizedBox(width: 10)
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 6, left: 6),
          child: SlideAction(
            decoration: BoxDecoration(
              color: Constants.editColor,
              borderRadius: BorderRadius.circular(15)
            ),
            child: Icon(
              MaterialIcons.color_lens,
              color: Colors.white,
              size: 30,
            ),
            onTap: () async {
              int newColorIndex = await _showEditColorDialog(context, _theme, audioFile.colorIndex);
              if (newColorIndex == null) return;
              
              setState(() {
                audioFile.update(color: _theme['colors'][newColorIndex], colorIndex: newColorIndex);
              });
            },
          ),
        )
      ],
      secondaryActions: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 6, right: 6),
          child: SlideAction(
            decoration: BoxDecoration(
              color: Constants.correctColor,
              borderRadius: BorderRadius.circular(15)
            ),
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 30,
            ),
            onTap: () async {
              String newFileName =
                  await _showFileNameDialog(context, audioFile.title);
              if (newFileName == null) {
                return;
              }

              Directory docDir = await getApplicationDocumentsDirectory();
              File newFile = await moveFile(
                  file, '${docDir.path}/audio', '$newFileName.aac');

              setState(() {
                _audioFileList[index]
                    .update(newTitle: newFileName, newPath: newFile.path);
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 6, right: 6),
          child: SlideAction(
            decoration: BoxDecoration(
              color: Constants.wrongColor,
              borderRadius: BorderRadius.circular(15)
            ),
            child: Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 30,
            ),
            onTap: () {
              file.delete();
              setState(() {
                _audioFileList.removeAt(index);
              });
            },
          ),
        ),
      ],
    );
  }

  Future<String> _showFileNameDialog(
    BuildContext context, String currentName) async {
    _fileNameTextFieldController.text = currentName;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Name of your file?'),
          content: TextField(controller: _fileNameTextFieldController),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                if (_fileNameTextFieldController.text == currentName || _fileNameTextFieldController.text.isEmpty) return;
                Navigator.of(context).pop(_fileNameTextFieldController.text);
              },
              disabledColor: Colors.white10,
            ),
          ],
        );
      },
    );
  }

  Future<int> _showEditColorDialog(BuildContext context, dynamic currentTheme, int currentColorIndex) async {
    List<Color> _currentColorList = currentTheme['colors'];

    return showDialog(
      context: context,
      builder: (context) {
        return EditColorDialog(
          colorList: _currentColorList,
          initialColorIndex: currentColorIndex,
        );
      },
    );
  }

  Future<void> _getListOfFiles() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    int count = 0;
    setState(() {
      try {
        _audioFileList = Directory('${docDir.path}/audio')
            .listSync()
            .map((file) {
              int colorIndex = count++ % _theme['colors'].length;
              _lastColorIndex = colorIndex;
              return new AudioFile(
                uri: file.uri.toString(),
                path: file.path,
                title: path.basenameWithoutExtension(file.path),
                color: _theme['colors'][colorIndex],
                colorIndex: colorIndex,
              );
            })
            .toList();
        // _audioFileList = Directory('${docDir.path}/audio').listSync();
      } on FileSystemException {
        new Directory('${docDir.path}/audio').createSync();
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    setState(() {
      AudioFile removedAudioFile = _audioFileList.removeAt(oldIndex);
      _audioFileList.insert(newIndex, removedAudioFile);
    });
  }

  Future<void> startPlayer(uri) async {
    try {
      await flutterSound.stopPlayer();
    } catch (err) {} finally {
      await flutterSound.startPlayer(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make sure there is a scroll controller attached to the scroll view that contains ReorderableSliverList.
    // Otherwise an error will be thrown.
    ScrollController _scrollController = PrimaryScrollController.of(context) ?? ScrollController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          children: [
            Scrollbar(
              child: CustomScrollView(
                // A ScrollController must be included in CustomScrollView, otherwise
                // ReorderableSliverList wouldn't work
                controller: _scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    elevation: 8,
                    expandedHeight: 210.0,
                    backgroundColor: _theme['appTitleBackgroundColor'],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Hey, Listen to this',
                        style: TextStyle(
                          // height: 0.4,
                          color: _theme['appTitleColor'],
                          fontFamily: 'AmaticSC',
                          fontSize: 36,
                          fontWeight: FontWeight.w900
                        ),
                      ),
                      centerTitle: true,
                      background: Image.asset(_theme['appBarImagePath'], fit: BoxFit.contain),
                    ),
                  ),
                  ReorderableSliverList(
                    delegate: ReorderableSliverChildListDelegate(
                      List.generate(_audioFileList.length, (index) => _getVoiceItem(context, index)),
                      // addRepaintBoundaries: false,
                    ),
                    // or use ReorderableSliverChildBuilderDelegate if needed
                    //          delegate: ReorderableSliverChildBuilderDelegate(
                    //            (BuildContext context, int index) => _rows[index],
                    //            childCount: _rows.length
                    //          ),
                    onReorder: _onReorder,
                  )
                ],
              ),
            ),
            SettingsPage(
              onSettingsSave: (var newTheme, int newFontSize) {
                setState(() {
                  _pageController.animateToPage(0,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
                  if (newTheme != null) {
                    _theme = newTheme;
                    _audioFileList.forEach((audioFile) => audioFile.update(color: newTheme['colors'][audioFile.colorIndex]));
                  }
                  if (newFontSize != null) {
                    _itemFontSize = newFontSize;
                  }
                });
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        itemCornerRadius: 15,
        selectedIndex: _currentPageIndex,
        showElevation: true, // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
            _currentPageIndex = index;
            _pageController.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
        }),
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Colors.red,
          ),
          BottomNavyBarItem(
              icon: Icon(Icons.settings),
              title: Text('Settings'),
              activeColor: Colors.blue
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentPageIndex == 0 ? FloatingActionButton(
        elevation: 0,
          child: Icon(Icons.add),
          backgroundColor: _theme['FABColor'],
          foregroundColor: Colors.white,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Recorder(
                  onFileSaveCb: (File file) {
                    ++_lastColorIndex;
                    if (_lastColorIndex >= _theme['colors'].length) {
                      _lastColorIndex = 0;
                    }
                    setState(() {
                      _audioFileList.add(new AudioFile(
                        uri: file.uri.toString(),
                        path: file.path,
                        title: path.basenameWithoutExtension(file.path),
                        color: _theme['colors'][_lastColorIndex],
                        colorIndex: _lastColorIndex,
                      ));
                    });
                    _scrollController.animateTo(_scrollController.position.maxScrollExtent, curve: Curves.ease, duration: const Duration(milliseconds: 700));
                  },
                  theme: _theme,
                );
              },
            );
          },
        ) : null,
    );
  }
}
