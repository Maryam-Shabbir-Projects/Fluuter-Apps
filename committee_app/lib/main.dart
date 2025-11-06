import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/committee_provider.dart';
import 'ui/theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CommitteeApp());

}

class CommitteeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommitteeProvider()..load(),
      child: MaterialApp(
        title: 'Committee App',
        theme: AppTheme,
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
