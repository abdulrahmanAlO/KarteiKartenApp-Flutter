import 'package:flutter/material.dart';
import 'package:flutter_application_final_project/Modells/Notiz.dart';
import 'package:flutter_application_final_project/Modells/UserServices.dart';
import 'package:flutter_application_final_project/Pages/InstructionPage.dart';
import 'package:flutter_application_final_project/Pages/LoginPage.dart';
import 'package:flutter_application_final_project/Pages/ModulePage.dart';
import 'package:flutter_application_final_project/theme/app_theme.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:envied/envied.dart';
part 'main.g.dart';

// main.dart
@Envied(path: 'lib/.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL', defaultValue: 'your.supabase.invalid')
  static const String supabaseUrl = _Env.supabaseUrl;
  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static String supabaseAnonKey = _Env.supabaseAnonKey;
}

Future<void> main() async {
 
  // Hive registeren
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NotizAdapter());
  //Supabase initialize
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  // json Laden supase simulation

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AACARDS-APP',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: <String, WidgetBuilder>{
        '/Module': (BuildContext context) => ModulePage(title: 'Welcome'),
        '/Login': (BuildContext context) => LoginScreen(),
      },
    );
  }
}

// Auth Wrapper that checks if user is logged in
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() =>  _AuthWrapperState();
}
class  _AuthWrapperState extends State<AuthWrapper> {
  

  Future<User?> _getUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;
    return Supabase.instance.client.auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getUser(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          // Load user data to determine if we should show instructions
          return FutureBuilder(
            future: UserServices.loadPerson(snapshot.data),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (userSnapshot.hasData) {
                final userData = userSnapshot.data;
                final isLecturer = userData?['IsLecturer'] == true;
                // Show instructions first, then user can navigate to ModulePage
                return InstructionPage(isLecturer: isLecturer);
              }
              
              return const ModulePage(title: 'Welcome');
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  void SignUp(){
    Navigator.pushNamed(context, '/Regster');
  }
  void Login(){
 Navigator.pushNamed(context, '/Login');
  }

  @override
  Widget build(BuildContext context) {
    Login();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FloatingActionButton(
                heroTag: "SingUP",
              onPressed: SignUp,
              tooltip: 'SignUp',
              child: Text("SignUp"),
            ),
             FloatingActionButton(
               heroTag: "Login",
              onPressed: Login,
              tooltip: 'Login',
              child: Text("Login"),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Module');
                },
                child: Text('Zur Module'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
       
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
