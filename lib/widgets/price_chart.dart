import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class PricePoint {
  final double price;
  final String label;

  PricePoint({required this.price, required this.label});
}

class PriceChart extends StatelessWidget {
  final List<PricePoint> points;
  final String currency;

  const PriceChart({super.key, required this.points, required this.currency});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No price history yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Once fares start updating, Skynova will show the trend here.',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    final minY = points.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.18).clamp(12, 80).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            minY: (minY - padding).clamp(0, double.infinity),
            maxY: maxY + padding,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFE4EAF3), strokeWidth: 1),
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
                  reservedSize: 44,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: points.length > 6 ? 2 : 1,
                  reservedSize: 34,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        points[index].label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppTheme.trustBlue,
                getTooltipItems: (spots) => spots.map((spot) {
                  final i = spot.x.toInt();
                  return LineTooltipItem(
                    '$currency ${points[i].price.toStringAsFixed(2)}\n${points[i].label}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int i = 0; i < points.length; i++)
                    FlSpot(i.toDouble(), points[i].price),
                ],
                isCurved: true,
                color: AppTheme.trustBlue,
                barWidth: 3.5,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.trustBlue.withOpacity(0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
