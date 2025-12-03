import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets/blur_card.dart';
import '../../shared/widgets/mystic_background.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({
    super.key,
    this.initialPush = true,
    this.initialInApp = true,
    this.initialSound = true,
    this.onBack,
    this.onSettingsChanged,
  });

  final bool initialPush;
  final bool initialInApp;
  final bool initialSound;
  final ValueChanged<NotificationSettingsState>? onSettingsChanged;
  final VoidCallback? onBack;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class NotificationSettingsState {
  NotificationSettingsState({
    required this.pushNotifications,
    required this.appNotifications,
    required this.soundEnabled,
  });

  bool pushNotifications;
  bool appNotifications;
  bool soundEnabled;
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late NotificationSettingsState _settings;

  @override
  void initState() {
    super.initState();
    _settings = NotificationSettingsState(
      pushNotifications: widget.initialPush,
      appNotifications: widget.initialInApp,
      soundEnabled: widget.initialSound,
    );
  }

  void _toggle(String key) {
    setState(() {
      switch (key) {
        case 'push':
          _settings.pushNotifications = !_settings.pushNotifications;
          break;
        case 'app':
          _settings.appNotifications = !_settings.appNotifications;
          break;
        case 'sound':
          _settings.soundEnabled = !_settings.soundEnabled;
          break;
      }
    });
    widget.onSettingsChanged?.call(_settings);
  }

  @override
  Widget build(BuildContext context) {
    // 하단 단축키 투명도 방지
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          MysticBackground(
            padding: EdgeInsets.zero,
            child: SafeArea(
              child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    children: [
                      Row(
                        children: [
                          _circleButton(Icons.arrow_back, widget.onBack),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '알림 설정',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.notifications_active,
                                  color: Color(0xFFFACC15),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '알림과 소리를 자유롭게 설정하세요',
                        style: TextStyle(color: Color(0xFFA5F3FC)),
                      ),
                      const SizedBox(height: 24),
                      BlurCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '알림 종류',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _toggleTile(
                              title: '푸시 알림',
                              subtitle: '외부 푸시 알림 받기',
                              value: _settings.pushNotifications,
                              onChanged: () => _toggle('push'),
                            ),
                            const SizedBox(height: 12),
                            _toggleTile(
                              title: '앱 알림',
                              subtitle: '앱 내 알림 받기',
                              value: _settings.appNotifications,
                              onChanged: () => _toggle('app'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlurCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '알림 방식',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _toggleTile(
                              title: '소리',
                              subtitle: '알림음 재생',
                              value: _settings.soundEnabled,
                              onChanged: () => _toggle('sound'),
                            ),
                          ],
                        ),
                      ),
                      // 하단 여백 추가 (스크롤이 네비게이션 바 영역까지 확장되도록)
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 100,
                      ),
                    ],
                  ),
            ),
          ),
          // 하단 단축키 영역을 덮는 검정색 배경
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).padding.bottom,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (_) => onChanged(),
          activeThumbColor: Colors.black,
          activeTrackColor: const Color(0xFFFACC15),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

