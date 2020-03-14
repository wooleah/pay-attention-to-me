import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:heyListen/util/commonFileFunc.dart';
import 'package:heyListen/util/settingsManager.dart';
import 'package:heyListen/widgets/file_name_dialog.dart';
import 'package:heyListen/widgets/recorder.dart';
import 'package:reorderables/reorderables.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:firebase_admob/firebase_admob.dart';

import 'constants.dart' as Constants;
import 'models/audiofile.dart';
import './settings_page.dart';
import './widgets/edit_color_dialog.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

import 'models/customTheme.dart';
import 'widgets/animatedButton.dart';

class HomeScreen extends StatefulWidget {
  final dynamic initialTheme;
  final double initialItemFontSize;
  final List<AudioFile> initialAudioFileList;
  final int initialLastColorIndex;

  const HomeScreen(
      {this.initialTheme,
      this.initialItemFontSize,
      this.initialAudioFileList,
      this.initialLastColorIndex});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterSound flutterSound;
  List<AudioFile> _audioFileList;
  int _currentPageIndex = 0;
  PageController _pageController;
  final SlidableController _slidableController = SlidableController();
  CustomTheme _theme;
  double _itemFontSize;
  int _lastColorIndex = 0;
  bool isAdClickable = true;

  InterstitialAd _myInterstitial;
  MobileAdTargetingInfo _targetingInfo;

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSound();
    _pageController = PageController();

    // Initialize theme
    _theme = widget.initialTheme;
    _itemFontSize = widget.initialItemFontSize;
    _lastColorIndex = widget.initialLastColorIndex;
    _audioFileList = widget.initialAudioFileList;

