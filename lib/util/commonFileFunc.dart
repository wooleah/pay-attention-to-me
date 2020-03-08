import 'dart:io';
import 'dart:typed_data';

Future<File> moveFile(File sourceFile, String newPath, String fileName) async {
  try {
    // rename is faster than copy
    return await sourceFile.rename('$newPath/$fileName');
  } on FileSystemException {
    // if rename fails, copy the source file and delete it after copying
    final newFile = await sourceFile.copy('$newPath/$fileName');
    await sourceFile.delete();
    return newFile;
  }
}

Future<void> writeToFile(ByteData data, String path) {
  final buffer = data.buffer;
  return new File(path).writeAsBytes(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}