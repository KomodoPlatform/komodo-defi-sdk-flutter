class UtxoMergeParams {
  UtxoMergeParams({
    required this.mergeAt,
    required this.checkEvery,
    required this.maxMergeAtOnce,
  });
  final int mergeAt;
  final int checkEvery;
  final int maxMergeAtOnce;

  Map<String, dynamic> toJson() => {
        'merge_at': mergeAt,
        'check_every': checkEvery,
        'max_merge_at_once': maxMergeAtOnce,
      };
}
