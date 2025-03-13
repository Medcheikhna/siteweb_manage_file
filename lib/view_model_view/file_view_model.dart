import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class FileViewModel extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<String> _allFiles = [];
  List<String> _files = [];
  bool uploadSuccess = false;
  String errorMessage = '';
  bool isUploading = false;

  // Map to track loading states per file (download and delete)
  Map<String, bool> fileDownloadInProgress = {};
  Map<String, bool> fileDeleteInProgress = {};

  List<String> get files => _files;

  FileViewModel() {
    loadAllFiles();
  }

  Future<void> loadAllFiles() async {
    _allFiles = await _service.listAllFiles();
    _files = _allFiles;
    notifyListeners();
  }

  Future<void> uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      await _service.uploadFile(fileBytes, fileName);
      uploadSuccess = true;
      await loadAllFiles();
    } catch (e) {
      uploadSuccess = false;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> pickAndUploadFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null && result.files.isNotEmpty) {
      isUploading = true;
      notifyListeners();

      try {
        for (var file in result.files) {
          await uploadFile(file.bytes!, file.name);
        }

        isUploading = false;
        notifyListeners();

        await showResultDialog(context, 'Upload Successful',
            '${result.files.length} file(s) uploaded successfully!');
      } catch (e) {
        isUploading = false;
        notifyListeners();
        await showResultDialog(context, 'Upload Failed', e.toString());
      }
    } else {
      await showResultDialog(context, 'No File Selected',
          'Please select at least one file to upload.');
    }
  }

  Future<void> searchFiles(String keyword) async {
    final allFiles = await _service.listAllFiles();

    if (keyword.isEmpty) {
      _files = allFiles;
    } else {
      final lowerKeyword = keyword.toLowerCase();

      final startsWith = <String>[];
      final contains = <String>[];

      for (var file in allFiles) {
        final lowerFileName = file.toLowerCase();

        if (lowerFileName.startsWith(lowerKeyword)) {
          startsWith.add(file);
        } else if (lowerFileName.contains(lowerKeyword)) {
          contains.add(file);
        }
      }

      _files = [...startsWith, ...contains];
    }

    notifyListeners();
  }

  Future<void> deleteFile(String fileName, BuildContext context) async {
    try {
      fileDeleteInProgress[fileName] = true;
      notifyListeners();

      await _service.deleteFile(fileName);
      await loadAllFiles();

      await showResultDialog(context, 'File Deleted',
          'The file "$fileName" has been deleted successfully.');
    } catch (e) {
      fileDeleteInProgress[fileName] = false;
      notifyListeners();

      await showResultDialog(context, 'Delete Failed', e.toString());
    }
  }

  Future<void> downloadFile(String fileName, BuildContext context) async {
    try {
      fileDownloadInProgress[fileName] = true;
      notifyListeners();

      final fileBytes = await _service.downloadFileAsBytes(fileName);
      await _service.saveFileForUser(fileName, fileBytes);

      fileDownloadInProgress[fileName] = false;
      notifyListeners();

      await showResultDialog(context, 'Download Successful',
          'File "$fileName" has been downloaded.');
    } catch (e) {
      fileDownloadInProgress[fileName] = false;
      notifyListeners();

      await showResultDialog(context, 'Download Failed', e.toString());
    }
  }

  // 🔹 Confirmation Dialog for Delete
  Future<bool?> showDeleteConfirmationDialog(
      BuildContext context, String fileName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete $fileName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 🔹 Generic Result Dialog
  Future<void> showResultDialog(
      BuildContext context, String title, String message) async {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
