/// Semantic navigation item for the iOS 26 native Liquid Glass tab bar.
///
/// Uses SF Symbol names so the native side renders icons through Apple's
/// system icon infrastructure, ensuring correct Dynamic Type scaling,
/// weight adaptation, and accessibility behaviour.
///
/// ```dart
/// IOS26NavigationItem(
///   id: 'home',
///   sfSymbolName: 'house',
///   selectedSfSymbolName: 'house.fill',
///   label: 'Home',
/// )
/// ```
class IOS26NavigationItem {
  /// Unique identifier for this tab. Must be stable across rebuilds.
  final String id;

  /// SF Symbol name for the unselected state (e.g. `'house'`).
  final String sfSymbolName;

  /// SF Symbol name for the selected state (e.g. `'house.fill'`).
  /// Defaults to [sfSymbolName] if not provided.
  final String? selectedSfSymbolName;

  /// Human-readable label shown below the icon and used as the
  /// accessibility label by VoiceOver.
  final String label;

  /// Whether this item uses Apple's native `UISearchTab` role.
  /// When `true`, the system provides a localised title and search icon.
  final bool isSearch;

  const IOS26NavigationItem({
    required this.id,
    required this.sfSymbolName,
    this.selectedSfSymbolName,
    required this.label,
    this.isSearch = false,
  });

  /// Serialises to the map format expected by the native bridge.
  Map<String, dynamic> toMap() => {
        'id': id,
        'sfSymbolName': sfSymbolName,
        'selectedSfSymbolName': selectedSfSymbolName ?? sfSymbolName,
        'label': label,
        'isSearch': isSearch,
      };
}
