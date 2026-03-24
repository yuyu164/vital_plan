class EmoDataModel {
  final String emotion;
  final String meridian;
  final String primaryAcupoint;
  final String secondaryAcupoint;
  final String coreSymptom;
  final String assistSymptom;

  EmoDataModel({
    required this.emotion,
    required this.meridian,
    required this.primaryAcupoint,
    required this.secondaryAcupoint,
    required this.coreSymptom,
    required this.assistSymptom,
  });
}

final List<EmoDataModel> emoDataList = [
  EmoDataModel(
    emotion: "喜",
    meridian: "手少阴心经",
    primaryAcupoint: "神门",
    secondaryAcupoint: "神门",
    coreSymptom: "心神不宁、焦虑烦躁",
    assistSymptom: "失眠多梦、心慌心悸、易惊易躁",
  ),
  EmoDataModel(
    emotion: "怒",
    meridian: "足厥阴肝经",
    primaryAcupoint: "太冲",
    secondaryAcupoint: "太冲",
    coreSymptom: "易怒暴躁、肝火郁结",
    assistSymptom: "头晕目胀、胸胁胀痛、情绪失控",
  ),
  EmoDataModel(
    emotion: "忧",
    meridian: "手太阴肺经",
    primaryAcupoint: "太渊",
    secondaryAcupoint: "太渊",
    coreSymptom: "悲伤抑郁、情绪低落",
    assistSymptom: "胸闷气短、叹气频繁、忧思过度",
  ),
  EmoDataModel(
    emotion: "思",
    meridian: "足太阴脾经",
    primaryAcupoint: "太白",
    secondaryAcupoint: "太白",
    coreSymptom: "思虑过度、思绪杂乱",
    assistSymptom: "情绪低迷、行动力差、烦躁纳差",
  ),
  EmoDataModel(
    emotion: "悲",
    meridian: "手厥阴心包经", // 悲和忧通常都伤肺，这里用文档里提供的心包经作为区分（郁气攻心）
    primaryAcupoint: "大陵",
    secondaryAcupoint: "大陵",
    coreSymptom: "心烦焦虑、郁气攻心",
    assistSymptom: "心悸胸闷、烦躁失眠、情绪压抑",
  ),
  EmoDataModel(
    emotion: "恐",
    meridian: "足少阴肾经",
    primaryAcupoint: "太溪",
    secondaryAcupoint: "太溪",
    coreSymptom: "恐惧胆怯、心神不慌", // 修正：可能是心神慌乱，但按文档原文
    assistSymptom: "胆小易惊、失眠盗汗、焦虑不安",
  ),
  EmoDataModel(
    emotion: "惊",
    meridian: "足少阳胆经", // 惊伤胆，提取胆经
    primaryAcupoint: "丘墟",
    secondaryAcupoint: "足临泣",
    coreSymptom: "胆虚易惊、烦躁易怒",
    assistSymptom: "头晕目眩、情绪不稳、胆小焦虑",
  ),
];
