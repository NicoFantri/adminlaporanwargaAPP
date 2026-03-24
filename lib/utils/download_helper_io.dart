import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(List<int> bytes, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes);
  
  // Try to share the file, or just save it and the user has to find it
  await Share.shareXFiles([XFile(file.path)], text: 'Data Laporan');
}
