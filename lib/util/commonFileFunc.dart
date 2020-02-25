import 'dart:io';

Future<File> moveFile(File sourceFile, String newPath, String fileName) async {
  try {
    // rename is faster than copy
    return await sourceFile.rename('$newPath/$fileName');
  } on FileSystemException catch (err) {
    // if rename fails, copy the source file and delete it after copying
    final newFile = await sourceFile.copy('$newPath/$fileName');
    await sourceFile.delete();
    return newFile;
  }
}
