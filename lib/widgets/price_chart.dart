import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PricePoint {
  final double price;
  final String label;

  PricePoint({
    required this.price,
    required this.label,
  });
}

class PriceChart extends StatelessWidget {
  final List<PricePoint> points;
  final String currency;

  const PriceChart({
    super.key,
    required this.points,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('No price history available'),
      );
    }

    final minY =
        points.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxY =
        points.map((e) => e.price).reduce((a, b) => a > b ? a : b);

    final paddedMinY =
        (minY - 20).clamp(0, double.infinity).toDouble();
    final paddedMaxY = (maxY + 20).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            minY: paddedMinY,
            maxY: paddedMaxY,
            gridData: FlGridData(
              show: true,
              horizontalInterval: ((paddedMaxY - paddedMinY) / 4)
                  .clamp(1, double.infinity)
                  .toDouble(),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 52,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 11),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        points[index].label,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final i = spot.x.toInt();
                    return LineTooltipItem(
                      '$currency ${points[i].price.toStringAsFixed(2)}\n${points[i].label}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  points.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    points[index].price,
                  ),
                ),
                isCurved: true,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}