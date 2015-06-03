part of modularity.ui;

/// Helper class which is used to generate unique IDs
class UniqueId {
  static Map<String, UniqueId> _cache;
  String _prefix;
  int _prevId;

  /**
   * Gets an unique ID generator of
   * a specific [prefix].
   */
  factory UniqueId(String prefix) {
    if(_cache == null) {
      _cache = <String, UniqueId>{};
    }

    if(_cache.containsKey(prefix)) {
      return _cache[prefix];
    } else {
      final uniqueId = new UniqueId._internal(prefix);
      _cache[prefix] = uniqueId;
      return uniqueId;
    }
  }

  /**
   * Initializes a new instance of the
   * unique ID generator with the help
   * of a specific [prefix].
   */
  UniqueId._internal(String prefix) {
    _prefix = prefix;
    _prevId = 0;
  }

  /**
   * Builds and gets an unique ID. Each time
   * this function is called a new ID is generated,
   * so it isn't possible to get the same ID twice.
   */
  String build() {
    var id = '${_prefix}_${_prevId}';
    ++_prevId;
    return id;
  }
}
