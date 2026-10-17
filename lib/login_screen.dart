import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_shell.dart';
import 'theme.dart';
import 'otp_service.dart';

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

  String _sentTo = '';
  String? _phoneError;
  String? _otpRequestId;

  @override
  void initState() {
    super.initState();

    _otpFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
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
        _phoneError = 'कृपया सही 10 अंकों का मोबाइल नंबर दर्ज करें';
      });
      return;
    }

    if (_sendingOtp || _verifyingOtp) return;

    if (_otpSent && _seconds > 0 && phone == _sentTo) {
      _msg('OTP पहले ही भेजा जा चुका है');
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
          'OTP request ID नहीं मिला। OTP API का response चेक करें।',
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
      _msg('OTP भेजने की रिक्वेस्ट सफल रही। अपना SMS चेक करें।');

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
      _msg('पहले OTP भेजें।');
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
        _msg('गलत OTP है। कृपया दोबारा जाँचें।');
        _otp.clear();
        return;
      }

      _timer?.cancel();

      _msg('OTP सत्यापित हो गया।');

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

  Widget _logoRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: _back,
            icon: const Icon(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                const TextSpan(
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
              const Text(
                'कमरा ढूँढना हुआ आसान।',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
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
                const Text(
                  'आपका स्वागत है',
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
                const Text(
                  'RoomMitra में लॉगिन करके अपने लिए सही कमरा खोजें।',
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
              style: const TextStyle(
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
          _feature(Icons.verified_user, 'सुरक्षित', 'लॉगिन'),
          _featureDivider(),
          _feature(Icons.home, 'सही और', 'विश्वसनीय लिस्टिंग'),
          _featureDivider(),
          _feature(Icons.bolt, 'तेज़ और', 'आसान प्रक्रिया'),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
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
                decoration: const BoxDecoration(
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'मोबाइल नंबर से लॉगिन करें',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'अपना 10 अंकों का मोबाइल नंबर दर्ज करें।',
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
              color: Colors.white,
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
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: const Row(
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.text,
                      letterSpacing: 1,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'मोबाइल नंबर दर्ज करें',
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
              style: const TextStyle(
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'OTP भेजें',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'या',
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
                    color: Colors.white,
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
                  const Icon(
                    Icons.verified_user,
                    size: 44,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OTP दर्ज करें',
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
                                    const TextSpan(
                                      text: 'आपके मोबाइल नंबर ',
                                    ),
                                    TextSpan(
                                      text: _phoneShown,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          ' पर भेजा गया 6 अंकों का OTP दर्ज करें।',
                                    ),
                                  ],
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              )
                            : const Text(
                                'पहले ऊपर नंबर डालकर OTP भेजें।',
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
                            ? 'OTP भेजा जा रहा है...'
                            : _seconds > 0
                                ? 'OTP दोबारा भेजें (00:$secondsText)'
                                : 'OTP दोबारा भेजें',
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
          onPressed: () =>
              _msg('Google लॉगिन बैकएंड जुड़ने पर चालू होगा'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: AppColors.primary,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'G',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4285F4),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Google से जारी रखें',
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
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 22,
                color: AppColors.text,
              ),
              SizedBox(width: 8),
              Text(
                'पहले से अकाउंट है? ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                ),
              ),
              Text(
                'लॉगिन करें',
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

  Widget _link(String text) {
    return InkWell(
      onTap: () => _msg('$text जल्द जुड़ेगा'),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _terms() {
    const style = TextStyle(
      fontSize: 12.5,
      color: AppColors.muted,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('लॉगिन करते समय आप हमारी ', style: style),
          _link('Terms & Conditions'),
          const Text(' और ', style: style),
          _link('Privacy Policy'),
          const Text(' से सहमत होते हैं।', style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FCF9),
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
  }
}
