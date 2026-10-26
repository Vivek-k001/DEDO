import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/services/update_service.dart';

class UpdateSettingsTile extends StatefulWidget {
  final bool isDark;

  const UpdateSettingsTile({
    super.key,
    required this.isDark,
  });

  @override
  State<UpdateSettingsTile> createState() => _UpdateSettingsTileState();
}

enum _UpdateState { idle, checking, upToDate, updateAvailable, downloading, downloaded, error }

class _UpdateSettingsTileState extends State<UpdateSettingsTile>
    with SingleTickerProviderStateMixin {
  _UpdateState _state = _UpdateState.idle;
  UpdateInfo? _updateInfo;
  String _currentAppVersion = '1.0.0';
  double _downloadProgress = 0.0;
  String _statusMessage = 'Tap to check for latest version';
  bool _expanded = false;

  late final AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadCurrentVersion();
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _currentAppVersion = info.version;
          if (_state == _UpdateState.idle) {
            _statusMessage = 'Current version: v$_currentAppVersion • Tap to check';
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _checkForUpdates() async {
    if (_state == _UpdateState.checking || _state == _UpdateState.downloading) {
      return;
    }

    HapticFeedback.lightImpact();
    _rotationCtrl.repeat();

    setState(() {
      _state = _UpdateState.checking;
      _statusMessage = 'Checking GitHub repository...';
      _expanded = false;
    });

    try {
      final info = await UpdateService.checkForUpdate();
      if (!mounted) return;

      _rotationCtrl.stop();
      _rotationCtrl.reset();

      setState(() {
        _updateInfo = info;
        if (info.hasUpdate) {
          _state = _UpdateState.updateAvailable;
          _statusMessage = 'Update available: v${info.latestVersion}';
          _expanded = true; // Smoothly auto-expand to show new features!
          HapticFeedback.mediumImpact();
        } else {
          _state = _UpdateState.upToDate;
          _statusMessage = 'App is up to date (v${info.currentVersion})';
          _expanded = false;
          HapticFeedback.lightImpact();
        }
      });
    } catch (e) {
      if (!mounted) return;
      _rotationCtrl.stop();
      _rotationCtrl.reset();
      setState(() {
        _state = _UpdateState.error;
        _statusMessage = 'Couldn\'t connect to GitHub';
      });
    }
  }

  Future<void> _startDownload() async {
    final apkUrl = _updateInfo?.apkDownloadUrl;
    if (apkUrl == null || apkUrl.isEmpty) {
      GlassToast.show(
        context,
        message: 'No APK package attached to this release.',
        icon: CupertinoIcons.exclamationmark_triangle_fill,
        iconColor: Colors.amber,
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _state = _UpdateState.downloading;
      _downloadProgress = 0.0;
    });

    try {
      await UpdateService.downloadAndInstallApk(
        downloadUrl: apkUrl,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _state = _UpdateState.downloaded;
          _downloadProgress = 1.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UpdateState.updateAvailable;
        });
        GlassToast.show(
          context,
          message: 'Download failed: $e',
          icon: CupertinoIcons.xmark_circle_fill,
          iconColor: Colors.redAccent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: GlassContainer(
        borderRadius: GlassTheme.radiusLarge,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Row
            InkWell(
              onTap: _checkForUpdates,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.2 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withValues(
                          alpha: isDark ? 0.35 : 0.25,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: RotationTransition(
                        turns: _rotationCtrl,
                        child: Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          size: 20,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Check for Updates',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_state == _UpdateState.updateAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFF3B30),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else if (_state == _UpdateState.upToDate)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF34C759).withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'LATEST',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF34C759),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _state == _UpdateState.updateAvailable
                                ? (isDark ? const Color(0xFFFF7563) : const Color(0xFFD32F2F))
                                : _state == _UpdateState.upToDate
                                    ? const Color(0xFF34C759)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : Colors.black.withValues(alpha: 0.45)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    size: 16,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.25),
                  ),
                ],
              ),
            ),

            // Animated Expandable Section showing changelog & update button
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: _buildExpandedChangelog(isDark, primaryColor),
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 320),
              sizeCurve: Curves.easeInOutCubic,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedChangelog(bool isDark, Color primaryColor) {
    final info = _updateInfo;
    if (info == null) return const SizedBox.shrink();

    final hasApk = info.apkDownloadUrl != null && info.apkDownloadUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 14),

          // Release Title & Version Comparison
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  info.releaseTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A0A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'v${info.currentVersion} ➔ v${info.latestVersion}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Changelog Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.sparkles,
                      size: 13,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'What\'s New:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1A0A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  info.releaseNotes,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.75)
                        : Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Section: Download Progress or Update Button
          if (_state == _UpdateState.downloading)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloading update...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '${(_downloadProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The Android installer will open automatically once complete.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            )
          else if (_state == _UpdateState.downloaded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF34C759).withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.checkmark_alt_circle_fill,
                      color: Color(0xFF34C759), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Installer launched. Follow screen prompt to update.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34C759),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: hasApk ? _startDownload : null,
                icon: const Icon(CupertinoIcons.arrow_down_circle_fill, size: 18),
                label: Text(
                  hasApk ? 'Download & Install Update' : 'No APK Attached (Check GitHub)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
