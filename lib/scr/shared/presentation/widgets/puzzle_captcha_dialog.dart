import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PuzzleCaptchaDialog extends StatefulWidget {
  const PuzzleCaptchaDialog({super.key});

  @override
  State<PuzzleCaptchaDialog> createState() => _PuzzleCaptchaDialogState();
}

class _PuzzleCaptchaDialogState extends State<PuzzleCaptchaDialog> with SingleTickerProviderStateMixin {
  late double _pieceX;
  late double _targetX;
  late String _imgUrl;
  bool _solved = false;
  bool _showSuccess = false;
  late AnimationController _controller;
  bool _imgLoaded = false;
  bool _imgError = false;

  static const double imgWidth = 240;
  static const double imgHeight = 100;
  static const double pieceSize = 40;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _loadNewPuzzle();
  }

  void _loadNewPuzzle() {
    setState(() {
      _imgLoaded = false;
      _imgError = false;
      _imgUrl = 'https://picsum.photos/${imgWidth.toInt()}/${imgHeight.toInt()}?random=${DateTime.now().millisecondsSinceEpoch}';
      _targetX = 60 + Random().nextInt((imgWidth - pieceSize - 60).toInt()).toDouble();
      _pieceX = 10;
      _solved = false;
      _showSuccess = false;
      _controller.reset();
    });

    // Precarga la imagen
    final img = Image.network(_imgUrl);
    final ImageStream stream = img.image.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener((_, __) {
      if (mounted) {
        setState(() {
          _imgLoaded = true;
          _imgError = false;
        });
      }
      stream.removeListener(listener!);
    }, onError: (dynamic _, __) {
      if (mounted) {
        setState(() {
          _imgLoaded = false;
          _imgError = true;
        });
      }
      stream.removeListener(listener!);
      // Intenta otra imagen automáticamente después de un breve delay
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _loadNewPuzzle();
      });
    });
    stream.addListener(listener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSuccessAnimation() async {
    setState(() {
      _showSuccess = true;
    });
    _controller.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.of(context).pop(true);
  }

  bool _isPieceInPlace() {
    // Permite un margen de error de 6px
    return (_pieceX - _targetX).abs() < 6;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)?.imageVerificationTitle ?? 'Image Verification'),
      content: SizedBox(
        width: imgWidth,
        height: imgHeight + 40,
        child: !_imgLoaded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _imgError
                        ? "Failed to load image. Trying another..."
                        : "Wait a moment...",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              )
            : Stack(
                children: [
                  // Imagen base con hueco
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imgUrl,
                            width: imgWidth,
                            height: imgHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Hueco transparente
                        Positioned(
                          left: _targetX,
                          top: 30,
                          child: Container(
                            width: pieceSize,
                            height: pieceSize,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              border: Border.all(color: Colors.purple, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pieza arrastrable (recorte real de la imagen)
                  if (!_solved)
                    Positioned(
                      left: _pieceX,
                      top: 30,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _pieceX += details.delta.dx;
                            _pieceX = _pieceX.clamp(0, imgWidth - pieceSize);
                          });
                        },
                        onHorizontalDragEnd: (_) {
                          if (_isPieceInPlace()) {
                            setState(() {
                              _solved = true;
                            });
                            _showSuccessAnimation();
                          }
                        },
                        child: _buildPiece(_imgUrl, _targetX),
                      ),
                    ),
                  // Animación de éxito
                  if (_showSuccess)
                    Positioned.fill(
                      child: Center(
                        child: ScaleTransition(
                          scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)?.cancelButton ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _loadNewPuzzle();
            });
          },
          child: Text(AppLocalizations.of(context)?.anotherImageButton ?? 'Another image'),
        ),
      ],
    );
  }

  Widget _buildPiece(String url, double x) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: pieceSize,
        height: pieceSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 2),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -x,
              top: -30,
              child: Image.network(
                url,
                width: imgWidth,
                height: imgHeight,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}