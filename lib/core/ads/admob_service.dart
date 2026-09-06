import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_colors.dart';

/// Centralized Google AdMob configuration, ad unit IDs, and ad manager service.
/// Provides monetization support for Banner, Interstitial, and Rewarded ads.
class AdMobService {
  AdMobService._();

  static bool _isInitialized = false;

  /// Initializes the Google Mobile Ads SDK.
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMobService: Google Mobile Ads SDK initialized successfully.');
    } catch (e) {
      debugPrint('AdMobService init warning (expected on web/desktop/unsupported platforms): $e');
    }
  }

  // ==========================================
  // AD UNIT IDS (Google Official Test Ad Unit IDs)
  // Replace these with your real AdMob Ad Unit IDs before production release.
  // ==========================================

  // Set to false when your AdMob account is fully approved and ready for live production ads.
  static bool useTestAds = kDebugMode;

  /// Production Android Banner Ad Unit ID
  static const String productionAndroidBannerId =
      'ca-app-pub-3040613611393529/9398408010';

  /// Google Official Test Banner Unit ID (Loads 100% of the time during development)
  static const String testAndroidBannerId =
      'ca-app-pub-3940256099942544/6300978111';

  /// Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return useTestAds ? testAndroidBannerId : productionAndroidBannerId;
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  /// Interstitial Ad Unit ID (Full Screen Ad)
  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  /// Rewarded Video Ad Unit ID (User earns reward/tokens for watching)
  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  /// App Open Ad Unit ID (Shows on app launch / foreground resume)
  static String get appOpenAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9257395921';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5575463023';
    }
    return '';
  }

  /// Rewarded Interstitial Ad Unit ID (Unskippable full screen rewarded format)
  static String get rewardedInterstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5354046379';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/6978759866';
    }
    return '';
  }

  // ==========================================
  // INTERSTITIAL ADS HELPER
  // ==========================================

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoading = false;

  /// Preloads an interstitial ad to be shown later without delay.
  static void loadInterstitialAd() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    if (_interstitialAd != null || _isInterstitialLoading) return;

    _isInterstitialLoading = true;
    try {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialLoading = false;
            debugPrint('AdMobService: Interstitial Ad loaded.');
          },
          onAdFailedToLoad: (error) {
            _interstitialAd = null;
            _isInterstitialLoading = false;
            debugPrint('AdMobService: Interstitial Ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      _interstitialAd = null;
      _isInterstitialLoading = false;
      debugPrint('AdMobService: Interstitial Ad load exception: $e');
    }
  }

  /// Shows the preloaded interstitial ad if available.
  static void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      onAdClosed?.call();
      return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          try {
            ad.dispose();
          } catch (_) {}
          _interstitialAd = null;
          loadInterstitialAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          try {
            ad.dispose();
          } catch (_) {}
          _interstitialAd = null;
          loadInterstitialAd();
          onAdClosed?.call();
        },
      );

      _interstitialAd!.show();
    } catch (e) {
      debugPrint('AdMobService: Interstitial Ad show exception: $e');
      _interstitialAd = null;
      onAdClosed?.call();
    }
  }

  // ==========================================
  // REWARDED VIDEO ADS HELPER
  // ==========================================

  static RewardedAd? _rewardedAd;
  static bool _isRewardedLoading = false;

  /// Preloads a rewarded video ad.
  static void loadRewardedAd() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    if (_rewardedAd != null || _isRewardedLoading) return;

    _isRewardedLoading = true;
    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedLoading = false;
            debugPrint('AdMobService: Rewarded Ad loaded.');
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isRewardedLoading = false;
            debugPrint('AdMobService: Rewarded Ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      _rewardedAd = null;
      _isRewardedLoading = false;
      debugPrint('AdMobService: Rewarded Ad load exception: $e');
    }
  }

  /// Shows the rewarded video ad and invokes [onUserEarnedReward] when reward conditions are met.
  static void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    if (_rewardedAd == null) {
      loadRewardedAd();
      onAdClosed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosed?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('AdMobService: User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward(reward);
      },
    );
  }

  // ==========================================
  // REWARDED INTERSTITIAL ADS HELPER
  // ==========================================

  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool _isRewardedInterstitialLoading = false;

  /// Preloads a rewarded interstitial ad.
  static void loadRewardedInterstitialAd() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    if (_rewardedInterstitialAd != null || _isRewardedInterstitialLoading) return;

    _isRewardedInterstitialLoading = true;
    try {
      RewardedInterstitialAd.load(
        adUnitId: rewardedInterstitialAdUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback:
            RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedInterstitialAd = ad;
            _isRewardedInterstitialLoading = false;
            debugPrint('AdMobService: Rewarded Interstitial Ad loaded.');
          },
          onAdFailedToLoad: (error) {
            _rewardedInterstitialAd = null;
            _isRewardedInterstitialLoading = false;
            debugPrint('AdMobService: Rewarded Interstitial Ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      _rewardedInterstitialAd = null;
      _isRewardedInterstitialLoading = false;
      debugPrint('AdMobService: Rewarded Interstitial Ad load exception: $e');
    }
  }

  /// Shows the rewarded interstitial ad.
  static void showRewardedInterstitialAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    if (_rewardedInterstitialAd == null) {
      loadRewardedInterstitialAd();
      onAdClosed?.call();
      return;
    }

    try {
      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          try {
            ad.dispose();
          } catch (_) {}
          _rewardedInterstitialAd = null;
          loadRewardedInterstitialAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          try {
            ad.dispose();
          } catch (_) {}
          _rewardedInterstitialAd = null;
          loadRewardedInterstitialAd();
          onAdClosed?.call();
        },
      );

      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('AdMobService: User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
        },
      );
    } catch (e) {
      debugPrint('AdMobService: Rewarded Interstitial Ad show exception: $e');
      _rewardedInterstitialAd = null;
      onAdClosed?.call();
    }
  }

  // ==========================================
  // APP OPEN ADS HELPER
  // ==========================================

  static AppOpenAd? _appOpenAd;
  static bool _isAppOpenLoading = false;

  /// Preloads an App Open ad.
  static void loadAppOpenAd() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    if (_appOpenAd != null || _isAppOpenLoading) return;

    _isAppOpenLoading = true;
    try {
      AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _isAppOpenLoading = false;
            debugPrint('AdMobService: App Open Ad loaded.');
          },
          onAdFailedToLoad: (error) {
            _appOpenAd = null;
            _isAppOpenLoading = false;
            debugPrint('AdMobService: App Open Ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      _appOpenAd = null;
      _isAppOpenLoading = false;
      debugPrint('AdMobService: App Open Ad load exception: $e');
    }
  }

  /// Shows the App Open ad.
  static void showAppOpenAd({VoidCallback? onAdClosed}) {
    if (_appOpenAd == null) {
      loadAppOpenAd();
      onAdClosed?.call();
      return;
    }

    try {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          try {
            ad.dispose();
          } catch (_) {}
          _appOpenAd = null;
          loadAppOpenAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          try {
            ad.dispose();
          } catch (_) {}
          _appOpenAd = null;
          loadAppOpenAd();
          onAdClosed?.call();
        },
      );

      _appOpenAd!.show();
    } catch (e) {
      debugPrint('AdMobService: App Open Ad show exception: $e');
      _appOpenAd = null;
      onAdClosed?.call();
    }
  }
}

