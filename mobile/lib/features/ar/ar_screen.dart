import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/theme/colors.dart';
import 'ar_marker_assets.dart';

class ArScreen extends StatefulWidget {
  final String markerId;
  final String? modelUrl;
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  const ArScreen({
    super.key,
    required this.markerId,
    this.modelUrl,
    this.imageUrl,
    this.title,
    this.subtitle,
  });

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> with WidgetsBindingObserver {
  CameraController? _camera;
  Future<void>? _cameraInit;
  String? _cameraError;

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  double _tiltX = 0;
  double _tiltY = 0;

  Offset _position = Offset.zero;
  Offset _positionStart = Offset.zero;
  double _scale = 1.0;
  double _scaleStart = 1.0;

  bool _modelChecked = false;
  bool _modelAvailable = false;

  ArMarkerAsset get _asset {
    final base = arMarkerAssets[widget.markerId] ??
        const ArMarkerAsset(
          imagePath: 'assets/journal/png/1.png',
          title: 'AR',
          subtitle: '',
        );
    final overrideModel = widget.modelUrl;
    final overrideImage = widget.imageUrl;
    if (overrideModel == null &&
        overrideImage == null &&
        widget.title == null &&
        widget.subtitle == null) {
      return base;
    }
    return ArMarkerAsset(
      imagePath: overrideImage ?? base.imagePath,
      modelPath: overrideModel ?? base.modelPath,
      title: widget.title ?? base.title,
      subtitle: widget.subtitle ?? base.subtitle,
    );
  }

  bool get _modelIsNetwork =>
      (_asset.modelPath ?? '').startsWith('http://') ||
      (_asset.modelPath ?? '').startsWith('https://');

  bool get _imageIsNetwork =>
      _asset.imagePath.startsWith('http://') ||
      _asset.imagePath.startsWith('https://');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _initGyro();
    _probeModel();
  }

  Future<void> _probeModel() async {
    final modelPath = _asset.modelPath;
    final available = _modelIsNetwork
        ? (modelPath != null && modelPath.isNotEmpty)
        : await hasBundledModel(modelPath);
    if (!mounted) return;
    setState(() {
      _modelAvailable = available;
      _modelChecked = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _camera;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = 'Камера табылмады');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _camera = controller;
      _cameraInit = controller.initialize();
      await _cameraInit;
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _cameraError = 'Камераны қосу мүмкін болмады: $e');
    }
  }

  void _initGyro() {
    _gyroSub = gyroscopeEventStream().listen((e) {
      setState(() {
        _tiltX = (_tiltX * 0.85 + e.y * 0.15).clamp(-0.4, 0.4);
        _tiltY = (_tiltY * 0.85 + e.x * 0.15).clamp(-0.4, 0.4);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gyroSub?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails d) {
    _scaleStart = _scale;
    _positionStart = _position;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _scale = (_scaleStart * d.scale).clamp(0.4, 3.0);
      _position = _positionStart + d.focalPointDelta;
    });
  }

  void _resetTransform() {
    setState(() {
      _scale = 1.0;
      _position = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildCameraLayer()),
          Positioned.fill(child: _buildCharacterLayer(size)),
          _buildTopBar(),
          _buildBottomHud(),
        ],
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (_cameraError != null) {
      return Container(
        color: const Color(0xFF111111),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _cameraError!,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final controller = _camera;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Color(0xFF111111),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize?.height ?? 1,
        height: controller.value.previewSize?.width ?? 1,
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildCharacterLayer(Size size) {
    if (!_modelChecked) {
      return const SizedBox.shrink();
    }
    return _modelAvailable
        ? _buildModelLayer(size)
        : _buildBillboardLayer(size);
  }

  Widget _buildModelLayer(Size size) {
    final targetWidth = math.min(size.width * 0.85, 480.0);
    final targetHeight = math.min(size.height * 0.7, 640.0);
    return Center(
      child: SizedBox(
        width: targetWidth,
        height: targetHeight,
        child: ModelViewer(
          src: _asset.modelPath!,
          alt: _asset.title,
          ar: false,
          autoRotate: false,
          cameraControls: true,
          disableZoom: false,
          backgroundColor: const Color(0x00000000),
          shadowIntensity: 1,
          exposure: 1.1,
        ),
      ),
    );
  }

  Widget _buildBillboardLayer(Size size) {
    final perspective = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateY(_tiltX)
      ..rotateX(-_tiltY);

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onDoubleTap: _resetTransform,
      child: Center(
        child: Transform.translate(
          offset: _position,
          child: Transform(
            alignment: Alignment.center,
            transform: perspective,
            child: Transform.scale(
              scale: _scale,
              child: _buildBillboard(size),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillboard(Size size) {
    final targetWidth = math.min(size.width * 0.7, 360.0);
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: -10,
          child: Container(
            width: targetWidth * 0.7,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const RadialGradient(
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),
        _imageIsNetwork
            ? Image.network(
                _asset.imagePath,
                width: targetWidth,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 96,
                  color: Colors.white54,
                ),
              )
            : Image.asset(
                _asset.imagePath,
                width: targetWidth,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 96,
                  color: Colors.white54,
                ),
              ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 4,
      left: 8,
      right: 8,
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.close,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          if (_modelAvailable)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: _ModeBadge(label: '3D'),
            )
          else if (_modelChecked)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: _ModeBadge(label: '2D'),
            ),
          _CircleButton(
            icon: Icons.refresh,
            onTap: _resetTransform,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomHud() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _asset.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _asset.subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              _modelAvailable
                  ? 'Саусақпен айналдырыңыз · шымшып үлкейтіңіз'
                  : 'Саусақпен жылжытыңыз · шымшып үлкейтіңіз · қос-түртіп қалпына келтіріңіз',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final String label;
  const _ModeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
