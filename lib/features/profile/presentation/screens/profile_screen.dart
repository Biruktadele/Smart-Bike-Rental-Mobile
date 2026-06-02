import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smbk/l10n/app_localizations.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../../theme.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../payment/presentation/screens/payment_methods_screen.dart';
import '../../../ride/presentation/ride_providers.dart';
import '../../../ride/data/ride_models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showTopUpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          int selectedAmount = 100;
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              color: VelocityColors.surfaceCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: VelocityColors.divider,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                Text(
                  'Top Up Wallet',
                  style: VelocityText.headlineSmall(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add funds to your smart bike rental wallet',
                  style: VelocityText.bodySmall(color: VelocityColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [50, 100, 200, 500, 1000].map((amount) {
                      final isSelected = selectedAmount == amount;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedAmount = amount),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? VelocityColors.primary : VelocityColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? VelocityColors.primaryDark : VelocityColors.primary.withValues(alpha: 0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '$amount ETB',
                              style: VelocityText.bodyMedium(
                                color: isSelected ? Colors.white : VelocityColors.primary,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully added $selectedAmount ETB to your wallet!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Confirm Top Up'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: VelocityColors.primary),
            const SizedBox(width: 10),
            const Text('Support & Help'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need assistance with your rides or account?', style: VelocityText.bodyMedium()),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone_rounded, size: 18, color: VelocityColors.secondaryDark),
                const SizedBox(width: 8),
                Text('+251 911 234 567', style: VelocityText.bodySmall()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email_rounded, size: 18, color: VelocityColors.secondaryDark),
                const SizedBox(width: 8),
                Text('support@velocityrides.com', style: VelocityText.bodySmall()),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: VelocityText.bodyMedium(color: VelocityColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Theme Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              activeColor: VelocityColors.primary,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Mode'),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              activeColor: VelocityColors.primary,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Mode'),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              activeColor: VelocityColors.primary,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    final currentLang = currentLocale?.languageCode ?? 'system';
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n?.languageDialogTitle ?? 'Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n?.systemDefault ?? 'System Default'),
              value: 'system',
              groupValue: currentLang,
              activeColor: VelocityColors.primary,
              onChanged: (String? value) {
                ref.read(localeProvider.notifier).setLocale(null);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(l10n?.english ?? 'English'),
              value: 'en',
              groupValue: currentLang,
              activeColor: VelocityColors.primary,
              onChanged: (String? value) {
                ref.read(localeProvider.notifier).setLocale(const Locale('en', ''));
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(l10n?.amharic ?? 'Amharic (አማርኛ)'),
              value: 'am',
              groupValue: currentLang,
              activeColor: VelocityColors.primary,
              onChanged: (String? value) {
                ref.read(localeProvider.notifier).setLocale(const Locale('am', ''));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(brightnessProvider);
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final sessionFuture = ref.watch(sessionProvider);
    final rideHistoryFuture = ref.watch(rideHistoryProvider);

    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: sessionFuture.when(
        data: (session) {
          // Compute stats from real ride history
          final rides = rideHistoryFuture.maybeWhen(
            data: (list) => list,
            orElse: () => <Ride>[],
          );
          final isHistoryLoading = rideHistoryFuture.isLoading;

          final totalRides = rides.length;
          double totalMinutes = 0.0;
          for (final ride in rides) {
            if (ride.startTime != null && ride.endTime != null) {
              totalMinutes += ride.endTime!.difference(ride.startTime!).inSeconds / 60.0;
            } else if (ride.startTime != null && ride.active) {
              totalMinutes += DateTime.now().difference(ride.startTime!).inSeconds / 60.0;
            }
          }

          final ridesVal = isHistoryLoading ? '...' : totalRides.toString();

          String timeVal = '0m';
          if (isHistoryLoading) {
            timeVal = '...';
          } else if (totalMinutes > 0) {
            if (totalMinutes < 60) {
              timeVal = '${totalMinutes.toStringAsFixed(0)}m';
            } else {
              timeVal = '${(totalMinutes / 60.0).toStringAsFixed(1)}h';
            }
          }

          final double co2Saved = totalMinutes * 0.05; // 0.05 kg CO2 saved per minute of cycling
          final co2Val = isHistoryLoading ? '...' : '${co2Saved.toStringAsFixed(1)} kg';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                // 1. Hero Gradient Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        VelocityColors.primaryDarker,
                        VelocityColors.primary,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(36),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n?.profileTitle ?? 'Profile',
                              style: VelocityText.headlineLarge(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified_user_rounded, color: VelocityColors.accent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'VERIFIED',
                                  style: VelocityText.overline(color: Colors.white).copyWith(letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Avatar and User Details Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: VelocityColors.accent, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person_rounded,
                                color: VelocityColors.primary,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session?.name ?? 'Guest',
                                  style: VelocityText.headlineSmall(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session?.email ?? 'Not signed in',
                                  style: VelocityText.bodySmall(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Stats Grid Cards
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: VelocityColors.surfaceCard,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: VelocityColors.primary.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.pedal_bike_rounded,
                              value: ridesVal,
                              label: l10n?.navRides ?? 'Rides',
                              iconColor: VelocityColors.primary,
                            ),
                          ),
                          Container(width: 1, height: 40, color: VelocityColors.divider.withOpacity(0.5)),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.access_time_rounded,
                              value: timeVal,
                              label: l10n?.timeLabel ?? 'Time',
                              iconColor: Colors.amber,
                            ),
                          ),
                          Container(width: 1, height: 40, color: VelocityColors.divider.withOpacity(0.5)),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.eco_rounded,
                              value: co2Val,
                              label: 'CO₂ Saved',
                              iconColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 3. Wallet Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              VelocityColors.primary,
                              VelocityColors.secondaryDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: VelocityColors.primary.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet_rounded, color: VelocityColors.accent, size: 16),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          l10n?.walletBalance ?? 'WALLET BALANCE',
                                          style: VelocityText.overline(color: Colors.white.withOpacity(0.8)).copyWith(letterSpacing: 1),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '350.00 ETB',
                                    style: VelocityText.titleLarge(color: Colors.white).copyWith(fontSize: 22),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => _showTopUpSheet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VelocityColors.accent,
                                foregroundColor: VelocityColors.primaryDarker,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                textStyle: VelocityText.labelMedium(),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add_rounded, size: 18),
                                  const SizedBox(width: 4),
                                  Text(l10n?.topUpWallet ?? 'Top Up'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 4. Menu options
                      Text(
                        l10n?.accountOptions ?? 'Account Options',
                        style: VelocityText.titleLarge(),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: VelocityColors.surfaceCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: VelocityColors.primary.withOpacity(0.06), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            _MenuRow(
                              icon: Icons.payment_rounded,
                              title: l10n?.paymentMethods ?? 'Payment Methods',
                              subtitle: l10n?.paymentMethodsSubtitle ?? 'Manage cards and billing info',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PaymentMethodsScreen(),
                                ),
                              ),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            _MenuRow(
                              icon: Icons.language_rounded,
                              title: l10n?.languageSetting ?? 'Language',
                              subtitle: l10n?.languageSettingSubtitle ?? 'Change app language',
                              onTap: () => _showLanguageSelectionDialog(context, ref),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            _MenuRow(
                              icon: Icons.dark_mode_rounded,
                              title: l10n?.themeSetting ?? 'Theme Settings',
                              subtitle: l10n?.themeSettingSubtitle ?? 'Switch between light, dark or system themes',
                              onTap: () => _showThemeSelectionDialog(context, ref),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            _MenuRow(
                              icon: Icons.help_outline_rounded,
                              title: l10n?.helpSupport ?? 'Help & Support',
                              subtitle: l10n?.helpSupportSubtitle ?? 'Contact center and FAQs',
                              onTap: () => _showHelpDialog(context),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            _MenuRow(
                              icon: Icons.security_rounded,
                              title: 'Security & Privacy',
                              subtitle: 'Manage credentials and privacy policy',
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    title: const Text('Privacy & Security'),
                                    content: Text(
                                      'Your ride telemetry, personal data, and transaction information are encrypted and protected under our strict privacy policies.',
                                      style: VelocityText.bodyMedium(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('OK', style: VelocityText.bodyMedium(color: VelocityColors.primary)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // 5. Sign Out
                      OutlinedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              title: Text(l10n?.logOut ?? 'Sign Out'),
                              content: Text(l10n?.logOutSubtitle ?? 'Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(l10n?.noKeep ?? 'Cancel', style: VelocityText.bodyMedium()),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(
                                    l10n?.logOut ?? 'Sign Out',
                                    style: VelocityText.bodyMedium(color: VelocityColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(tokenStorageProvider).clearSession();
                            await AuthService.logout();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (_) => false,
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: VelocityColors.error,
                          side: BorderSide(color: VelocityColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, size: 20),
                            const SizedBox(width: 8),
                            const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: VelocityColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: VelocityText.bodyLarge(color: VelocityColors.error),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: VelocityText.headlineSmall().copyWith(height: 1),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: VelocityText.labelSmall(color: VelocityColors.textMuted).copyWith(fontSize: 10),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: VelocityColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: VelocityColors.primary, size: 20),
      ),
      title: Text(title, style: VelocityText.bodyMedium().copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: VelocityText.bodySmall(color: VelocityColors.textMuted)),
      trailing: Icon(Icons.chevron_right_rounded, color: VelocityColors.secondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }
}
