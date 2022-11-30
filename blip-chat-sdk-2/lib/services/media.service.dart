import 'dart:convert';
import 'dart:io';

import 'package:blip_sdk/blip_sdk.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

import '../processors/media.processor.dart';
import 'message.service.dart';

abstract class MediaService {
  static Future<void> sendFiles(List<File> files) async {
    for (final file in files) {
      await sendFile(file);
    }
  }

  static Future<void> sendFile(File file) async {
    try {
      final document = await _uploadFile(file);

      MessageService.sendMediaLinkMessage(document);
    } catch (e) {
      // EventUtils.ShowError('Não foi possível carregar o arquivo.')
      print(e);
      return;
    }
  }

  static Future<Map<String, dynamic>> _uploadFile(File file) async {
    final command = await MediaProcessor.getMediaUploadUri();
    if (command.status != CommandStatus.success) {
      throw command.reason!.description!;
    }

    try {
      final mimeType = lookupMimeType(file.path) ?? '';
      final title = mimeType.contains('image') ? null : basename(file.path);
      final size = file.lengthSync();

      final document = {
        'title': title,
        'type': mimeType,
        'size': size,
      };

      final bytes = await file.readAsBytes();

      final response = await http.post(
        Uri.parse('${command.resource}?context=blipChat'),
        body: bytes,
        headers: {'Content-Type': mimeType},
      );

      final result = jsonDecode(response.body);
      document['uri'] = result['mediaUri'];

      return document;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
