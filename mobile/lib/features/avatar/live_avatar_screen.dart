import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/api/api_client.dart';

const _tokenKey = 'auth.token';

/// LiveAvatar (HeyGen) streaming экраны.
///
/// `web/index.html` бетін WebView-де ашады. Сол бет ORTAx бэкенді арқылы
/// HeyGen LiveAvatar сессиясын ашып, WebRTC видеоны рендер етеді.
class LiveAvatarScreen extends StatefulWidget {
  const LiveAvatarScreen({
    super.key,
    this.hostUrl,
    this.apiBase,
    this.jwt,
    this.initialText,
  });

  /// `web/index.html` орналасу URL-ы. Берілмесе [liveAvatarHostUrl].
  final String? hostUrl;

  /// ORTAx backend URL. Берілмесе [apiBaseUrl].
  final String? apiBase;

  /// JWT. Берілмесе SharedPreferences-тан оқылады.
  final String? jwt;

  final String? initialText;

  @override
  State<LiveAvatarScreen> createState() => _LiveAvatarScreenState();
}

class _LiveAvatarScreenState extends State<LiveAvatarScreen> {
  WebViewController? _controller;
  String _status = 'Жүктелуде…';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await [Permission.microphone, Permission.camera].request();

    final jwt = widget.jwt ?? await _readJwt();
    if (jwt == null) {
      setState(() => _status = 'JWT табылмады — қайта кіріңіз');
      return;
    }

    final host = widget.hostUrl ?? liveAvatarHostUrl;
    final base = widget.apiBase ?? apiBaseUrl;
    final uri = Uri.parse(host).replace(
      queryParameters: {'api': base, 'jwt': jwt},
    );

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B0B10))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: _onWebMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            final initial = widget.initialText;
            if (initial != null && initial.isNotEmpty) {
              speak(initial);
            }
          },
        ),
      )
      ..loadRequest(uri);

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<String?> _readJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  void _onWebMessage(JavaScriptMessage msg) {
    try {
      final payload = jsonDecode(msg.message) as Map<String, dynamic>;
      switch (payload['type']) {
        case 'status':
          setState(() => _status = payload['message'] as String? ?? '');
          break;
        case 'error':
          setState(() => _status = 'Қате: ${payload['message']}');
          break;
      }
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    final payload = jsonEncode({'type': 'speak', 'text': text});
    await _controller?.runJavaScript('window.flutterInbox(${jsonEncode(payload)});');
  }

  Future<void> stop() async {
    final payload = jsonEncode({'type': 'stop'});
    await _controller?.runJavaScript('window.flutterInbox(${jsonEncode(payload)});');
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B10),
      body: SafeArea(
        child: Stack(
          children: [
            if (controller != null)
              Positioned.fill(child: WebViewWidget(controller: controller))
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              ),
            if (_status.isNotEmpty)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Text(
                  _status,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
