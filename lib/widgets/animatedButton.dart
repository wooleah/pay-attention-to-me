import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:heyListen/models/audiofile.dart';

class AnimatedButton extends StatefulWidget {
  final AudioFile audioFile;
  final double itemFontSize;
  final Function onTapCb;

  AnimatedButton({
    this.audioFile,
    this.itemFontSize,
    this.onTapCb,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  // Animation for voice button
  double _voiceBtnScale;
  AnimationController _voiceBtnController;

  @override
  void initState() {
    super.initState();

    _voiceBtnController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.06,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _voiceBtnController.dispose();
    super.dispose();
  }

  void _onVoiceBtnTapDown() {
    widget.onTapCb();
    _voiceBtnController.forward().whenCompleteOrCancel(() {
      _voiceBtnController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    _voiceBtnScale = 1 - _voiceBtnController.value;

    return GestureDetector(
      onTap: _onVoiceBtnTapDown,
      child: Transform.scale(
        scale: _voiceBtnScale,
        child: Container(
          decoration: BoxDecoration(
            color: widget.audioFile.color,
            image: widget.audioFile.background != ''
                ? DecorationImage(
                    image: AssetImage(widget.audioFile.background),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.7),
                      BlendMode.srcIn,
                    ),
                  )
                : null,
            borderRadius: BorderRadius.circular(15),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black,
            //     blurRadius: 20.0, // has the effect of softening the shadow
            //     spreadRadius: 5.0, // has the effect of extending the shadow
            //     offset: Offset(
            //       5.0, // horizontal, move right 10
            //       5.0, // vertical, move down 10
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
                    widget.audioFile.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.itemFontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              Icon(
                Octicons.chevron_left,
                color: Colors.white,
                size: 25,
              ),
              SizedBox(width: 10)
            ],
          ),
        ),
      ),
    );
  }
}
