class ActionModel {
  final String id;
  final String board;
  final String title;
  final String description;
  final String duration;
  final int difficulty;
  final String interactionType;
  final ActionAssets assets;
  final ActionRewards rewards;

  ActionModel({
    required this.id,
    required this.board,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.interactionType,
    required this.assets,
    required this.rewards,
  });

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
      id: json['id'],
      board: json['board'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      difficulty: json['difficulty'],
      interactionType: json['interactionType'],
      assets: ActionAssets.fromJson(json['assets']),
      rewards: ActionRewards.fromJson(json['rewards']),
    );
  }
}

class ActionAssets {
  final String gif;
  final String poster;

  ActionAssets({required this.gif, required this.poster});

  factory ActionAssets.fromJson(Map<String, dynamic> json) {
    return ActionAssets(
      gif: json['gif'],
      poster: json['poster'],
    );
  }
}

class ActionRewards {
  final int coins;
  final int exp;

  ActionRewards({required this.coins, required this.exp});

  factory ActionRewards.fromJson(Map<String, dynamic> json) {
    return ActionRewards(
      coins: json['coins'],
      exp: json['exp'],
    );
  }
}
