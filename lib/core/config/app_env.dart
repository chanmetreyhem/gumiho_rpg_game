/// App-wide environment flags.
///
/// **Before production release:** set [shopTestMode] to `false`.
class AppEnv {
  AppEnv._();

  /// When `true`, all heroes, guns, and arenas are unlocked in the shop
  /// (buy/equip without spending coins). Use for closed testing and QA.
  ///
  /// Set to `false` for Play Store / App Store production builds.
  static const bool shopTestMode = false;
}
