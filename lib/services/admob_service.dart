// lib/services/admob_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/settings_controller.dart';

/// جایگاه‌های تبلیغ در اپ
enum AdSlot {
  splashOpen,
  connectInterstitial,
  connectRewardInterstitial,
  disconnectInterstitial,
  disconnectRewardInterstitial,
  rewarded,
  rewardInterstitial,
}

class AdMobService {
  AdMobService._();
  static final AdMobService instance = AdMobService._();

  final Map<AdSlot, InterstitialAd?> _intAds        = {};
  final Map<AdSlot, RewardedAd?> _rewAds            = {};
  final Map<AdSlot, RewardedInterstitialAd?> _rewIntAds = {};
  final Map<AdSlot, bool> _isReady = { for (var s in AdSlot.values) s: false };

  bool _sdkInitialised = false;

  /// فراخوانی در main.dart **بعد از** بارگذاری تنظیمات
  Future<void> init() async {
    if (_sdkInitialised) return;
    await MobileAds.instance.initialize();
    _sdkInitialised = true;
    // پیش‌بارگذاری همه‌ی اسلات‌ها
    for (final slot in AdSlot.values) {
      unawaited(_loadAd(slot));
    }
  }

  String? _unitId(AdSlot slot) {
    final m = SettingsController.instance.settings.adUnits;
    switch (slot) {
      case AdSlot.splashOpen:
        return m['splashOpen'];
      case AdSlot.connectInterstitial:
        return m['connectInterstitial'];
      case AdSlot.connectRewardInterstitial:
        return m['connectRewardInterstitial'];
      case AdSlot.disconnectInterstitial:
        return m['disconnectInterstitial'];
      case AdSlot.disconnectRewardInterstitial:
        return m['disconnectRewardInterstitial'];
      case AdSlot.rewardInterstitial:
        return m['rewardInterstitial'];
      case AdSlot.rewarded:
        return m['rewarded'];
    }
  }

  Future<void> _loadAd(AdSlot slot) async {
    final unitId = _unitId(slot);
    if (unitId == null || unitId.isEmpty) {
      debugPrint('⚠️ No Ad Unit ID for slot $slot – skipping');
      _isReady[slot] = false;
      return;
    }
    debugPrint('🔄 Loading ad for $slot (unitId=$unitId)');

    switch (slot) {
      case AdSlot.splashOpen:
      case AdSlot.connectInterstitial:
      case AdSlot.disconnectInterstitial:
        if (_intAds[slot] != null) return;
        await InterstitialAd.load(
          adUnitId: unitId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              _intAds[slot] = ad;
              _isReady[slot] = true;
              debugPrint('✅ Interstitial loaded for $slot');
            },
            onAdFailedToLoad: (error) {
              _intAds[slot] = null;
              _isReady[slot] = false;
              debugPrint('❌ Interstitial failed for $slot: $error');
            },
          ),
        );
        break;

