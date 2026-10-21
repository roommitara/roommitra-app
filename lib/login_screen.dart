import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_shell.dart';
import 'theme.dart';
import 'otp_service.dart';
import 'strings.dart';
import 'terms_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _phoneFocus = FocusNode();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();
  final _scroll = ScrollController();

  Timer? _timer;
  int _seconds = 0;

  bool _otpSent = false;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  bool _googleBusy = false;
  bool _navigated = false;

  String _sentTo = '';
  String? _phoneError;
  String? _otpRequestId;

  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();

    _otpFocus.addListener(() {
      if (mounted) setState(() {});
    });

    // Google लॉगिन से लौटने पर (या किसी भी तरह साइन-इन होने पर) होम खोलना
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        _goHome();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _timer?.cancel();
    _phone.dispose();
    _phoneFocus.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _msg(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
  }

  void _goHome() {
    if (!mounted || _navigated) return;
    _navigated = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _googleLogin() async {
    if (_googleBusy || _sendingOtp || _verifyingOtp) return;
    setState(() => _googleBusy = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'roommitra://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (e) {
      if (mounted) {
        _msg(t('Google लॉगिन नहीं हो सका: ${e.message}',
            'Google login failed: ${e.message}'));
      }
    } catch (_) {
      if (mounted) {
        _msg(t('Google लॉगिन नहीं खुल सका। इंटरनेट जाँचकर फिर कोशिश करें।',
            'Could not open Google login. Check your internet and try again.'));
      }
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() => _seconds = 45);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phone.text.trim();

    if (phone.length != 10 ||
        !RegExp(r'^[6-9]').hasMatch(phone) ||
        !RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() {
        _phoneError = t(
          'कृपया सही 10 अंकों का मोबाइल नंबर दर्ज करें',
          'Please enter a valid 10-digit mobile number',
        );
      });
      return;
    }

    if (_sendingOtp || _verifyingOtp) return;

    if (_otpSent && _seconds > 0 && phone == _sentTo) {
      _msg(t('OTP पहले ही भेजा जा चुका है', 'OTP has already been sent'));
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _phoneError = null;
      _sendingOtp = true;
    });

    try {
      final result = await OtpService.sendOtp(phone);

      final nested = result['data'];

      final requestId = result['requestId'] ??
          result['otpRequestId'] ??
          (nested is Map
              ? (nested['requestId'] ?? nested['otpRequestId'])
              : null);

      if (requestId == null || requestId.toString().isEmpty) {
        throw Exception(
          t(
            'OTP request ID नहीं मिला। OTP API का response चेक करें।',
            'OTP request ID not found. Check the OTP API response.',
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _otpSent = true;
        _sentTo = phone;
        _otpRequestId = requestId.toString();
        _otp.clear();
      });

      _startTimer();
      _msg(
        t(
          'OTP भेजने की रिक्वेस्ट सफल रही। अपना SMS चेक करें।',
          'OTP request sent. Please check your SMS.',
        ),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _otpFocus.requestFocus();
      });
    } catch (e) {
      if (mounted) {
        _msg(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _sendingOtp = false);
      }
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0 || _sendingOtp || _verifyingOtp) return;

    _otp.clear();
    await _sendOtp();
  }

  void _onOtpChanged(String value) {
    setState(() {});

    if (value.length == 6 && !_verifyingOtp) {
      _verify();
    }
  }

  Future<void> _verify() async {
    final requestId = _otpRequestId;
    final code = _otp.text.trim();

    if (requestId == null || requestId.isEmpty) {
      _msg(t('पहले OTP भेजें।', 'Send the OTP first.'));
      return;
    }

    if (code.length != 6 || _verifyingOtp) return;

    FocusScope.of(context).unfocus();

    setState(() => _verifyingOtp = true);

    try {
      final verified = await OtpService.verifyOtp(
        requestId: requestId,
        otpCode: code,
      );

      if (!mounted) return;

      if (!verified) {
        _msg(
          t(
            'गलत OTP है। कृपया दोबारा जाँचें।',
            'Wrong OTP. Please check again.',
          ),
        );
        _otp.clear();
        return;
      }

      _msg(t('OTP सत्यापित हो गया।', 'OTP verified.'));
      _goHome();
    } catch (e) {
      if (mounted) {
        _msg(e.toString().replaceFirst('Exception: ', ''));
        _otp.clear();
      }
    } finally {
      if (mounted) {
        setState(() => _verifyingOtp = false);
      }
    }
  }

  void _goToPhone() {
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _phoneFocus.requestFocus();
  }

  String get _phoneShown {
    final phone = _sentTo;

    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }

    return '+91';
  }

  Widget _langToggle() {
    return InkWell(
      onTap: AppLang.toggle,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              AppLang.isHindi ? 'English' : 'हिंदी',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: _back,
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.text,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/logo.png',
              width: 46,
              height: 46,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Room',
                        style: TextStyle(color: AppColors.primaryDark),
                      ),
                      TextSpan(
                        text: 'Mitra',
                        style: TextStyle(color: Color(0xFF3FAE5A)),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  t('कमरा ढूँढना हुआ आसान।', 'Finding a room made easy.'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _langToggle(),
        ],
      ),
    );
  }

  Widget _hero(double width) {
    return SizedBox(
      height: 215,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 6,
            width: width * 0.55,
            child: Image.asset(
              'assets/login_art.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 20,
            top: 22,
            width: width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('आपका स्वागत है', 'Welcome'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 46,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3FAE5A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t(
                    'RoomMitra में लॉगिन करके अपने लिए सही कमरा खोजें।',
                    'Log in to RoomMitra and find the right room for you.',
                  ),
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String first, String second) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$first\n$second',
              style: TextStyle(
                fontSize: 11,
                height: 1.25,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureDivider() {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.border,
    );
  }

  Widget _features() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          _feature(
            Icons.verified_user,
            t('सुरक्षित', 'Secure'),
            t('लॉगिन', 'login'),
          ),
          _featureDivider(),
          _feature(
            Icons.home,
            t('सही और', 'Genuine and'),
            t('विश्वसनीय लिस्टिंग', 'trusted listings'),
          ),
          _featureDivider(),
          _feature(
            Icons.bolt,
            t('तेज़ और', 'Quick and'),
            t('आसान प्रक्रिया', 'easy process'),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    );
  }

  Widget _phoneCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(
                        'मोबाइल नंबर से लॉगिन करें',
                        'Login with mobile number',
                      ),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t(
                        'अपना 10 अंकों का मोबाइल नंबर दर्ज करें।',
                        'Enter your 10-digit mobile number.',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _phoneError != null
                    ? AppColors.danger
                    : AppColors.border,
                width: 1.3,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('🇮🇳', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColors.text,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phone,
                    focusNode: _phoneFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                    onSubmitted: (_) => _sendOtp(),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text,
                      letterSpacing: 1,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: t(
                        'मोबाइल नंबर दर्ज करें',
                        'Enter mobile number',
                      ),
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: AppColors.muted,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_phoneError != null) ...[
            const SizedBox(height: 6),
            Text(
              _phoneError!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.danger,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _sendingOtp ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _sendingOtp
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t('OTP भेजें', 'Send OTP'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              t('या', 'or'),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }

  Widget _otpBoxes() {
    final value = _otp.text;

    return GestureDetector(
      onTap: () => _otpFocus.requestFocus(),
      child: Stack(
        children: [
          Row(
            children: List.generate(6, (index) {
              final hasValue = index < value.length;
              final active = _otpFocus.hasFocus &&
                  (index == value.length ||
                      (value.length == 6 && index == 5));

              return Expanded(
                child: Container(
                  height: 54,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active
                          ? AppColors.primary
                          : AppColors.border,
                      width: active ? 1.8 : 1.2,
                    ),
                  ),
                  child: Text(
                    hasValue ? value[index] : '–',
                    style: TextStyle(
                      fontSize: hasValue ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: hasValue
                          ? AppColors.text
                          : AppColors.muted,
                    ),
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _otp,
                focusNode: _otpFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: _onOtpChanged,
                showCursor: false,
                enableInteractiveSelection: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpCard() {
    final secondsText = _seconds.toString().padLeft(2, '0');
    final canResend = _otpSent && _seconds == 0 && !_sendingOtp;

    return Opacity(
      opacity: _otpSent ? 1 : 0.6,
      child: IgnorePointer(
        ignoring: !_otpSent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 44,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('OTP दर्ज करें', 'Enter OTP'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _otpSent
                            ? Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: t(
                                        'आपके मोबाइल नंबर ',
                                        'Enter the 6-digit OTP sent to ',
                                      ),
                                    ),
                                    TextSpan(
                                      text: _phoneShown,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    TextSpan(
                                      text: t(
                                        ' पर भेजा गया 6 अंकों का OTP दर्ज करें।',
                                        '.',
                                      ),
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              )
                            : Text(
                                t(
                                  'पहले ऊपर नंबर डालकर OTP भेजें।',
                                  'First enter your number above and send the OTP.',
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _otpBoxes(),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: canResend ? _resend : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 20,
                        color: canResend
                            ? AppColors.primary
                            : AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _sendingOtp
                            ? t('OTP भेजा जा रहा है...', 'Sending OTP...')
                            : _seconds > 0
                                ? t(
                                    'OTP दोबारा भेजें (00:$secondsText)',
                                    'Resend OTP (00:$secondsText)',
                                  )
                                : t('OTP दोबारा भेजें', 'Resend OTP'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: canResend
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: canResend
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_verifyingOtp) ...[
                const SizedBox(height: 12),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: _googleBusy ? null : _googleLogin,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: AppColors.primary,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _googleBusy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      t('Google से जारी रखें', 'Continue with Google'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _alreadyHaveAccount() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: InkWell(
        onTap: _goToPhone,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 22,
                color: AppColors.text,
              ),
              const SizedBox(width: 8),
              Text(
                t('पहले से अकाउंट है? ', 'Already have an account? '),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                ),
              ),
              Text(
                t('लॉगिन करें', 'Log in'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _link(String hi, String en, int tab) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TermsScreen(initialTab: tab)),
      ),
      child: Text(
        t(hi, en),
        style: TextStyle(
          fontSize: 12.5,
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _terms() {
    final style = TextStyle(
      fontSize: 12.5,
      color: AppColors.muted,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            t(
              'लॉगिन करते समय आप हमारी ',
              'By logging in, you agree to our ',
            ),
            style: style,
          ),
          _link('नियम और शर्तें', 'Terms & Conditions', 0),
          Text(t(' और ', ' and '), style: style),
          _link('गोपनीयता नीति', 'Privacy Policy', 1),
          Text(t(' से सहमत होते हैं।', '.'), style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (AppTheme.isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: AppColors.bg,
            body: SafeArea(
              child: SingleChildScrollView(
                controller: _scroll,
                child: Column(
                  children: [
                    _logoRow(),
                    _hero(width),
                    _features(),
                    _phoneCard(),
                    _orDivider(),
                    _otpCard(),
                    _googleButton(),
                    _alreadyHaveAccount(),
                    _terms(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
