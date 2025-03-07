import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  final String bucket = 'upload';
  String sanitizeFileName(String originalName) {
    return Uri.encodeComponent(originalName.replaceAll(' ', '_'));
  }

  Future<void> uploadFile(Uint8List fileBytes, String fileName) async {
    final sanitizedFileName = sanitizeFileName(fileName);
    await supabase.storage.from(bucket).uploadBinary(
          sanitizedFileName,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );
  }

  Future<List<String>> searchFiles(String keyword) async {
    final storage = supabase.storage.from(bucket);

    // You need to specify the folder to list files from.
    // If your files are in the root, this is just an empty string: ''
    final files = await storage.list(path: ''); // root folder or subfolder

    // Search files by keyword
    return files
        .where(
            (file) => file.name.toLowerCase().contains(keyword.toLowerCase()))
        .map((file) => file.name)
        .toList();
  }

  Future<List<String>> listAllFiles() async {
    final files = await supabase.storage.from(bucket).list();
    return files.map((f) => f.name).toList();
  }

  Future<void> deleteFile(String fileName) async {
    final sanitizedFileName = sanitizeFileName(fileName);
    print(sanitizedFileName);
    final response = await supabase.storage.from(bucket).remove(['terize.jpg']);

    if (response.isNotEmpty) {
      final errorMessage = response.first;
      throw Exception('Failed to delete file: $errorMessage');
    }
  }

  Future<Uint8List> downloadFileAsBytes(String fileName) async {
    final sanitizedFileName = sanitizeFileName(fileName);
    final response =
        await supabase.storage.from(bucket).download(sanitizedFileName);
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
   

   /*
   
    Future<List<Map<String, dynamic>>> listAllFiles() async {
    final response = await _supabase
        .from(bucketName)
        .select()
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> files =
        List<Map<String, dynamic>>.from(response);
    return files;
  }

  // ✅ Search files by name and date (metadata search from table)
  Future<List<Map<String, dynamic>>> searchFiles(
      String nameKeyword, String dateKeyword) async {
    try {
      final response = await _supabase
          .from(bucketName)
          .select()
          .ilike('name', '%$nameKeyword%')
          .ilike('created_at', '%$dateKeyword%');

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to search files: ${e.message}');
    }
  }

  // ✅ Upload file to Supabase Storage
  Future<void> uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(fileName, fileBytes);
    } on StorageException catch (e) {
      throw Exception('Failed to upload file: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during upload: $e');
    }
  }

  // ✅ Delete file from Supabase Storage (fully updated to handle FileObject)
  Future<void> deleteFile(String fileName) async {
    try {
      final result =
          await _supabase.storage.from(bucketName).remove([fileName]);

      // If no files were removed, you can optionally treat this as a failure
      if (result.isEmpty) {
        throw Exception('File not found or already deleted.');
      }

      // Optionally, check if the file deleted is really the one you wanted (but not strictly necessary)
      final deletedFile = result.first;
      if (deletedFile.name != fileName) {
        throw Exception('Unexpected file deleted: ${deletedFile.name}');
      }

      // Success — no need to manually check "isSuccess" because if remove() succeeds, it's good.
    } on StorageException catch (e) {
      throw Exception('Failed to delete file: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while deleting file: $e');
    }
  }

  // ✅ Download file (get URL to download from)
  Future<String> downloadFile(String fileName) async {
    try {
      final fileData = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(fileName, 60 * 60); // URL valid for 1 hour
      return fileData; // This is a public URL you can use to download.
    } on StorageException catch (e) {
      throw Exception('Failed to download file: ${e.message}');
    }
  }
   
   
     */