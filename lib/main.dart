import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cubits/subscription_cubit.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const BibillApp());
}

class BibillApp extends StatelessWidget {
  const BibillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => SubscriptionCubit())],
      child: MaterialApp(
        title: 'Bibill',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.outfitTextTheme(),
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const HomePage(),
      ),
    );
  }
}
