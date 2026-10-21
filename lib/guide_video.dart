import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'strings.dart';
import 'theme.dart';

/// फॉर्म के ऊपर आने वाली छोटी गाइड वीडियो (किरदार बोलकर समझाता है)।
/// - स्टेप खुलते ही एक बार अपने आप चलती है, फिर सिर्फ़ "दोबारा देखें" दबाने पर।
/// - वीडियो फ़ाइल न मिले तो चुपचाप कुछ नहीं दिखता।
class GuideVideo extends StatefulWidget {
  final String asset; // जैसे 'assets/guide_rent.mp4'
  final String hi;
  final String en;
  const GuideVideo(
      {super.key, required this.asset, required this.hi, required this.en});

  /// इस ऐप-सेशन में जिन वीडियो को अपने आप चल चुके हैं
  static final Set<String> _played = {};

  @override
  State<GuideVideo> createState() => _GuideVideoState();
}

class _GuideVideoState extends State<GuideVideo> {
  VideoPlayerController? _c;
  bool _ready = false;
  bool _failed = false;
  bool _muted = false;
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.asset(widget.asset);
      _c = c;
      await c.initialize();
      await c.setLooping(false);
      c.addListener(() {
        if (mounted) setState(() {});
      });
      if (!mounted) return;
      setState(() => _ready = true);
      if (GuideVideo._played.add(widget.asset)) {
        await c.play();
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// स्टेप बदलने पर Flutter वही State दोबारा इस्तेमाल करता है, इसलिए नई वीडियो यहाँ लोड करो
  @override
  void didUpdateWidget(covariant GuideVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) {
      _c?.dispose();
      _c = null;
      _ready = false;
      _failed = false;
      _hidden = false;
      _muted = false;
      _init();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  void _toggle() {
    final c = _c;
    if (c == null || !_ready) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      if (c.value.position >= c.value.duration) c.seekTo(Duration.zero);
      c.play();
    }
    setState(() {});
  }

  void _mute() {
    _c?.setVolume(_muted ? 1 : 0);
    setState(() => _muted = !_muted);
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    final c = _c;
    if (_hidden) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() => _hidden = false),
          icon: const Icon(Icons.play_circle_outline, size: 20),
          label: Text(t('गाइड वीडियो देखें', 'Watch guide video')),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      );
    }
    final playing = c?.value.isPlaying ?? false;
    final ended = _ready &&
        c!.value.duration > Duration.zero &&
        c.value.position >= c.value.duration;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _toggle,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 96,
                height: 170,
                child: _ready
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: c!.value.size.width,
                              height: c.value.size.height,
                              child: VideoPlayer(c),
                            ),
                          ),
                          if (!playing)
                            Container(
                              color: Colors.black26,
                              child: Icon(
                                  ended ? Icons.replay : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40),
                            ),
                        ],
                      )
                    : const Center(
                        child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('RoomMitra गाइड', 'RoomMitra guide'),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark),
                ),
                const SizedBox(height: 4),
                Text(
                  t(widget.hi, widget.en),
                  style: const TextStyle(
                      fontSize: 14, height: 1.35, color: AppColors.text),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InkWell(
                      onTap: _toggle,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                            playing
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            color: AppColors.primary),
                      ),
                    ),
                    InkWell(
                      onTap: _mute,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                            _muted ? Icons.volume_off : Icons.volume_up,
                            color: AppColors.primary),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _c?.pause();
                        setState(() => _hidden = true);
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.muted,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                      child: Text(t('बंद करें', 'Close')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
