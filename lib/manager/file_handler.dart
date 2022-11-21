import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:simple_shopping_list/model/shopping_list.dart';

class FileHandler {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String name) async {
    final path = await _localPath;
    return File('$path/$name.json');
  }

  Future<void> deleteFile(String name) async {
    final file = await _localFile(name);
    file.delete();
  }

  Future<File> writeList(ShoppingList list) async {
    final file = await _localFile(list.name);
    // Write the file
    return file.writeAsString(json.encode(list));
  }

  Future<List<ShoppingList>> readLists() async {
    final path = await _localPath;
    List<ShoppingList> lists = [];
    List<FileSystemEntity> files = Directory(path).listSync();
    for (FileSystemEntity file in files) {
      if (file.path.endsWith('.json')) {
        File f = File(file.path);
        String contents = await f.readAsString();
        lists.add(ShoppingList.fromJson(json.decode(contents)));
      }
    }
    return lists;
  }
}