    // Initialize Ad
    FirebaseAdMob.instance.initialize(appId: Constants.ADMOB_ID);
    _targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['sound', 'play', 'fun', 'soundboard', 'record'],
      // contentUrl: 'https://flutter.io',
      childDirected: true,
      testDevices: <String>[], // Android emulators are considered test devices
    );
    _myInterstitial = createInterstitialAd()..load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _myInterstitial?.dispose();
    super.dispose();
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      // adUnitId: Constants.PROD_ADUNIT_ID,
      adUnitId: Constants.TEST_ADUNIT_ID,
      targetingInfo: _targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.closed ||
            event == MobileAdEvent.failedToLoad) {
          setState(() {
            isAdClickable = true;
          });
        }
        // print("InterstitialAd event is $event");
      },
    );
  }

  Widget _getVoiceItem(BuildContext context, int index) {
    AudioFile audioFile = _audioFileList[index];
    File file = File(audioFile.path);

    return Slidable(
      key: Key(audioFile.uri),
      controller: _slidableController,
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: AnimatedButton(
        audioFile: audioFile,
        itemFontSize: _itemFontSize,
        onTapCb: () => startPlayer(audioFile.path),
      ),
      actions: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 6, left: 6),
          child: SlideAction(
            decoration: BoxDecoration(
              color: Constants.shareColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              MaterialIcons.share,
              color: Colors.white,
              size: 30,
            ),
            onTap: () async {
              try {
                final Uint8List bytes = File(audioFile.path).readAsBytesSync();
                await Share.file(audioFile.title, path.basename(audioFile.path),
                    bytes.buffer.asUint8List(), '	audio/*',
                    text: 'testing share');
              } catch (err) {
                return;
              }
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 6, left: 6),
          child: SlideAction(
            decoration: BoxDecoration(
                color: Constants.editColor,
                borderRadius: BorderRadius.circular(15)),
            child: Icon(
              MaterialIcons.color_lens,
              color: Colors.white,
              size: 30,
            ),
            onTap: () async {
              int newColorIndex = await _showEditColorDialog(
                  context, _theme, audioFile.colorIndex);
              if (newColorIndex == null) return;

              setState(() {
                audioFile.update(
                    color: _theme.themeSet[newColorIndex]['color'],
                    colorIndex: newColorIndex);
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
                borderRadius: BorderRadius.circular(15)),
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

              // Update fileUriOrderList in sharedPref
              saveEncodedFileOrderList(_audioFileList);
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 6, right: 6),
          child: SlideAction(
            decoration: BoxDecoration(
                color: Constants.wrongColor,
                borderRadius: BorderRadius.circular(15)),
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
              _lastColorIndex--;
              if (_lastColorIndex < 0) {
                _lastColorIndex = _theme.themeSet.length - 1;
              }

              // Update fileUriOrderList in sharedPref
              saveEncodedFileOrderList(_audioFileList);
            },
          ),
        ),
      ],
    );
  }

  Future<String> _showFileNameDialog(
      BuildContext context, String currentName) async {
    return showDialog(
      context: context,
      builder: (context) {
        return FileNameDialog(currentName: currentName);
      },
    );
  }

  Future<int> _showEditColorDialog(BuildContext context,
      CustomTheme currentTheme, int currentColorIndex) async {
    List<Color> _currentColorList = currentTheme.colors;

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

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    setState(() {
      AudioFile removedAudioFile = _audioFileList.removeAt(oldIndex);
      _audioFileList.insert(newIndex, removedAudioFile);
    });

    // Update fileUriOrderList in sharedPref
    saveEncodedFileOrderList(_audioFileList);
  }

  Future<void> startPlayer(uri) async {
    try {
      await flutterSound.stopPlayer();
    } catch (err) {} finally {
      await flutterSound.startPlayer(uri);
    }
  }

  Future<void> stopPlayer() async {
    try {
      await flutterSound.stopPlayer();
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Make sure there is a scroll controller attached to the scroll view that contains ReorderableSliverList.
    // Otherwise an error will be thrown.
    ScrollController _scrollController =
        PrimaryScrollController.of(context) ?? ScrollController();

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
                    backgroundColor: _theme.appTitleBackgroundColor,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(
                          MaterialCommunityIcons.gift,
                          color: _theme.appTitleColor,
                        ),
                        disabledColor: _theme.appTitleColor.withOpacity(0.3),
                        onPressed: isAdClickable
                            ? () async {
                                // Prevent ad multi-clicking
                                if (isAdClickable == false) {
                                  return;
                                }
                                setState(() {
                                  isAdClickable = false;
                                });

                                // Stop audio
                                stopPlayer();
                                // Show ad
                                _myInterstitial?.dispose();
                                _myInterstitial = createInterstitialAd()
                                  ..load()
                                  ..show();
                              }
                            : null,
                      )
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Hey, Listen to this',
                        style: TextStyle(
                          // height: 0.4,
                          color: _theme.appTitleColor,
                          fontFamily: 'AmaticSC',
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      centerTitle: true,
                      background: Image.asset(
                        _theme.appBarImagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  ReorderableSliverList(
                    delegate: ReorderableSliverChildListDelegate(
                      List.generate(_audioFileList.length,
                          (index) => _getVoiceItem(context, index)),
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
              currentTheme: _theme,
              currentFontSize: _itemFontSize,
              onSettingsSave: (CustomTheme newTheme, double newFontSize) {
                saveSettings(
                  themeName: newTheme?.themeName,
                  fontSize: newFontSize,
                );
                setState(() {
                  _pageController.animateToPage(0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease);
                  if (newTheme != null) {
                    _theme = newTheme;
                    _audioFileList.forEach((audioFile) => audioFile.update(
                          color: newTheme.themeSet[audioFile.colorIndex]
                              ['color'],
                          background: newTheme.themeSet[audioFile.colorIndex]
                              ['background'],
                        ));
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
      bottomNavigationBar: SizedBox(
        height: 60,
        child: BubbleBottomBar(
          opacity: .2,
          currentIndex: _currentPageIndex,
          onTap: (index) => setState(() {
            _currentPageIndex = index;
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          }),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          elevation: 15,
          fabLocation: BubbleBottomBarFabLocation.end, //new
          hasNotch: true, //new
          hasInk: true, //new, gives a cute ink effect
          inkColor:
              Colors.black12, //optional, uses theme color if not specified
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
              backgroundColor: Constants.wrongColor,
              icon: Icon(
                MaterialIcons.dashboard,
                color: Colors.black,
              ),
              activeIcon: Icon(
                MaterialIcons.dashboard,
                color: Constants.wrongColor,
              ),
              title: Text(
                "Main",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            BubbleBottomBarItem(
              backgroundColor: Constants.correctColor,
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.settings,
                color: Constants.correctColor,
              ),
              title: Text(
                "Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _currentPageIndex == 0
          ? FloatingActionButton(
              // elevation: 0,
              child: Icon(Icons.add),
              backgroundColor: _theme.fabColor,
              foregroundColor: Colors.white,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Recorder(
                      onFileSaveCb: (File file) {
                        ++_lastColorIndex;
                        if (_lastColorIndex >= _theme.themeSet.length) {
                          _lastColorIndex = 0;
                        }

                        Map<String, dynamic> selectedThemeSet =
                            _theme.themeSet[_lastColorIndex];
                        setState(() {
                          _audioFileList.add(new AudioFile(
                            uri: file.uri.toString(),
                            path: file.path,
                            title: path.basenameWithoutExtension(file.path),
                            color: selectedThemeSet['color'],
                            background: selectedThemeSet['background'],
                            colorIndex: _lastColorIndex,
                          ));
                        });

                        // Update fileUriOrderList in sharedPref
                        saveEncodedFileOrderList(_audioFileList);

                        _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            curve: Curves.ease,
                            duration: const Duration(milliseconds: 700));
                      },
                      onFilesImportedCb: (List<File> files) {
                        files.forEach((file) {
                          ++_lastColorIndex;
                          if (_lastColorIndex >= _theme.themeSet.length) {
                            _lastColorIndex = 0;
                          }

                          Map<String, dynamic> selectedThemeSet =
                              _theme.themeSet[_lastColorIndex];
                          setState(() {
                            _audioFileList.add(new AudioFile(
                              uri: file.uri.toString(),
                              path: file.path,
                              title: path.basenameWithoutExtension(file.path),
                              color: selectedThemeSet['color'],
                              background: selectedThemeSet['background'],
                              colorIndex: _lastColorIndex,
                            ));
                          });
                        });

                        // Update fileUriOrderList in sharedPref
                        saveEncodedFileOrderList(_audioFileList);

                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 700),
                        );
                      },
                      theme: _theme,
                    );
                  },
                );
              },
            )
          : null,
    );
  }
}
