# Login screen integration notes

The current `lib/login_screen.dart` has demo-only `_sendOtp`, `_resend`, and
`_verify` methods. Replace the demo behavior with `RoomMitaraOtpService`:

1. Add:
   ```dart
   import 'otp_service.dart';
   ```
2. Add fields:
   ```dart
   String? _requestId;
   bool _sending = false;
   bool _verifying = false;
   ```
3. In `_sendOtp`, validate the 10-digit Indian number, call
   `final id = await RoomMitaraOtpService.send(p);`, then set `_requestId = id`,
   `_otpSent = true`, `_sentTo = p`, clear `_otp`, start the timer, and show
   “OTP भेज दिया गया है। SMS में आया कोड दर्ज करें।” Handle errors with `_msg`.
4. `_resend` should call `_sendOtp` again after the timer reaches zero.
5. In `_verify`, require `_requestId != null` and six digits, then call:
   ```dart
   final verified = await RoomMitaraOtpService.verify(
     requestId: _requestId!,
     otpCode: _otp.text.trim(),
   );
   ```
   Only proceed if `verified` is true; otherwise show an incorrect/expired OTP
   message. Prevent duplicate requests with `_verifying`.
6. Keep `http` in `pubspec.yaml` (it is already a dependency).

Do not leave the old “any six digits” demo behavior in place. Before public
release, complete Supabase Auth session creation and profile creation, then
test real send/verify on a physical device. Also add server-side rate limiting
and abuse protections before production.
