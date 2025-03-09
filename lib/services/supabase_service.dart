import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  final String bucket = 'upload';

  Future<void> uploadFile(Uint8List fileBytes, String fileName) async {
    
    await supabase.storage.from(bucket).uploadBinary(
          fileName,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );
  }

  Future<List<String>> listAllFiles() async {
    final files = await supabase.storage.from(bucket).list();
    return files.map((f) => f.name).toList();
  }

  Future<FileObject> deleteFile(String fileName) async {
    final response = await supabase.storage.from(bucket).remove([fileName]);

    return response.first;
  }

  Future<Uint8List> downloadFileAsBytes(String fileName) async {
    final response = await supabase.storage.from(bucket).download(fileName);
    return response;
  }

  Future<void> saveFileForUser(String fileName, Uint8List fileBytes) async {
    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: fileBytes,
        mimeType: MimeType
            .other, // Or customize if you know the exact type (pdf, png, etc.)
      );
    } else {
      throw UnsupportedError(
          'saveFileForUser() is only implemented for Web for now.');
    }
  }
}
