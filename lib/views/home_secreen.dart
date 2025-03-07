import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model_view/file_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<FileViewModel>(context, listen: false);

    // Load files initially
    viewModel.loadAllFiles();

    // Real-time search listener
    _searchController.addListener(() {
      viewModel.searchFiles(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'File Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upload Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label:
                      const Text('Upload File', style: TextStyle(fontSize: 16)),
                  onPressed: () => viewModel.pickAndUploadFile(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                if (viewModel.isUploading) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],

                const SizedBox(height: 24),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Files',
                    labelStyle: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold),
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.searchFiles(''); // Clear search
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // File List Section
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: viewModel.files.isEmpty
                        ? const Center(
                            child: Text(
                              'No files found',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: viewModel.files.length,
                            itemBuilder: (context, index) {
                              final fileName = viewModel.files[index];

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                leading: const Icon(Icons.file_present,
                                    color: Colors.teal),
                                title: Text(
                                  fileName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Download Icon with Progress
                                    viewModel.fileDownloadInProgress[
                                                fileName] ==
                                            true
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.download,
                                                color: Colors.teal),
                                            onPressed: () =>
                                                viewModel.downloadFile(
                                                    fileName, context),
                                          ),

                                    // Delete Icon with Progress
                                    viewModel.fileDeleteInProgress[fileName] ==
                                            true
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => viewModel
                                                .deleteFile(fileName, context),
                                          ),
                                  ],
                                ),
                                tileColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
