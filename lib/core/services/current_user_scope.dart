/// Holds the id of the currently signed-in user so data-layer queries can
/// scope every read/write to that user's account (via the `business_id`
/// column). Set by the auth provider on login/restore/logout.
abstract final class CurrentUserScope {
  CurrentUserScope._();

  static int? _userId;

  static int? get userId => _userId;

  /// The tenant id to use in queries. Falls back to `0` (unclaimed/legacy)
  /// when no user is signed in; data screens are unreachable in that state.
  static int get activeId => _userId ?? 0;

  static void setUserId(int? id) => _userId = id;
}
