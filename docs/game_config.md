# Game balance & configuration

All gameplay numbers live in Dart files under `lib/data/config/` and `lib/features/game/domain/`. Edit those files, then hot restart the app to test changes.

## Config file map

| What to change | File |
|----------------|------|
| Guns (damage, price, fire rate) | `lib/data/config/shop_catalog.dart` |
| Heroes / skins (HP%, speed%, price) | `lib/data/config/shop_catalog.dart` |
| Arenas (price, image) | `lib/data/config/shop_catalog.dart` |
| Enemy HP, speed, damage, coins | `lib/data/config/level_curve.dart` |
| Enemy unlock by level + wave spawns | `lib/data/config/wave_config.dart` |
| Total levels + waves per level | `lib/data/config/level_config.dart` |
| Wave buff cards (combo picks) | `lib/features/game/domain/run_combo.dart` |
| Star rating + level clear coins | `lib/features/game/domain/star_rating.dart` |
| Player base HP / speed | `lib/features/game/flame/components/player_component.dart` |
| Starting bombs per run | `lib/features/game/flame/gumiho_game.dart` |
| Bomb damage / explosion | `lib/features/game/flame/components/bomb_component.dart` |
| Heavy enemy bomb resistance | `lib/features/game/flame/components/explosion_component.dart` |
| New player save defaults | `lib/features/profile/domain/player_profile.dart` |
| Audio / music file | `lib/features/game/flame/audio/game_audio.dart` |
| Gun & enemy image paths | `lib/data/config/game_assets.dart` |
| Enemy type enum | `lib/features/game/domain/enemy_type.dart` |
| IAP / ads / coin rewards | `lib/features/monetization/data/monetization_config.dart` |
| Shop test mode (unlock all) | `lib/core/config/app_env.dart` |
| Settings defaults | `lib/features/settings/domain/game_settings.dart` |

---

## Guns

**File:** `lib/data/config/shop_catalog.dart` → `ShopCatalog.weapons`

| ID | Name | Damage | Fire rate | Bullet speed | Spread | Price | Special |
|----|------|--------|-----------|--------------|--------|-------|---------|
| `pistol` | Pistol | 10 | 3 | 400 | 0.05 | 0 | — |
| `rifle` | Rifle | 14 | 5 | 500 | 0.08 | 200 | — |
| `shotgun` | Shotgun | 8 | 1.5 | 350 | 0.35 | 350 | — |
| `sniper` | Sniper | 40 | 0.8 | 700 | 0.02 | 500 | — |
| `plasma_pistol` | Sleek Plasma Pistol | 16 | 4.5 | 620 | 0.03 | 600 | armor pierce |
| `pulse_smg` | Sub-Orbital Pulse SMG | 7 | 9 | 380 | 0.1 | 550 | disorient |
| `tesla_carbine` | Charged Tesla Carbine | 22 | 2.2 | 540 | 0.04 | 650 | shock |

**Fields in `WeaponStats`:**
- `damage` — per-bullet damage
- `fireRate` — shots per second
- `bulletSpeed` — projectile speed (px/s)
- `spreadAngle` — random aim spread (radians)
- `price` — shop coin cost (0 = free/default)
- `special` — `WeaponSpecial` enum (`none`, `armorPierce`, `disorient`, `shock`)
- `bulletColor` / `bulletGlowColor` — hex colors for premium guns

**Gun sprites:** `lib/data/config/game_assets.dart` → `gunPaths`

---

## Heroes (skins)

**File:** `lib/data/config/shop_catalog.dart` → `ShopCatalog.skins`

Base stats (in `player_component.dart`):
- **HP** = `100 × (1 + hpBonus)`
- **Move speed** = `200 × (1 + speedBonus)`

| ID | Name | Asset folder | HP bonus | Speed bonus | Price |
|----|------|--------------|----------|-------------|-------|
| `default` | Cave Man | `Cave_Man_Character_2` | 0% | 0% | 0 |
| `archer` | Archer | `Archer_Character_1` | 0% | +4% | 100 |
| `clown` | Clown | `Clown_Character_3` | +3% | +5% | 120 |
| `gumiho` | Monk | `Monk_Character_4` | +5% | +3% | 150 |
| `ninja` | Ninja | `Ninja_Character_5` | 0% | +8% | 200 |
| `pirate` | Pirate | `Pirate_Character_6` | +4% | +2% | 220 |
| `soldier` | Soldier | `Soldier_Character_7` | +6% | 0% | 240 |
| `knight` | Warrior | `Warrior_Character_8` | +10% | 0% | 280 |
| `wizard` | Wizard | `Wizard_Character_9` | +8% | +2% | 320 |

