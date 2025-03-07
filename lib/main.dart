import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upload_file_site_web/view_model_view/file_viewmodel.dart';
import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ecqsgkarbdwyzzgmjfqv.supabase.co', // Replace
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjcXNna2FyYmR3eXp6Z21qZnF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA5NjExNzEsImV4cCI6MjA1NjUzNzE3MX0.6s3q9WstOFz_TWoU9eWkVNc70CJMujNOo3Q6RtAe-8o', // Replace
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FileViewModel()),
      ],
      child:  MyApp(),
    ),
  );
}
