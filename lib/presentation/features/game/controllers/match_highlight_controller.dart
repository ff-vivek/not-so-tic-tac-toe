import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';

import 'package:not_so_tic_tac_toe_game/presentation/features/highlights/highlight_recorder.dart';
import 'package:not_so_tic_tac_toe_game/presentation/features/highlights/highlight_share_target.dart';
import 'package:not_so_tic_tac_toe_game/core/analytics/analytics_service.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';

class MatchHighlightState {
  const MatchHighlightState({
    this.isRecording = false,
    this.shareState = const AsyncData<void>(null),
    this.shareEventId = 0,
    this.lastShareTarget,
    this.hasFrames = false,
  });

  final bool isRecording;
  final AsyncValue<void> shareState;
  final int shareEventId;
  final HighlightShareTarget? lastShareTarget;
  final bool hasFrames;

  MatchHighlightState copyWith({
    bool? isRecording,
    AsyncValue<void>? shareState,
    int? shareEventId,
    HighlightShareTarget? lastShareTarget,
    bool? hasFrames,
  }) {
    return MatchHighlightState(
      isRecording: isRecording ?? this.isRecording,
      shareState: shareState ?? this.shareState,
      shareEventId: shareEventId ?? this.shareEventId,
      lastShareTarget: lastShareTarget ?? this.lastShareTarget,
      hasFrames: hasFrames ?? this.hasFrames,
    );
  }
}

class MatchHighlightController extends StateNotifier<MatchHighlightState> {
  MatchHighlightController(this._analytics, this._matchId)
      : _recorder = BoardHighlightRecorder(
          retention: const Duration(seconds: 10),
          interval: const Duration(milliseconds: 500),
          maxFrameCount: 32,
        ),
        super(const MatchHighlightState()) {
    _recorder.updateCaptureCallback(_handleFrameCaptured);
  }

  final AnalyticsService _analytics;
  final String _matchId;
  final BoardHighlightRecorder _recorder;
  GlobalKey? _boundaryKey;

  void attachBoundary(GlobalKey boundaryKey) {
    _boundaryKey = boundaryKey;
    _recorder.attachBoundary(boundaryKey);
    if (!_recorder.isCapturing) {
      _recorder.start();
      state = state.copyWith(isRecording: true);
    }
  }

  void detachBoundary(GlobalKey boundaryKey) {
    _recorder.detachBoundary(boundaryKey);
    if (_boundaryKey == boundaryKey) {
      _boundaryKey = null;
      state = state.copyWith(isRecording: false, hasFrames: false);
    }
  }

  void _handleFrameCaptured() {
    final bool available = _recorder.hasFrames;
    if (state.hasFrames != available) {
      state = state.copyWith(hasFrames: available);
    }
  }

  Future<void> shareHighlight(HighlightShareTarget target) async {
    // Fire-and-forget analytics for the click
    unawaited(_analytics.shareButtonClick(
      matchId: _matchId,
      target: target.name,
    ));

    state = state.copyWith(shareState: const AsyncLoading<void>());

    try {
      final List<HighlightFrame> frames = _recorder.snapshot();
      if (frames.length < 2) {
        throw StateError('Not enough frames captured for a highlight yet.');
      }

      Uint8List bytes;
      try {
        bytes = await compute(_encodeGif, _GifInput(frames));
      } catch (error) {
        if (error is UnsupportedError || error is UnimplementedError) {
          bytes = _encodeGif(_GifInput(frames));
        } else {
          rethrow;
        }
      }
      if (bytes.isEmpty) {
        throw StateError('Unable to generate the highlight clip. Play a few moves and try again.');
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      if (kIsWeb) {
        // On web, use a download fallback because share sheets for files are not broadly supported.
        await FileSaver.instance.saveFile(
          name: 'gridlock_highlight_$timestamp.gif',
          bytes: bytes,
        );
      } else {
        final XFile clip = XFile.fromData(
          bytes,
          mimeType: 'image/gif',
          name: 'gridlock_highlight_$timestamp.gif',
        );

        final String shareText = _shareCopy(target);
        await Share.shareXFiles([clip], text: shareText);
      }

      state = state.copyWith(
        shareState: const AsyncData<void>(null),
        shareEventId: state.shareEventId + 1,
        lastShareTarget: target,
        hasFrames: _recorder.hasFrames,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        shareState: AsyncError<void>(error, stackTrace),
        shareEventId: state.shareEventId + 1,
        lastShareTarget: target,
        hasFrames: _recorder.hasFrames,
      );
    }
  }

  String _shareCopy(HighlightShareTarget target) {
    switch (target) {
      case HighlightShareTarget.general:
        return 'Gridlock highlight! Can you top this endgame?';
      case HighlightShareTarget.tiktok:
        return '#Gridlock Clutch 🍥 Breaking the gridwide meta.';
      case HighlightShareTarget.instagram:
        return 'Gridlock highlight – board supremacy unlocked. #Gridlock #TicTacToe';
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}

class _GifInput {
  _GifInput(this.frames);

  final List<HighlightFrame> frames;
}

Uint8List _encodeGif(_GifInput input) {
  final List<HighlightFrame> frames = input.frames;
  if (frames.isEmpty) {
    return Uint8List(0);
  }

  final img.GifEncoder encoder = img.GifEncoder(repeat: 0);

  for (int index = 0; index < frames.length; index++) {
    final HighlightFrame frame = frames[index];
    final img.Image? current = img.decodeImage(frame.bytes);
    if (current == null) {
      continue;
    }

    final img.Image resized = img.copyResize(current, width: 512);
    final int duration = _frameDuration(frames, index);
    encoder.addFrame(resized, duration: duration);
  }

  final Uint8List? bytes = encoder.finish();
  if (bytes == null || bytes.isEmpty) {
    return Uint8List(0);
  }

  return bytes;
}

int _frameDuration(List<HighlightFrame> frames, int index) {
  if (frames.length < 2) {
    return 500;
  }

  if (index == frames.length - 1) {
    final int fallback = frames.last.timestamp
        .difference(frames[frames.length - 2].timestamp)
        .inMilliseconds;
    return fallback.clamp(80, 600);
  }

  final int delta = frames[index + 1].timestamp.difference(frames[index].timestamp).inMilliseconds;
  return delta.clamp(80, 600);
}

final matchHighlightControllerProvider =
    StateNotifierProvider.autoDispose.family<
        MatchHighlightController,
        MatchHighlightState,
        String>(
  (ref, matchId) =>
      MatchHighlightController(ref.read(analyticsServiceProvider), matchId),
);