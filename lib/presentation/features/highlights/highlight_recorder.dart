import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Represents a captured frame of the board including the capture timestamp.
class HighlightFrame {
  HighlightFrame({required this.timestamp, required this.bytes});

  final DateTime timestamp;
  final Uint8List bytes;
}

/// Captures the most recent frames of a [RepaintBoundary] to enable highlight exports.
class BoardHighlightRecorder {
  BoardHighlightRecorder({
    required Duration retention,
    required Duration interval,
    int maxFrameCount = 40,
    VoidCallback? onFrameCaptured,
  })  : _retention = retention,
        _interval = interval,
        _maxFrameCount = maxFrameCount,
        _onFrameCaptured = onFrameCaptured;

  final Duration _retention;
  final Duration _interval;
  final int _maxFrameCount;
  VoidCallback? _onFrameCaptured;

  GlobalKey? _boundaryKey;
  final List<HighlightFrame> _frames = <HighlightFrame>[];
  Timer? _timer;
  bool _isCapturing = false;
  bool _captureInFlight = false;
  bool _disposed = false;

  bool get isCapturing => _isCapturing;

  bool get hasFrames => _frames.length > 1;

  /// Provides a snapshot of the currently buffered frames.
  List<HighlightFrame> snapshot() => List<HighlightFrame>.unmodifiable(_frames);

  /// Associates a [RepaintBoundary] with the recorder.
  void attachBoundary(GlobalKey boundaryKey) {
    _boundaryKey = boundaryKey;
  }

  /// Detaches the active boundary and clears captured frames.
  void detachBoundary(GlobalKey boundaryKey) {
    if (_boundaryKey == boundaryKey) {
      stop();
      _boundaryKey = null;
      _frames.clear();
    }
  }

  void updateCaptureCallback(VoidCallback? callback) {
    _onFrameCaptured = callback;
  }

  /// Starts a rolling capture of the boundary frames.
  void start() {
    if (_disposed || _isCapturing) {
      return;
    }

    _isCapturing = true;
    _timer = Timer.periodic(_interval, (_) => _captureFrame());

    // Capture an initial frame as soon as possible.
    scheduleMicrotask(_captureFrame);
  }

  /// Stops capturing frames but retains the buffered history.
  void stop() {
    _isCapturing = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _captureFrame() async {
    if (!_isCapturing || _captureInFlight || _boundaryKey == null) {
      return;
    }

    final BuildContext? context = _boundaryKey!.currentContext;
    if (context == null) {
      return;
    }

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      return;
    }
    if (renderObject.debugNeedsPaint) {
      // Wait until the boundary has painted before attempting a capture.
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureFrame());
      return;
    }

    _captureInFlight = true;
    try {
      final RenderRepaintBoundary boundary = renderObject;
      final mediaQuery = MediaQuery.maybeOf(context);
      final ui.FlutterView? view = ui.PlatformDispatcher.instance.views.isNotEmpty
          ? ui.PlatformDispatcher.instance.views.first
          : ui.PlatformDispatcher.instance.implicitView;
      final double pixelRatio = mediaQuery?.devicePixelRatio ?? view?.devicePixelRatio ?? 1.0;
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      _frames.add(HighlightFrame(timestamp: DateTime.now(), bytes: pngBytes));
      _trimBuffer();
      _onFrameCaptured?.call();
    } catch (_) {
      // Swallow capture errors; they occur occasionally during layout changes.
    } finally {
      _captureInFlight = false;
    }
  }

  void _trimBuffer() {
    final DateTime cutoff = DateTime.now().subtract(_retention);
    _frames.removeWhere((frame) => frame.timestamp.isBefore(cutoff));

    if (_frames.length > _maxFrameCount) {
      _frames.removeRange(0, _frames.length - _maxFrameCount);
    }
  }

  void dispose() {
    if (_disposed) return;
    stop();
    _frames.clear();
    _disposed = true;
  }
}