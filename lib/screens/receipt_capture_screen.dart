import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_recognition/receipt_recognition.dart';
import 'package:taxed/controllers/receipt_scan_controller.dart';
import 'package:taxed/services/camera_handler_mixin.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/widgets/receipt_overlay.dart';

class ReceiptCaptureScreen extends StatefulWidget {
  const ReceiptCaptureScreen({super.key});

  @override
  State<ReceiptCaptureScreen> createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends State<ReceiptCaptureScreen>
    with CameraHandlerMixin {
  late final ReceiptScanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReceiptScanController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cameras = await availableCameras();
      await initCamera(cameras);
      await startLiveFeed(_handleInputImage);
      _controller.resetBestPercent();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    stopLiveFeed();
    _controller.disposeAsync();
    super.dispose();
  }

  Future<void> _handleInputImage(InputImage input) async {
    if (await _guardIfAccepted()) return;
    await _controller.processImage(input);
  }

  Future<bool> _guardIfAccepted() async {
    if (_controller.isAccepted) {
      if (!mounted) return false;
      await stopLiveFeed();
      _goAcceptedRoute();
      return true;
    }
    return false;
  }

  void _goAcceptedRoute() {
    ReceiptLogger.logReceipt(_controller.receipt);
    Navigator.of(context).pop(_controller.receipt);
  }

  Size? _previewImageSizePortrait() {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return null;

    final previewSize = controller.value.previewSize;
    if (previewSize == null) return null;

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? Size(previewSize.height, previewSize.width)
        : Size(previewSize.width, previewSize.height);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final controller = cameraController;
        final percent = _controller.bestPercent;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (controller != null && controller.value.isInitialized) ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final imageSize = _previewImageSizePortrait();
                    if (imageSize == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final receipt = _controller.receipt;
                    final scene = SizedBox(
                      width: imageSize.width,
                      height: imageSize.height,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(controller),
                          ReceiptOverlay(
                            positions: _controller.positions,
                            imageSize: imageSize,
                            screenSize: imageSize,
                            store: receipt.store,
                            totalLabel: receipt.totalLabel,
                            total: receipt.total,
                            purchaseDate: receipt.purchaseDate,
                          ),
                        ],
                      ),
                    );

                    return FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: scene,
                    );
                  },
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: percent == 0 ? null : percent / 100.0,
                      minHeight: 6,
                      color: AppColors.accentOrange,
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progress: ${percent.toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.firaCode(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: percent >= _controller.nearlyCompleteThreshold
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FloatingActionButton.extended(
                    key: const ValueKey('accept'),
                    onPressed: () async {
                      await _controller.acceptCurrent();
                      if (!mounted) return;
                      await stopLiveFeed();
                      _goAcceptedRoute();
                    },
                    icon: const Icon(Icons.done),
                    label: const Text('Manually Accept'),
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
