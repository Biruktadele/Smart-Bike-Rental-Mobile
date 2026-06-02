import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../theme.dart';
import '../../../bikes/presentation/bike_providers.dart';
import '../../../ride/presentation/screens/active_ride_screen.dart';
import '../../../ride/presentation/ride_providers.dart';

class ScanScreen extends ConsumerStatefulWidget {
  final bool isStartRide;

  const ScanScreen({
    super.key,
    this.isStartRide = false,
  });

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  String? _message;

  Future<void> _handleCode(String qr) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _message = null;
    });

    try {
      if (widget.isStartRide) {
        // Start the ride directly if already booked
        final ride = await ref.read(rideRepositoryProvider).startRide(qrCode: qr);
        // Clear local booking
        await ref.read(bookingRepositoryProvider).clearBookedBike();
        ref.invalidate(bookedBikeProvider);
        
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ActiveRideScreen(ride: ride)),
        );
      } else {
        // Book the bike
        await ref.read(bookingRepositoryProvider).bookBike(qrCode: qr);
        ref.invalidate(bookedBikeProvider);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bike booked successfully!')),
        );
        Navigator.of(context).pop(); // Go back after booking
      }
    } catch (e) {
      setState(() => _message = e.toString());
      // Prevent rapid scanning on failure
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            errorBuilder: (context, error, child) {
              return Center(
                child: Text(
                  'Camera error: ${error.errorCode}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
            onDetect: (capture) {
              if (capture.barcodes.isNotEmpty) {
                final code = capture.barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  _handleCode(code);
                }
              }
            },
          ),
          // Dark Overlay with transparent center
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  color: VelocityColors.primary,
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: ValueListenableBuilder(
                                valueListenable: _controller,
                                builder: (context, state, child) {
                                  switch (state.torchState) {
                                    case TorchState.on:
                                      return Icon(Icons.flash_on, color: VelocityColors.primary);
                                    case TorchState.off:
                                    default:
                                      return const Icon(Icons.flash_off, color: Colors.white);
                                  }
                                },
                              ),
                              onPressed: () => _controller.toggleTorch(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.cameraswitch, color: Colors.white),
                              onPressed: () => _controller.switchCamera(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_message != null) ...[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: VelocityColors.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _message!,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.isStartRide ? 'Scan to Start Ride' : 'Scan to Book Bike',
                            style: VelocityText.headlineSmall(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Align the QR code within the frame to scan.',
                            style: VelocityText.bodySmall(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.7);

    // Calculate scanner box size (square)
    final double scanBoxSize = size.width * 0.7;
    final double left = (size.width - scanBoxSize) / 2;
    final double top = (size.height - scanBoxSize) / 2;
    final Rect scanRect = Rect.fromLTWH(left, top, scanBoxSize, scanBoxSize);

    // Provide a neat curved rectangle for the scanning area
    final RRect scanRRect = RRect.fromRectAndRadius(scanRect, const Radius.circular(16));

    // Clear the center by using Path.combine
    final Path backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path scanBoxPath = Path()..addRRect(scanRRect);

    final Path finalPath = Path.combine(PathOperation.difference, backgroundPath, scanBoxPath);
    canvas.drawPath(finalPath, backgroundPaint);

    // Draw scanning border corners
    final borderPaint = Paint()
      ..color = VelocityColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final double cornerLength = scanBoxSize * 0.15;

    // Top-Left corner
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top + 8), borderPaint);
    canvas.drawLine(Offset(left + 8, top), Offset(left + cornerLength, top), borderPaint);
    canvas.drawArc(Rect.fromLTWH(left, top, 16, 16), 3.14, 1.57, false, borderPaint);

    // Top-Right corner
    canvas.drawLine(Offset(left + scanBoxSize - cornerLength, top), Offset(left + scanBoxSize - 8, top), borderPaint);
    canvas.drawLine(Offset(left + scanBoxSize, top + 8), Offset(left + scanBoxSize, top + cornerLength), borderPaint);
    canvas.drawArc(Rect.fromLTWH(left + scanBoxSize - 16, top, 16, 16), 4.71, 1.57, false, borderPaint);

    // Bottom-Left corner
    canvas.drawLine(Offset(left, top + scanBoxSize - cornerLength), Offset(left, top + scanBoxSize - 8), borderPaint);
    canvas.drawLine(Offset(left + 8, top + scanBoxSize), Offset(left + cornerLength, top + scanBoxSize), borderPaint);
    canvas.drawArc(Rect.fromLTWH(left, top + scanBoxSize - 16, 16, 16), 1.57, 1.57, false, borderPaint);

    // Bottom-Right corner
    canvas.drawLine(Offset(left + scanBoxSize - cornerLength, top + scanBoxSize), Offset(left + scanBoxSize - 8, top + scanBoxSize), borderPaint);
    canvas.drawLine(Offset(left + scanBoxSize, top + scanBoxSize - cornerLength), Offset(left + scanBoxSize, top + scanBoxSize - 8), borderPaint);
    canvas.drawArc(Rect.fromLTWH(left + scanBoxSize - 16, top + scanBoxSize - 16, 16, 16), 0, 1.57, false, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