> **Wizard** is also sold as IAP (`gumiho_premium_wizard`) — see `monetization_config.dart`.

**Hero sprites:** `assets/images/Characters/<folder>/` (Body, Head, Left_Foot, Right_Foot)

---

## Arenas

**File:** `lib/data/config/shop_catalog.dart` → `ShopCatalog.arenas`

| ID | Name | Image file | Price |
|----|------|------------|-------|
| `forest` | Forest Arena | `forest-arena.png` | 0 |
| `desert` | Desert Arena | `desert-arena.png` | 150 |
| `swamp` | Swamp Arena | `swamp-arena.png` | 180 |
| `cemetery` | Cemetery Arena | `cemetery-arena.png` | 220 |
| `gridlock` | Gridlock Arena | `gridlock-arena.png` | 260 |

**Arena images:** `assets/images/arenas/`

---

## Enemies

**File:** `lib/data/config/level_curve.dart`

### Global scaling

| Constant | Value | Effect |
|----------|-------|--------|
| `enemySizeScale` | 1.3 | Sprite visual size multiplier |
| `hurtboxRadiusScale` | 0.82 | Bullet hitbox vs sprite (higher = easier to hit) |
| `hpMultiplier(level)` | `1 + level × 0.04` | Enemy HP scales per level |
| `speedMultiplier(level)` | `1 + level × 0.012` | Enemy speed scales per level |
| Extra coins | `coinReward + (level ÷ 5)` | Added on top of base reward |

**Final stats:** `LevelCurve.scaledStats(enemyType, level)`

### Base stats (level 1, before scaling)

| Enemy type | HP | Speed | Contact dmg | Coins | Size | Heavy? |
|------------|-----|-------|-------------|-------|------|--------|
| `zombie` | 26 | 72 | 6 | 5 | 36 | No |
| `monster` | 42 | 118 | 9 | 10 | 32 | No |
| `tank` | 95 | 50 | 15 | 25 | 52 | **Yes** |
| `scalebladeRavager` | 34 | 128 | 8 | 12 | 38 | No |
| `blazingBoneRaider` | 48 | 96 | 11 | 14 | 40 | No |
| `venomjawBlaster` | 38 | 88 | 10 | 16 | 36 | No |
| `stoneClubBrute` | 110 | 44 | 18 | 30 | 56 | **Yes** |

**Heavy enemies** (`tank`, `stoneClubBrute`): take **50% bomb damage** and bonus damage from armor-pierce weapons.

**Enemy sprites:** `assets/images/enemies/<folder>/` — register new types in:
- `lib/features/game/domain/enemy_type.dart`
- `lib/data/config/game_assets.dart` → `_enemyFolders`

---

## Levels & waves

### Level count

**File:** `lib/data/config/level_config.dart`

| Setting | Value |
|---------|-------|
| `totalLevels` | 200 |

### Waves per level

| Level range | Wave count |
|-------------|------------|
| 1–20 | 3 |
| 21–60 | 4 |
| 61–120 | 5 |
| 121–180 | 6 |
| 181+ | 7 |

### Enemy unlock by level

**File:** `lib/data/config/wave_config.dart`

| Enemy | Appears from level |
|-------|-------------------|
| Zombie | Always |
| Monster | 2+ |
| Tank | 4+ (penultimate / final waves) |
| Scaleblade Ravager | 11+ |
| Blazing Bone Raider | 21+ |
| Venomjaw Blaster | 41+ |
| Stone Club Brute | 61+ (final wave only) |

Levels **1–3** use fixed tutorial waves (`_tutorialWave()`).

Spawn counts scale with level tier and wave number via `_scaledCount()`.

---

## Bombs

| Setting | Value | File |
|---------|-------|------|
| Bombs per run | 3 | `gumiho_game.dart` → `bombsRemaining` |
| Throw range | 420 | `gumiho_game.dart` → `bombThrowRange` |
| Bomb travel speed | 320 | `bomb_component.dart` |
| Fuse time | 2.5 s | `bomb_component.dart` |
| Explosion radius | 120 | `bomb_component.dart` |
| Explosion damage | 80 | `bomb_component.dart` |

