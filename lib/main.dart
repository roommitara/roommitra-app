import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'app_shell.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'otp_service.dart';
import 'strings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? startupError;
  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } catch (e, st) {
    startupError = '$e\n\n$st';
  }

  if (startupError != null) {
    runApp(ErrorApp(message: startupError));
    return;
  }

  runApp(const RoomMitraApp());
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'स्टार्टअप एरर - इसका स्क्रीनशॉट भेजें',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    message,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoomMitraApp extends StatelessWidget {
  const RoomMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomMitra',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _video;
  Timer? _guard;
  bool _ready = false;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    // सुरक्षा: कुछ भी अटके तो 15 सेकंड बाद आगे बढ़ जाओ
    _guard = Timer(const Duration(seconds: 15), _goNext);
    _startVideo();
  }

  Future<void> _startVideo() async {
    try {
      final c = VideoPlayerController.asset('assets/intro.mp4');
      _video = c;
      await c.initialize();
      if (!mounted || _gone) return;
      await c.setLooping(false);
      c.addListener(_onTick);
      setState(() => _ready = true);
      await c.play();
    } catch (_) {
      // वीडियो न चले तो पुरानी इमेज थोड़ी देर दिखाकर आगे बढ़ो
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      _goNext();
    }
  }

  void _onTick() {
    final c = _video;
    if (c == null) return;
    final v = c.value;
    if (v.hasError) {
      _goNext();
      return;
    }
    if (v.isInitialized &&
        v.duration > Duration.zero &&
        v.position >= v.duration) {
      _goNext();
    }
  }

  void _goNext() {
    if (_gone || !mounted) return;
    _gone = true;
    _guard?.cancel();
    _video?.pause();

    // पहले से लॉगिन है तो सीधे ऐप खोलो
    bool loggedIn = false;
    try {
      loggedIn = Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      loggedIn = false;
    }
    if (loggedIn) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AppShell(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, __, ___) => OnboardingScreen(
          onFinish: () {
            Navigator.of(ctx).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => LoginScreen(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _guard?.cancel();
    _video?.removeListener(_onTick);
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _video;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // वीडियो लोड होने तक पुरानी स्प्लैश इमेज
          if (!_ready)
            SizedBox.expand(
              child: Image.asset('assets/splash.png', fit: BoxFit.cover),
            ),
          if (_ready && c != null)
            Center(
              child: AspectRatio(
                aspectRatio: c.value.aspectRatio,
                child: VideoPlayer(c),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: _goNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x66000000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t('छोड़ें', 'Skip'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
