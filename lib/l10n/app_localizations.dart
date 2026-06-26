import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gumiho RPG'**
  String get appTitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String level(int number);

  /// No description provided for @wave.
  ///
  /// In en, this message translates to:
  /// **'Wave {current}/{total}'**
  String wave(int current, int total);

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @bomb.
  ///
  /// In en, this message translates to:
  /// **'Bomb'**
  String get bomb;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @khmer.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get khmer;

  /// No description provided for @musicVolume.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicVolume;

  /// No description provided for @sfxVolume.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get sfxVolume;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @equip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get equip;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level Complete!'**
  String get levelComplete;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @coinsEarned.
  ///
  /// In en, this message translates to:
  /// **'Coins earned: {amount}'**
  String coinsEarned(int amount);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBack;

  /// No description provided for @letsPlay.
  ///
  /// In en, this message translates to:
  /// **'LET\'S PLAY'**
  String get letsPlay;

  /// No description provided for @gameTagline.
  ///
  /// In en, this message translates to:
  /// **'Survive waves. Upgrade gear. Become legend.'**
  String get gameTagline;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  /// No description provided for @guns.
  ///
  /// In en, this message translates to:
  /// **'Guns'**
  String get guns;

  /// No description provided for @skins.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get skins;

  /// No description provided for @youScored.
  ///
  /// In en, this message translates to:
  /// **'YOU\'VE SCORED'**
  String get youScored;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get playAgain;

  /// No description provided for @closeGame.
  ///
  /// In en, this message translates to:
  /// **'CLOSE GAME'**
  String get closeGame;

  /// No description provided for @joystickSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Joystick Sensitivity'**
  String get joystickSensitivity;

  /// No description provided for @equipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get equipped;

  /// No description provided for @equippedLoadout.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get equippedLoadout;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @resetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get resetProgressTitle;

  /// No description provided for @resetProgressConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will erase coins, levels, and shop purchases. This cannot be undone.'**
  String get resetProgressConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get navPlay;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @weaponStats.
  ///
  /// In en, this message translates to:
  /// **'DMG {damage} · FR {fireRate}'**
  String weaponStats(int damage, String fireRate);

  /// No description provided for @skinStats.
  ///
  /// In en, this message translates to:
  /// **'HP +{hp}% · SPD +{speed}%'**
  String skinStats(int hp, int speed);

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// No description provided for @coinPack500.
  ///
  /// In en, this message translates to:
  /// **'500 Coins'**
  String get coinPack500;

  /// No description provided for @coinPack1500.
  ///
  /// In en, this message translates to:
  /// **'1500 Coins'**
  String get coinPack1500;

  /// No description provided for @premiumWizard.
  ///
  /// In en, this message translates to:
  /// **'Premium Wizard Skin'**
  String get premiumWizard;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @watchAdForCoins.
  ///
  /// In en, this message translates to:
  /// **'Watch ad for +50 coins'**
  String get watchAdForCoins;

  /// No description provided for @watchAdToRevive.
  ///
  /// In en, this message translates to:
  /// **'Watch ad to revive'**
  String get watchAdToRevive;

  /// No description provided for @rewardedCoinsGranted.
  ///
  /// In en, this message translates to:
  /// **'+50 coins added!'**
  String get rewardedCoinsGranted;

  /// No description provided for @adsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Ads removed'**
  String get adsRemoved;

  /// No description provided for @purchaseRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get purchaseRestored;

  /// No description provided for @comboPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave cleared!'**
  String get comboPickTitle;

  /// No description provided for @comboPickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one boost for the next wave'**
  String get comboPickSubtitle;

  /// No description provided for @comboDamageTitle.
  ///
  /// In en, this message translates to:
  /// **'Power Shot'**
  String get comboDamageTitle;

  /// No description provided for @comboDamageDesc.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% bullet damage'**
  String comboDamageDesc(int percent);

  /// No description provided for @comboFireRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rapid Fire'**
  String get comboFireRateTitle;

  /// No description provided for @comboFireRateDesc.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% fire rate'**
  String comboFireRateDesc(int percent);

  /// No description provided for @comboMaxHpTitle.
  ///
  /// In en, this message translates to:
  /// **'Iron Body'**
  String get comboMaxHpTitle;

  /// No description provided for @comboMaxHpDesc.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% max HP'**
  String comboMaxHpDesc(int percent);

  /// No description provided for @comboHealTitle.
  ///
  /// In en, this message translates to:
  /// **'First Aid'**
  String get comboHealTitle;

  /// No description provided for @comboHealDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore {percent}% HP'**
  String comboHealDesc(int percent);

  /// No description provided for @comboSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Swift Feet'**
  String get comboSpeedTitle;

  /// No description provided for @comboSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% move speed'**
  String comboSpeedDesc(int percent);

  /// No description provided for @comboBombTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra Bomb'**
  String get comboBombTitle;

  /// No description provided for @comboBombDesc.
  ///
  /// In en, this message translates to:
  /// **'+1 bomb for this run'**
  String get comboBombDesc;

  /// No description provided for @comboBulletSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast Bullets'**
  String get comboBulletSpeedTitle;

  /// No description provided for @comboBulletSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% bullet speed'**
  String comboBulletSpeedDesc(int percent);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
