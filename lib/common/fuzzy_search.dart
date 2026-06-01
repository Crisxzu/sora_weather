class FuzzySearch {
  static bool matches(String candidate, String query, {double threshold = 0.3}) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    final c = candidate.toLowerCase();

    if (c.contains(q)) return true;
    if (q.length <= 3) return c.startsWith(q) || c.contains(q);

    // Test against each word of the candidate so "unitd" matches "United Kingdom"
    final words = c.split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.contains(q)) return true;
      if (q.length <= 3 && word.startsWith(q)) return true;
      if (q.length > 3 && _diceSimilarity(word, q) >= threshold) return true;
    }

    return _diceSimilarity(c, q) >= threshold;
  }

  static double _diceSimilarity(String a, String b) {
    final ta = _trigrams(a);
    final tb = _trigrams(b);
    if (ta.isEmpty || tb.isEmpty) return 0;
    final shared = ta.toSet().intersection(tb.toSet()).length;
    return (2 * shared) / (ta.length + tb.length);
  }

  static List<String> _trigrams(String s) =>
      [for (var i = 0; i < s.length - 2; i++) s.substring(i, i + 3)];
}