/// A ready-to-use Google AdMob Banner widget for placing real money-making ads
/// into screens and lab pages, with built-in loading states and error handling.
class AdMobBannerWidget extends StatefulWidget {
  final AdSize adSize;
  final Widget? fallbackWidget;
  final EdgeInsetsGeometry? margin;

  const AdMobBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.fallbackWidget,
    this.margin,
  });

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      setState(() => _isAdFailed = true);
      return;
    }

    final adUnitId = AdMobService.bannerAdUnitId;
    if (adUnitId.isEmpty) {
      setState(() => _isAdFailed = true);
      return;
    }

    try {
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: widget.adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
                _isAdFailed = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('AdMobBannerWidget: Banner ad failed to load: $error');
            try {
              ad.dispose();
            } catch (_) {}
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
                _isAdFailed = true;
              });
            }
          },
        ),
      );

      _bannerAd?.load().catchError((e) {
        debugPrint('AdMobBannerWidget load error (needs full app restart for new native plugin): $e');
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _isAdFailed = true;
          });
        }
      });
    } catch (e) {
      debugPrint('AdMobBannerWidget init exception: $e');
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
          _isAdFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      _bannerAd?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdFailed && widget.fallbackWidget != null) {
      return widget.fallbackWidget!;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ad attribution label
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.35),
                    width: 0.7,
                  ),
                ),
                child: const Text(
                  'AD • GOOGLE ADMOB',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Monetized Placement',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Real Banner Container
          if (_isAdLoaded && _bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          else
            // Shimmer/Placeholder box while loading real ad
            Container(
              width: widget.adSize.width.toDouble() > 0
                  ? widget.adSize.width.toDouble()
                  : 320,
              height: widget.adSize.height.toDouble() > 0
                  ? widget.adSize.height.toDouble()
                  : 50,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading Google Ad...',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
