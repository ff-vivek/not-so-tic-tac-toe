import 'package:flutter/material.dart';

enum HighlightShareTarget { general, tiktok, instagram }

extension HighlightShareTargetX on HighlightShareTarget {
  String get label {
    switch (this) {
      case HighlightShareTarget.general:
        return 'Share highlight';
      case HighlightShareTarget.tiktok:
        return 'TikTok clip';
      case HighlightShareTarget.instagram:
        return 'Instagram reel';
    }
  }

  String get description {
    switch (this) {
      case HighlightShareTarget.general:
        return 'Send the GIF to any app or chat.';
      case HighlightShareTarget.tiktok:
        return 'Export with a TikTok-ready caption.';
      case HighlightShareTarget.instagram:
        return 'Save with a reel-friendly description.';
    }
  }

  IconData get icon {
    switch (this) {
      case HighlightShareTarget.general:
        return Icons.ios_share_rounded;
      case HighlightShareTarget.tiktok:
        return Icons.music_note_rounded;
      case HighlightShareTarget.instagram:
        return Icons.camera_alt_rounded;
    }
  }
}