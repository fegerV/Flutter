import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ar_app/presentation/providers/performance_providers.dart';

class PerformanceOverlay extends ConsumerStatefulWidget {
  final Widget child;
  final bool enabled;

  const PerformanceOverlay({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  ConsumerState<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends ConsumerState<PerformanceOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final performanceState = ref.watch(performanceProvider);

    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          Positioned(
            top: 50,
            right: 10,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _toggleVisibility,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSectionTitle('Performance'),
                      const SizedBox(height: 8),
                      if (performanceState.currentMetrics != null)
                        _buildMetrics(performanceState.currentMetrics!),
                      if (performanceState.deviceProfile != null) ...[
                        const SizedBox(height: 8),
                        _buildDeviceInfo(performanceState.deviceProfile!),
                      ],
                      if (performanceState.alerts.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildAlerts(performanceState.alerts),
                      ],
                      const SizedBox(height: 8),
                      _buildControls(performanceState),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (!_isVisible)
          Positioned(
            top: 50,
            right: 10,
            child: GestureDetector(
              onTap: _toggleVisibility,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.speed,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildMetrics(metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricRow('FPS', '${metrics.fps.toStringAsFixed(1)}', 
                       _getFPSColor(metrics.fps)),
        _buildMetricRow('CPU', '${metrics.cpuUsage.toStringAsFixed(1)}%', 
                       _getUsageColor(metrics.cpuUsage)),
        _buildMetricRow('GPU', '${metrics.gpuUsage.toStringAsFixed(1)}%', 
                       _getUsageColor(metrics.gpuUsage)),
        _buildMetricRow('Memory', '${metrics.memoryUsagePercentage.toStringAsFixed(1)}%', 
                       _getUsageColor(metrics.memoryUsagePercentage)),
        _buildMetricRow('Battery', '${metrics.batteryLevel.toStringAsFixed(1)}%', 
                       _getBatteryColor(metrics.batteryLevel, metrics.isCharging)),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            ': ',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(deviceProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${deviceProfile.brand} ${deviceProfile.model}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        Text(
          'Tier: ${deviceProfile.tier.name}',
          style: TextStyle(
            color: _getTierColor(deviceProfile.tier),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAlerts(List<String> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts (${alerts.length})',
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...alerts.take(3).map((alert) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            alert,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        if (alerts.length > 3)
          Text(
            '... and ${alerts.length - 3} more',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  Widget _buildControls(performanceState) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (performanceState.isMonitoring) {
              ref.read(performanceProvider.notifier).stopMonitoring();
            } else {
              ref.read(performanceProvider.notifier).startMonitoring();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: performanceState.isMonitoring ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              performanceState.isMonitoring ? 'Stop' : 'Start',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            ref.read(performanceProvider.notifier).clearAlerts();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getFPSColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.yellow;
    return Colors.red;
  }

  Color _getUsageColor(double usage) {
    if (usage <= 50) return Colors.green;
    if (usage <= 75) return Colors.yellow;
    return Colors.red;
  }

  Color _getBatteryColor(double level, bool isCharging) {
    if (isCharging) return Colors.green;
    if (level >= 50) return Colors.green;
    if (level >= 20) return Colors.yellow;
    return Colors.red;
  }

  Color _getTierColor(DeviceTier tier) {
    switch (tier) {
      case DeviceTier.flagship:
        return Colors.green;
      case DeviceTier.midTier:
        return Colors.yellow;
      case DeviceTier.lowEnd:
        return Colors.red;
    }
  }
}