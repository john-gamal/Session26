import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'cubit/notes_cubit.dart';
import 'screens/notes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    BlocProvider(create: (_) => NotesCubit()..getNotes(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firestore CRUD',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const NotesScreen(),
    );
  }
}
