import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/home/home_bloc.dart';
import 'blocs/details/details_bloc.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'repository/dummy_content_repository.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const OTTApp());
}

class OTTApp extends StatelessWidget {
  const OTTApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DummyContentRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(repository: repository),
        ),
        BlocProvider(
          create: (context) => DetailsBloc(repository: repository),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(repository: repository),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'OTT Stream',
        theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
