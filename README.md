# CaveMan: Survivor

Top-down twin-stick RPG shooter built with **Flutter** and **Flame** for **Android** and **iOS**. Fight wave-based enemies, upgrade gear in the shop, and progress through **200 levels**.

## Features

- **Free-move hero** — camera follows the player across a large arena
- **Dual joysticks** — move + aim/shoot independently
- **Limited bombs** — AOE damage with explosion VFX
- **200 levels** — scaling waves across 7 enemy types
- **9 character skins + 7 guns** — sprite-based shop items
- **Star ratings** — 1–3 stars by HP remaining; bonus coins scale with stars
- **English & Khmer** — UI + Noto Sans Khmer font
- **Local save** — coins, unlocks, settings
- **Monetization** — rewarded/interstitial ads + IAP (remove ads, coin packs, premium skin)

## Tech Stack

| Package | Purpose |
|---------|---------|
| `flame` | Game loop, components, collision, camera |
| `flame_audio` | SFX and background music |
| `flutter_riverpod` | App state (manual providers) |
| `go_router` | Navigation |
| `shared_preferences` | Local persistence |
| `google_fonts` | Khmer typography |
| `google_mobile_ads` | AdMob |
| `in_app_purchase` | IAP |

## Docs

| Doc | Contents |
|-----|----------|
| **[game_config.md](docs/game_config.md)** | **Guns, heroes, enemies, waves, bombs, prices — full balance reference** |
| [android_release.md](docs/android_release.md) | Signed APK/AAB builds |
| [store_listing.md](docs/store_listing.md) | Play Store / App Store copy (EN + KM) |
| [monetization.md](docs/monetization.md) | Ad units + IAP product IDs |

## Controls

| Input | Action |
|-------|--------|
| Left joystick | Move |
| Right joystick | Aim + auto-fire |
| Bomb button | Throw bomb |
| Pause | Pause menu |

Portrait orientation is locked.

## Project Structure

```
lib/
  features/
    game/flame/     # GumihoGame, components, audio, overlays
    profile/        # Main menu, save data
    shop/           # Skins, guns, IAP premium section
    levels/         # Level select
    settings/       # Language, audio, restore purchases
    monetization/   # AdMob + IAP service
  data/config/      # Waves, shop catalog, level curve
  l10n/             # app_en.arb, app_km.arb
assets/
  images/           # Characters, guns, enemies, arenas
  audio/            # SFX + new_music.mp3
  icon/             # App icon source
```

## Game balance & config

All tunable numbers (gun damage, hero HP, enemy stats, wave rules, shop prices, bombs, stars) are documented in **[docs/game_config.md](docs/game_config.md)**.

Quick reference — main files:

| Config | File |
|--------|------|
| Guns, heroes, arenas | `lib/data/config/shop_catalog.dart` |
| Enemy HP / speed / damage | `lib/data/config/level_curve.dart` |
| Waves & spawn rules | `lib/data/config/wave_config.dart` |
| Level count | `lib/data/config/level_config.dart` |
| Wave buff cards | `lib/features/game/domain/run_combo.dart` |
| Stars & coin bonus | `lib/features/game/domain/star_rating.dart` |

### Formulas

- Enemy HP: `baseHp × (1 + level × 0.04)`
- Enemy speed: `baseSpeed × (1 + level × 0.012)`
- Player HP: `100 × (1 + skin hpBonus)`
- Player speed: `200 × (1 + skin speedBonus)`
- Level clear bonus: `level × 15 + stars × 10` coins
- New players start with **75 coins**

## Implementation Phases

| Phase | Status |
|-------|--------|
| 0 — README | Done |
| 1 — Foundation | Done |
| 2 — Enemies & waves | Done |
| 3 — Bombs & stars | Done |
| 4 — Shop & persistence | Done |
| 5 — L10n & release config | Done |
| 6 — Ads & IAP | Done |
| 7 — Assets, audio, polish | Done |

## Getting Started

```bash
flutter pub get
flutter gen-l10n
flutter run
```

Regenerate app icons after changing `assets/icon/app_icon.png`:

```bash
dart run flutter_launcher_icons
```

### Build release

```bash
flutter build apk --release
flutter build appbundle --release
```

See [docs/android_release.md](docs/android_release.md) for signing.

### Android Gradle troubleshooting

If `metadata.bin` errors occur, the project uses a local cache at `android/.gradle-home/`. Run `flutter clean && flutter pub get && flutter run`.

## Testing Checklist

- [x] Hero moves freely; camera follows
- [x] Right stick aims gun independently
- [x] Waves spawn and clear correctly
- [x] Bomb limited count + AOE
- [x] Level unlock persists
- [x] EN / KM language switch
- [x] Shop purchase persists
- [x] Character + enemy sprites
- [x] SFX and music (settings volumes)
- [x] Rewarded revive / bonus coins on game over
- [x] IAP + restore purchases (requires store setup)

## License

Private project — not published to pub.dev.
