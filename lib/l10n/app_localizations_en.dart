// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gumiho RPG';

  @override
  String get play => 'Play';

  @override
  String get shop => 'Shop';

  @override
  String get settings => 'Settings';

  @override
  String level(int number) {
    return 'Level $number';
  }

  @override
  String wave(int current, int total) {
    return 'Wave $current/$total';
  }

  @override
  String get coins => 'Coins';

  @override
  String get bomb => 'Bomb';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get khmer => 'Khmer';

  @override
  String get musicVolume => 'Music';

  @override
  String get sfxVolume => 'Sound Effects';

  @override
  String get back => 'Back';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get quit => 'Quit';

  @override
  String get locked => 'Locked';

  @override
  String get equip => 'Equip';

  @override
  String get buy => 'Buy';

  @override
  String get owned => 'Owned';

  @override
  String get levelComplete => 'Level Complete!';

  @override
  String get gameOver => 'Game Over';

  @override
  String get continueBtn => 'Continue';

  @override
  String coinsEarned(int amount) {
    return 'Coins earned: $amount';
  }

  @override
  String get welcomeBack => 'WELCOME BACK';

  @override
  String get letsPlay => 'LET\'S PLAY';

  @override
  String get gameTagline => 'Survive waves. Upgrade gear. Become legend.';

  @override
  String get selectLevel => 'Select Level';

  @override
  String get guns => 'Guns';

  @override
  String get skins => 'Skins';

  @override
  String get youScored => 'YOU\'VE SCORED';

  @override
  String get points => 'Points';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get closeGame => 'CLOSE GAME';

  @override
  String get joystickSensitivity => 'Joystick Sensitivity';

  @override
  String get equipped => 'Equipped';

  @override
  String get equippedLoadout => 'Equipped';

  @override
  String get resetProgress => 'Reset Progress';

  @override
  String get resetProgressTitle => 'Reset all progress?';

  @override
  String get resetProgressConfirm =>
      'This will erase coins, levels, and shop purchases. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get navHome => 'Home';

  @override
  String get navPlay => 'Play';

  @override
  String get free => 'Free';

  @override
  String weaponStats(int damage, String fireRate) {
    return 'DMG $damage · FR $fireRate';
  }

  @override
  String skinStats(int hp, int speed) {
    return 'HP +$hp% · SPD +$speed%';
  }

  @override
  String get premium => 'Premium';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get coinPack500 => '500 Coins';

  @override
  String get coinPack1500 => '1500 Coins';

  @override
  String get premiumWizard => 'Premium Wizard Skin';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get watchAdForCoins => 'Watch ad for +50 coins';

  @override
  String get watchAdToRevive => 'Watch ad to revive';

  @override
  String get rewardedCoinsGranted => '+50 coins added!';

  @override
  String get adsRemoved => 'Ads removed';

  @override
  String get purchaseRestored => 'Purchases restored';

  @override
  String get comboPickTitle => 'Wave cleared!';

  @override
  String get comboPickSubtitle => 'Choose one boost for the next wave';

  @override
  String get comboDamageTitle => 'Power Shot';

  @override
  String comboDamageDesc(int percent) {
    return '+$percent% bullet damage';
  }

  @override
  String get comboFireRateTitle => 'Rapid Fire';

  @override
  String comboFireRateDesc(int percent) {
    return '+$percent% fire rate';
  }

  @override
  String get comboMaxHpTitle => 'Iron Body';

  @override
  String comboMaxHpDesc(int percent) {
    return '+$percent% max HP';
  }

  @override
  String get comboHealTitle => 'First Aid';

  @override
  String comboHealDesc(int percent) {
    return 'Restore $percent% HP';
  }

  @override
  String get comboSpeedTitle => 'Swift Feet';

  @override
  String comboSpeedDesc(int percent) {
    return '+$percent% move speed';
  }

  @override
  String get comboBombTitle => 'Extra Bomb';

  @override
  String get comboBombDesc => '+1 bomb for this run';

  @override
  String get comboBulletSpeedTitle => 'Fast Bullets';

  @override
  String comboBulletSpeedDesc(int percent) {
    return '+$percent% bullet speed';
  }
}
