class ActionVideoMapping {
  static const Map<String, String> _videoUrlByActionId = {
    'act_normal_07':
        'https://qnowezjtbhashvlrrrit.supabase.co/storage/v1/object/public/videos/baduanjin.mp4',
    'act_normal_08':
        'https://qnowezjtbhashvlrrrit.supabase.co/storage/v1/object/public/videos/mingmugong.mp4',
    'act_eye_mingmu':
        'https://qnowezjtbhashvlrrrit.supabase.co/storage/v1/object/public/videos/mingmugong.mp4',
  };

  static bool hasVideo(String actionId) {
    return _videoUrlByActionId.containsKey(actionId);
  }

  static String? videoUrlOf(String actionId) {
    return _videoUrlByActionId[actionId];
  }
}
