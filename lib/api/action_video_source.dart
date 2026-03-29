import '../components/board/action_video_mapping.dart';

class ActionVideoCachePolicy {
  final Duration maxCacheAge;

  const ActionVideoCachePolicy({required this.maxCacheAge});
}

class ActionVideoSource {
  static const ActionVideoCachePolicy _defaultPolicy =
      ActionVideoCachePolicy(maxCacheAge: Duration(days: 30));

  static ActionVideoCachePolicy cachePolicyOf(String actionId) {
    return _defaultPolicy;
  }

  static bool hasVideo(String actionId) {
    return ActionVideoMapping.hasVideo(actionId);
  }

  static String? rawVideoUrlOf(String actionId) {
    return ActionVideoMapping.videoUrlOf(actionId);
  }

  static bool isPlayableVideoUrl(String url) {
    if (url.startsWith('SUPABASE_VIDEO_URL_PLACEHOLDER_')) {
      return false;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    return uri.scheme == 'https' || uri.scheme == 'http';
  }

  static Uri? playableVideoUriOf(String actionId) {
    final raw = rawVideoUrlOf(actionId);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    if (!isPlayableVideoUrl(raw)) {
      return null;
    }
    return Uri.parse(raw);
  }
}