Damage falloff: `damage × (1 - distance/radius × 0.3)` at edge of blast.

---

## Wave buff cards (combo picks)

**File:** `lib/features/game/domain/run_combo.dart` → `ComboCatalog._pool`

| Buff | Type | Value | Effect |
|------|------|-------|--------|
| Power Shot | `damageUp` | +20% / +12% | Bullet damage multiplier |
| Rapid Fire | `fireRateUp` | +25% / +15% | Fire rate multiplier |
| Iron Body | `maxHpUp` | +25% | Max HP increase |
| First Aid | `heal` | +35% / +20% | Heal % of max HP |
| Swift Feet | `speedUp` | +15% | Move speed multiplier |
| Extra Bomb | `extraBomb` | +1 | Adds 1 bomb |
| Fast Bullets | `bulletSpeedUp` | +20% | Bullet speed multiplier |

Levels **1–5**, waves **1–2**: fixed picks (heal, damage, fire rate) for easier onboarding.

---

## Stars & rewards

**File:** `lib/features/game/domain/star_rating.dart`

| HP remaining at clear | Stars |
|-----------------------|-------|
| ≥ 70% | 3 |
| ≥ 40% | 2 |
| < 40% | 1 |

**Level clear bonus coins:** `level × 15 + stars × 10`

**Kill coins:** enemy `coinReward` (scaled per level) added during the run.

---

## Player & save defaults

**File:** `lib/features/profile/domain/player_profile.dart`

| Setting | Default |
|---------|---------|
| Starting coins | 75 |
| Owned skin | `default` |
| Owned gun | `pistol` |
| Owned arena | `forest` |
| Level unlock | Level 1 only; next level unlocks after clearing previous |

---

## Settings defaults

**File:** `lib/features/settings/domain/game_settings.dart`

| Setting | Default |
|---------|---------|
| Language | `en` |
| Music volume | 0.8 |
| SFX volume | 1.0 |
| Joystick sensitivity | 1.0 |
| Vibration | on |

---

## Monetization

**File:** `lib/features/monetization/data/monetization_config.dart`

| Item | Value |
|------|-------|
| Rewarded ad coin bonus | 50 |
| IAP 500 coins | product `gumiho_coins_500` → 500 coins |
| IAP 1500 coins | product `gumiho_coins_1500` → 1500 coins |
| Remove ads | product `gumiho_remove_ads` |
| Premium wizard skin | product `gumiho_premium_wizard` → skin id `wizard` |

Ad unit IDs are Google test IDs — replace before production. See [monetization.md](monetization.md).

---

## Dev / test flags

**File:** `lib/core/config/app_env.dart`

```dart
static const bool shopTestMode = true;  // set false for production
```

When `true`, all shop items can be bought/equipped without spending coins.

---

## Audio

**File:** `lib/features/game/flame/audio/game_audio.dart`

| File | Purpose |
|------|---------|
| `new_music.mp3` | Background music (loop) |
| `shoot.wav` | Gun fire |
| `hit.wav` | Bullet hit |
| `enemy_death.wav` | Enemy killed |
| `explosion.wav` | Bomb |
| `bomb_throw.wav` | Throw bomb |
| `level_complete.wav` | Win |
| `game_over.wav` | Death |

Register new audio in `pubspec.yaml` under `assets/audio/`.

---

## Adding new content (checklist)

### New hero
1. Add sprites to `assets/images/Characters/My_Hero/`
2. Register folder in `pubspec.yaml`
3. Add `SkinStats` entry in `shop_catalog.dart`

### New gun
1. Add image to `assets/images/gun/`
2. Add path in `game_assets.dart` → `gunPaths`
3. Add `WeaponStats` in `shop_catalog.dart`

### New enemy
1. Add sprites to `assets/images/enemies/my_enemy/` (body, head, hands, feet)
2. Register folder in `pubspec.yaml`
3. Add enum value in `enemy_type.dart`
4. Add folder in `game_assets.dart` → `_enemyFolders`
5. Add base stats in `level_curve.dart` → `baseStats()`
6. Add spawn rules in `wave_config.dart`
