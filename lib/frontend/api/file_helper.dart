import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FileHelper {
  Future<String> downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/temp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  String formatLikes(int likes) {
    if (likes >= 1000000000) {
      return '${(likes / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B'; // Billions
    } else if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    } else {
      return '$likes';
    }
  }
}
