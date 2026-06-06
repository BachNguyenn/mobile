import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class KanjiStrokeOrderView extends StatefulWidget {
  final List<String> strokePaths;
  final int? strokeCount;

  const KanjiStrokeOrderView({
    super.key,
    required this.strokePaths,
    this.strokeCount,
  });

  @override
  State<KanjiStrokeOrderView> createState() => _KanjiStrokeOrderViewState();
}

class _KanjiStrokeOrderViewState extends State<KanjiStrokeOrderView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Path> _paths;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _paths = _parsePaths(widget.strokePaths);
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
  }

  @override
  void didUpdateWidget(covariant KanjiStrokeOrderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strokePaths != widget.strokePaths) {
      _paths = _parsePaths(widget.strokePaths);
      _controller
        ..duration = _animationDuration
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration get _animationDuration {
    final strokeTotal = math.max(_paths.length, 1);
    return Duration(milliseconds: (strokeTotal * 560 / _speed).round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColor = AppColors.resolve(AppColors.leafGreen, context);
    final strokeTotal = widget.strokeCount ?? _paths.length;

    return AppCard(
      borderColor: resolvedColor.withValues(alpha: 0.14),
      shadowColor: resolvedColor.withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gesture_rounded, color: resolvedColor, size: 18),
              const SizedBox(width: AppSpacing.sp8),
              Expanded(
                child: Text(
                  'Thứ tự nét',
                  style: AppTypography.bodyMBold.copyWith(
                    color: resolvedColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$strokeTotal nét',
                style: AppTypography.label.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.34,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.32,
                  ),
                ),
              ),
              child: _paths.isEmpty
                  ? _StrokeFallback(strokeCount: widget.strokeCount)
                  : AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _StrokeOrderPainter(
                            paths: _paths,
                            progress: _controller.value,
                            strokeColor: theme.colorScheme.onSurface,
                            activeColor: resolvedColor,
                            guideColor: theme.colorScheme.outlineVariant,
                          ),
                        );
                      },
                    ),
            ),
          ),
          if (_paths.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp12),
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: _controller.isAnimating ? 'Tạm dừng' : 'Phát',
                  onPressed: _togglePlayback,
                  icon: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => Icon(
                      _controller.isAnimating
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: resolvedColor.withValues(alpha: 0.12),
                    foregroundColor: resolvedColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp8),
                IconButton(
                  tooltip: 'Vẽ lại',
                  onPressed: _reset,
                  icon: const Icon(Icons.replay_rounded),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Slider(
                        value: _controller.value,
                        onChanged: (value) {
                          if (_controller.isAnimating) {
                            _controller.stop();
                          }
                          _controller.value = value;
                        },
                      );
                    },
                  ),
                ),
                PopupMenuButton<double>(
                  tooltip: 'Tốc độ',
                  initialValue: _speed,
                  onSelected: _setSpeed,
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 0.65, child: Text('0.65x')),
                    PopupMenuItem(value: 1.0, child: Text('1x')),
                    PopupMenuItem(value: 1.4, child: Text('1.4x')),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp8,
                      vertical: AppSpacing.sp8,
                    ),
                    child: Text(
                      '${_speed.toStringAsFixed(_speed == 1.0 ? 0 : 2)}x',
                      style: AppTypography.label.copyWith(
                        color: resolvedColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _togglePlayback() {
    if (_controller.isAnimating) {
      _controller.stop();
      return;
    }
    if (_controller.value >= 1) {
      _controller.value = 0;
    }
    _controller.forward();
  }

  void _reset() {
    _controller
      ..stop()
      ..value = 0;
  }

  void _setSpeed(double speed) {
    setState(() {
      _speed = speed;
      _controller.duration = _animationDuration;
    });
  }

  List<Path> _parsePaths(List<String> rawPaths) {
    final paths = <Path>[];
    for (final rawPath in rawPaths) {
      try {
        paths.add(parseSvgPathData(rawPath));
      } catch (_) {
        // Skip malformed source paths so one bad stroke does not break detail.
      }
    }
    return paths;
  }
}

class _StrokeFallback extends StatelessWidget {
  final int? strokeCount;

  const _StrokeFallback({this.strokeCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp16),
        child: Text(
          strokeCount == null
              ? 'Chưa có dữ liệu nét cho chữ này.'
              : 'Chưa có path nét. Tổng số nét: $strokeCount.',
          style: AppTypography.bodyM.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _StrokeOrderPainter extends CustomPainter {
  final List<Path> paths;
  final double progress;
  final Color strokeColor;
  final Color activeColor;
  final Color guideColor;

  const _StrokeOrderPainter({
    required this.paths,
    required this.progress,
    required this.strokeColor,
    required this.activeColor,
    required this.guideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sourceBounds = _combinedBounds(paths);
    if (sourceBounds == null || sourceBounds.isEmpty) return;

    final padding = size.shortestSide * 0.12;
    final targetSize = Size(
      math.max(size.width - padding * 2, 1),
      math.max(size.height - padding * 2, 1),
    );
    final scale = math.min(
      targetSize.width / sourceBounds.width,
      targetSize.height / sourceBounds.height,
    );
    final dx =
        (size.width - sourceBounds.width * scale) / 2 -
        sourceBounds.left * scale;
    final dy =
        (size.height - sourceBounds.height * scale) / 2 -
        sourceBounds.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final guidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = guideColor.withValues(alpha: 0.24);
    final donePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = strokeColor.withValues(alpha: 0.86);
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = activeColor;

    for (final path in paths) {
      canvas.drawPath(path, guidePaint);
    }

    final scaledProgress = (progress.clamp(0.0, 1.0)) * paths.length;
    final activeIndex = math.min(scaledProgress.floor(), paths.length - 1);
    final activeProgress = scaledProgress - activeIndex;

    for (var index = 0; index < paths.length; index++) {
      if (progress >= 1 || index < activeIndex) {
        canvas.drawPath(paths[index], donePaint);
      } else if (index == activeIndex) {
        _drawPartialPath(canvas, paths[index], activeProgress, activePaint);
      }
    }

    canvas.restore();
  }

  void _drawPartialPath(
    Canvas canvas,
    Path path,
    double progress,
    Paint paint,
  ) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    for (final metric in path.computeMetrics()) {
      final partial = metric.extractPath(0, metric.length * clampedProgress);
      canvas.drawPath(partial, paint);
    }
  }

  Rect? _combinedBounds(List<Path> sourcePaths) {
    Rect? bounds;
    for (final path in sourcePaths) {
      final pathBounds = path.getBounds();
      if (pathBounds.isEmpty) continue;
      bounds = bounds == null ? pathBounds : bounds.expandToInclude(pathBounds);
    }
    return bounds;
  }

  @override
  bool shouldRepaint(covariant _StrokeOrderPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.progress != progress ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.guideColor != guideColor;
  }
}
