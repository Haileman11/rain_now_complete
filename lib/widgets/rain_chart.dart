import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_models.dart';
import '../utils/constants.dart';

class RainChart extends StatelessWidget {
  final List<RainForecast> rainData;
  final bool isDarkMode;

  const RainChart({
    Key? key,
    required this.rainData,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rainData.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDarkMode 
              ? AppColors.darkSecondary.withOpacity(0.3)
              : AppColors.lightSecondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No rain data available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 15,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final minutes = value.toInt();
                  if (minutes == 0) return const Text('now', style: TextStyle(fontSize: 10));
                  if (minutes == 30) return const Text('30m', style: TextStyle(fontSize: 10));
                  if (minutes == 60) return const Text('60m', style: TextStyle(fontSize: 10));
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0) return const Text('0', style: TextStyle(fontSize: 10));
                  if (value == 2) return const Text('2mm', style: TextStyle(fontSize: 10));
                  if (value == 4) return const Text('4mm', style: TextStyle(fontSize: 10));
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: 60,
          minY: 0,
          maxY: 5,
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.8),
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < rainData.length && i < 60; i++) {
      spots.add(FlSpot(
        i.toDouble(),
        rainData[i].precipitation.clamp(0.0, 5.0),
      ));
    }
    
    return spots;
  }
}