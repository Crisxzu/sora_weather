class FuzzySearch {
  static const _accents = 'àáâãäåæçèéêëìíîïðñòóôõöùúûüýÿ';
  static const _plain   = 'aaaaaaeceeeeiiiidnoooooouuuuyy';

  // O(1) accent lookup built once at class load
  static final Map<int, int> _accentMap = () {
    final accentRunes = _accents.runes.toList();
    final plainRunes  = _plain.runes.toList();
    return { for (var i = 0; i < accentRunes.length; i++) accentRunes[i]: plainRunes[i] };
  }();

  static String normalize(String s) {
    final buf = StringBuffer();
    for (final cp in s.toLowerCase().runes) {
      buf.writeCharCode(_accentMap[cp] ?? cp);
    }
    return buf.toString();
  }

  /// Normalizes [query] once, then tests [candidate] against it.
  static bool matches(String candidate, String query, {double threshold = 0.3}) {
    if (query.isEmpty) return true;
    return matchesNormalized(normalize(candidate), normalize(query), threshold: threshold);
  }

  /// Use this when the normalized query is already known (avoid re-normalizing per candidate).
  static bool matchesNormalized(String normalizedCandidate, String normalizedQuery, {double threshold = 0.3}) {
    final q = normalizedQuery;
    final c = normalizedCandidate;

    if (c.contains(q)) return true;
    if (q.length <= 3) return c.startsWith(q) || c.contains(q);

    // Test against each word so "unitd" matches "United Kingdom"
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
