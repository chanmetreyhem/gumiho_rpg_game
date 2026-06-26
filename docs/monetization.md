# Monetization Setup (Phase 6)

## What's implemented

### Ads (Google AdMob)
| Placement | When |
|-----------|------|
| **Rewarded** | Game Over — revive or +50 coins |
| **Interstitial** | Game Over — on Continue (lose only), skipped if Remove Ads purchased |

Test ad unit IDs are in [`monetization_config.dart`](../lib/features/monetization/data/monetization_config.dart). Replace before production.

### In-App Purchases
| Product ID | Type | Effect |
|------------|------|--------|
| `gumiho_remove_ads` | Non-consumable | Sets `removeAdsPurchased` on profile |
| `gumiho_coins_500` | Consumable | +500 coins |
| `gumiho_coins_1500` | Consumable | +1500 coins |
| `gumiho_premium_wizard` | Non-consumable | Unlocks `wizard` skin |

Shop → **Premium** section. Settings → **Restore Purchases**.

## Before production

### AdMob
1. Create an AdMob app at [admob.google.com](https://admob.google.com)
2. Replace test app IDs in:
   - `android/app/src/main/AndroidManifest.xml` (`APPLICATION_ID`)
   - `ios/Runner/Info.plist` (`GADApplicationIdentifier`)
3. Replace rewarded/interstitial unit IDs in `monetization_config.dart`

### Google Play
1. Create in-app products matching product IDs above
2. Upload a signed AAB to internal testing
3. Add license testers for IAP testing

### App Store Connect
1. Create IAP products with the same IDs
2. Add StoreKit configuration for local testing
3. Submit for review with restore purchases working

## Fair play
- Rewarded ads are always optional
- Interstitials only after failed runs
- Remove Ads IAP disables interstitials only (rewarded still available)