      case AdSlot.connectRewardInterstitial:
      case AdSlot.disconnectRewardInterstitial:
      case AdSlot.rewardInterstitial:
        if (_rewIntAds[slot] != null) return;
        await RewardedInterstitialAd.load(
          adUnitId: unitId,
          request: const AdRequest(),
          rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              _rewIntAds[slot] = ad;
              _isReady[slot] = true;
              debugPrint('✅ RewardedInterstitial loaded for $slot');
            },
            onAdFailedToLoad: (error) {
              _rewIntAds[slot] = null;
              _isReady[slot] = false;
              debugPrint('❌ RewardedInterstitial failed for $slot: $error');
            },
          ),
        );
        break;

      case AdSlot.rewarded:
        if (_rewAds[slot] != null) return;
        await RewardedAd.load(
          adUnitId: unitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              _rewAds[slot] = ad;
              _isReady[slot] = true;
              debugPrint('✅ Rewarded loaded for $slot');
            },
            onAdFailedToLoad: (error) {
              _rewAds[slot] = null;
              _isReady[slot] = false;
              debugPrint('❌ Rewarded failed for $slot: $error');
            },
          ),
        );
        break;
    }
  }

  Future<bool> _showAd(AdSlot slot) async {
    if (_isReady[slot] != true) {
      debugPrint('⚠️ Ad not ready for $slot, reloading...');
      unawaited(_loadAd(slot));
      return false;
    }

    bool cancelled = false;

    switch (slot) {
      case AdSlot.splashOpen:
      case AdSlot.connectInterstitial:
      case AdSlot.disconnectInterstitial:
        final ad = _intAds[slot];
        if (ad == null) return false;
        final c = Completer<void>();
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (a) {
            cancelled = true;
            a.dispose();
            _intAds[slot] = null;
            _isReady[slot] = false;
            c.complete();
          },
          onAdFailedToShowFullScreenContent: (a, error) {
            cancelled = true;
            a.dispose();
            _intAds[slot] = null;
            _isReady[slot] = false;
            debugPrint('❌ Show failed for $slot: $error');
            c.complete();
          },
        );
        ad.show();
        await c.future;
        return cancelled;

      case AdSlot.connectRewardInterstitial:
      case AdSlot.disconnectRewardInterstitial:
      case AdSlot.rewardInterstitial:
        final ad = _rewIntAds[slot];
        if (ad == null) return false;
        final c2 = Completer<void>();
        bool cancelled2 = false;
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (a) {
            cancelled2 = true;
            a.dispose();
            _rewIntAds[slot] = null;
            _isReady[slot] = false;
            c2.complete();
          },
          onAdFailedToShowFullScreenContent: (a, error) {
            cancelled2 = true;
            a.dispose();
            _rewIntAds[slot] = null;
            _isReady[slot] = false;
            debugPrint('❌ Show failed for $slot: $error');
            c2.complete();
          },
        );
        ad.show(onUserEarnedReward: (_, __) {});
        await c2.future;
        return cancelled2;

      case AdSlot.rewarded:
        final ad = _rewAds[slot];
        if (ad == null) return false;
        final c3 = Completer<void>();
        bool cancelled3 = false;
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (a) {
            cancelled3 = true;
            a.dispose();
            _rewAds[slot] = null;
            _isReady[slot] = false;
            c3.complete();
          },
          onAdFailedToShowFullScreenContent: (a, error) {
            cancelled3 = true;
            a.dispose();
            _rewAds[slot] = null;
            _isReady[slot] = false;
            debugPrint('❌ Show failed for $slot: $error');
            c3.complete();
          },
        );
        ad.show(onUserEarnedReward: (_, __) {});
        await c3.future;
        return cancelled3;
    }
    return cancelled;
  }

  /// حتماً اینترستیشال Connect رو نمایش بده
  Future<void> showConnectAd() async {
    final s = SettingsController.instance.settings;
    if (!s.showAdmobAds) return;

    if (_isReady[AdSlot.connectInterstitial] != true) {
      debugPrint('🔄 connectInterstitial not ready, loading');
      await _loadAd(AdSlot.connectInterstitial);
    }

    if (_isReady[AdSlot.connectInterstitial] == true) {
      debugPrint('>>> Showing connectInterstitial');
      await _showAd(AdSlot.connectInterstitial);
    } else {
      debugPrint('⚠️ connectInterstitial failed to load');
    }
  }

  /// حتماً اینترستیشال Disconnect رو نمایش بده
  Future<void> showDisconnectAd() async {
    final s = SettingsController.instance.settings;
    if (!s.showAdmobAds) return;

    if (_isReady[AdSlot.disconnectInterstitial] != true) {
      debugPrint('🔄 disconnectInterstitial not ready, loading');
      await _loadAd(AdSlot.disconnectInterstitial);
    }

    if (_isReady[AdSlot.disconnectInterstitial] == true) {
      debugPrint('>>> Showing disconnectInterstitial');
      await _showAd(AdSlot.disconnectInterstitial);
    } else {
      debugPrint('⚠️ disconnectInterstitial failed to load');
    }
  }

  Future<bool> showSplashAd() async {
    final s = SettingsController.instance.settings;
    if (!s.showAdmobAds) return false;
    return await _showAd(AdSlot.splashOpen);
  }

  /// برای Preload مجدد یک Interstitial از بیرون
  Future<void> loadInterstitial(AdSlot slot) async {
    await _loadAd(slot);
  }

  void dispose() {
    for (final ad in _intAds.values)    ad?.dispose();
    for (final ad in _rewAds.values)    ad?.dispose();
    for (final ad in _rewIntAds.values) ad?.dispose();
    _intAds.clear();
    _rewAds.clear();
    _rewIntAds.clear();
    _isReady.clear();
  }
}