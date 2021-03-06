import 'package:flutter/material.dart';

class FileNameDialog extends StatefulWidget {
  final String currentName;

  const FileNameDialog({this.currentName});

  @override
  _FileNameDialogState createState() => _FileNameDialogState();
}

class _FileNameDialogState extends State<FileNameDialog> {
  TextEditingController _fileNameTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fileNameTextFieldController.text = widget.currentName;
  }

  @override
  void dispose() {
    _fileNameTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Name of your file?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(controller: _fileNameTextFieldController),
      actions: <Widget>[
        FlatButton(
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: const Text(
            'OK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            if (_fileNameTextFieldController.text == widget.currentName ||
                _fileNameTextFieldController.text.isEmpty) return;
            Navigator.of(context).pop(_fileNameTextFieldController.text);
          },
          disabledColor: Colors.white10,
        ),
      ],
    );
  }
}
