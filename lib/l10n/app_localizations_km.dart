// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'CaveMan: Survivor';

  @override
  String get play => 'លេង';

  @override
  String get shop => 'ហាង';

  @override
  String get settings => 'ការកំណត់';

  @override
  String level(int number) {
    return 'កម្រិត $number';
  }

  @override
  String wave(int current, int total) {
    return 'រលក $current/$total';
  }

  @override
  String get coins => 'កាក់';

  @override
  String get bomb => 'គ្រាប់បែក';

  @override
  String get language => 'ភាសា';

  @override
  String get english => 'English';

  @override
  String get khmer => 'ខ្មែរ';

  @override
  String get musicVolume => 'តន្ត្រី';

  @override
  String get sfxVolume => 'សំឡេង';

  @override
  String get back => 'ត្រលប់';

  @override
  String get pause => 'ផ្អាក';

  @override
  String get resume => 'បន្ត';

  @override
  String get quit => 'ចាកចេញ';

  @override
  String get locked => 'ចាក់សោ';

  @override
  String get equip => 'ប្រើ';

  @override
  String get buy => 'ទិញ';

  @override
  String get owned => 'មានរួច';

  @override
  String get levelComplete => 'បញ្ចប់កម្រិត!';

  @override
  String get gameOver => 'ចាញ់ហ្គេម';

  @override
  String get continueBtn => 'បន្ត';

  @override
  String coinsEarned(int amount) {
    return 'កាក់ទទួលបាន: $amount';
  }

  @override
  String get welcomeBack => 'សូមស្វាគមន៍';

  @override
  String get letsPlay => 'លេងឥឡូវ';

  @override
  String get gameTagline => 'ប្រយុទ្ធរលក ដំឡើងអាវុធ ក្លាយជរឿន';

  @override
  String get selectLevel => 'ជ្រើសកម្រិត';

  @override
  String get guns => 'កាំភ្លើង';

  @override
  String get skins => 'វីរបុរស';

  @override
  String get arenas => 'សង្គ្រាមដី';

  @override
  String get shopTabHeroes => 'វីរបុរស';

  @override
  String get shopTabGuns => 'កាំភ្លើង';

  @override
  String get shopTabArenas => 'សង្គ្រាមដី';

  @override
  String get shopTabPremium => 'ពិសេស';

  @override
  String get shopTestModeBanner => 'ម៉ូដសាកល្បង៖ បើកធាតុទាំងអស់សម្រាប់សាកល្បង។';

  @override
  String get shopLoadout => 'ឧបករណ៍ប្រើ';

  @override
  String get shopTapToEquip => 'ចុចទិញ ឬប្រើធាតុ';

  @override
  String get youScored => 'ពិន្ទុរបស់អ្នក';

  @override
  String get points => 'ពិន្ទុ';

  @override
  String get playAgain => 'លេងម្តងទៀត';

  @override
  String get closeGame => 'បិទហ្គេម';

  @override
  String get joystickSensitivity => 'ភាពរសើបរបាញ់';

  @override
  String get equipped => 'កំពុងប្រើ';

  @override
  String get equippedLoadout => 'ឧបករណ៍ប្រើ';

  @override
  String get resetProgress => 'កំណត់ឡើងវិញ';

  @override
  String get resetProgressTitle => 'លុបវឌ្ឍនភាពទាំងអស់?';

  @override
  String get resetProgressConfirm =>
      'នេះនឹងលុបកាក់ កម្រិត និងការទិញក្នុងហាង។ មិនអាចត្រឡប់វិញបានទេ។';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get reset => 'កំណត់ឡើងវិញ';

  @override
  String get quickPlay => 'លេងភ្លាម';

  @override
  String get waveProgress => 'រលក';

  @override
  String levelPage(int current, int total) {
    return 'ទំព័រ $current / $total';
  }

  @override
  String levelsPerPage(int count) {
    return '$count កម្រិត';
  }

  @override
  String get audioSettings => 'សំឡេង & ការបញ្ជា';

  @override
  String get accountSettings => 'គណនី';

  @override
  String get navHome => 'ទំព័រដើម';

  @override
  String get navPlay => 'លេង';

  @override
  String get free => 'ឥតគិតថ្លៃ';

  @override
  String weaponStats(int damage, String fireRate) {
    return 'ខូច $damage · បាញ់ $fireRate';
  }

  @override
  String skinStats(int hp, int speed) {
    return 'ឈាម +$hp% · ល្បឿន +$speed%';
  }

  @override
  String get premium => 'ពិសេស';

  @override
  String get removeAds => 'លុបពាណិយកម្ម';

  @override
  String get coinPack500 => 'កាក់ ៥០០';

  @override
  String get coinPack1500 => 'កាក់ ១៥០០';

  @override
  String get premiumWizard => 'ស្បែក Wizard ពិសេស';

  @override
  String get restorePurchases => 'ស្តារការទិញ';

  @override
  String get watchAdForCoins => 'មើលពាណិយកម្ម ទទួលកាក់ +៥០';

  @override
  String get watchAdToRevive => 'មើលពាណិយកម្ម ដើម្បីរស់វិញ';

  @override
  String get rewardedCoinsGranted => 'បានបន្ថែមកាក់ ៥០!';

  @override
  String get adNotAvailable =>
      'ពាណិយកម្មមិនទាន់អាចប្រើបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get adsRemoved => 'បានលុបពាណិយកម្ម';

  @override
  String get purchaseRestored => 'បានស្តារការទិញ';

  @override
  String get comboPickTitle => 'បញ្ចប់រលក!';

  @override
  String get comboPickSubtitle => 'ជ្រើសរើសការបន្ថែមមួយសម្រាប់រលកបន្ទាប់';

  @override
  String get comboPickHint => 'ជ្រើសរើសកាតមួយពីខាងលើ';

  @override
  String get comboCategoryAct => 'ACT';

  @override
  String get comboCategoryStat => 'SATA';

  @override
  String get comboCategoryPas => 'PAS';

  @override
  String comboLevel(int level) {
    return 'Lv. $level';
  }

  @override
  String comboProgress(int current, int max) {
    return '$current/$max';
  }

  @override
  String get comboDamageTitle => 'ការបាញ់ខ្លាំង';

  @override
  String comboDamageDesc(int percent) {
    return '+$percent% កំហាប់គ្រាប់';
  }

  @override
  String get comboFireRateTitle => 'បាញ់លឿន';

  @override
  String comboFireRateDesc(int percent) {
    return '+$percent% ល្បឿនបាញ់';
  }

  @override
  String get comboMaxHpTitle => 'រាងខ្លាំង';

  @override
  String comboMaxHpDesc(int percent) {
    return '+$percent% ឈាមអតិបរមា';
  }

  @override
  String get comboHealTitle => 'ព្យាបាល';

  @override
  String comboHealDesc(int percent) {
    return 'ស្តារឈាម $percent%';
  }

  @override
  String get comboSpeedTitle => 'ជើងលឿន';

  @override
  String comboSpeedDesc(int percent) {
    return '+$percent% ល្បឿនដើរ';
  }

  @override
  String get comboBombTitle => 'គ្រាប់បែកបន្ថែម';

  @override
  String get comboBombDesc => '+១ គ្រាប់បែកក្នុងដំណើរនេះ';

  @override
  String get comboBulletSpeedTitle => 'គ្រាប់លឿន';

  @override
  String comboBulletSpeedDesc(int percent) {
    return '+$percent% ល្បឿនគ្រាប់';
  }

  @override
  String get splashLoadingProfile => 'កំពុងផ្ទុកប្រវត្តិ...';

  @override
  String get splashLoadingSettings => 'កំពុងផ្ទុកការកំណត់...';

  @override
  String get splashLoadingAds => 'កំពុងចាប់ផ្ដើមពាណិជ្ជកម្ម...';

  @override
  String get splashLoadingStore => 'កំពុងផ្ទុកហាង...';

  @override
  String get splashFinishing => 'កំពុងចាប់ផ្ដើមហ្គេម...';

  @override
  String get gamePreparingLevel => 'កំពុងរៀបចំកម្រិត...';

  @override
  String gameLoadingLevel(int level) {
    return 'កំពុងផ្ទុកកម្រិត $level...';
  }
}
