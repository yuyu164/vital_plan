class ActionVideoMapping {
  static const bool _isReleaseBuild = bool.fromEnvironment('dart.vm.product');
  static const String _configuredSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String _debugFallbackSupabaseUrl =
      'https://qnowezjtbhashvlrrrit.supabase.co';
  static final String _baseSupabaseUrl = _configuredSupabaseUrl.isNotEmpty
      ? _configuredSupabaseUrl
      : (_isReleaseBuild ? '' : _debugFallbackSupabaseUrl);

  static Map<String, String> get _videoUrlByActionId {
    if (_baseSupabaseUrl.isEmpty) {
      return const {};
    }
    return {
      'act_normal_07':
          '$_baseSupabaseUrl/storage/v1/object/public/videos/baduanjin.mp4',
      'act_normal_08':
          '$_baseSupabaseUrl/storage/v1/object/public/videos/mingmugong.mp4',
      'act_eye_mingmu':
          '$_baseSupabaseUrl/storage/v1/object/public/videos/mingmugong.mp4',
    };
  }

  static bool hasVideo(String actionId) {
    return _videoUrlByActionId.containsKey(actionId);
  }

  static String? videoUrlOf(String actionId) {
    return _videoUrlByActionId[actionId];
  }
}
