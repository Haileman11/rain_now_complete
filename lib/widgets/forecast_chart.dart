import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_models.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class ForecastChart extends StatelessWidget {
  final List<ForecastDay> forecastData;
  final bool isDarkMode;
  final SettingsProvider settings;

  const ForecastChart({
    Key? key,
    required this.forecastData,
    required this.isDarkMode,
    required this.settings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecastData.isEmpty) {
      return Container(
        height: 150,
        child: const Center(
          child: Text('No forecast data available'),
        ),
      );
    }

    return Container(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
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
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < forecastData.length) {
                    final day = forecastData[index];
                    if (index == 0) return const Text('Today', style: TextStyle(fontSize: 10));
                    if (index == 1) return const Text('Tomorrow', style: TextStyle(fontSize: 10));
                    
                    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Text(
                      weekdays[day.date.weekday - 1],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (settings.settings.temperatureUnit == 'fahrenheit') {
                    final fahrenheit = (value * 9/5) + 32;
                    return Text('${fahrenheit.round()}°F', style: const TextStyle(fontSize: 10));
                  }
                  return Text('${value.round()}°C', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (forecastData.length - 1).toDouble(),
          minY: _getMinTemp() - 5,
          maxY: _getMaxTemp() + 5,
          lineBarsData: [
            // Max temperature line
            LineChartBarData(
              spots: _generateMaxTempSpots(),
              isCurved: true,
              color: Colors.red.withOpacity(0.8),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.red,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
            // Min temperature line
            LineChartBarData(
              spots: _generateMinTempSpots(),
              isCurved: true,
              color: Colors.blue.withOpacity(0.8),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.blue,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateMaxTempSpots() {
    return forecastData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.tempMax);
    }).toList();
  }

  List<FlSpot> _generateMinTempSpots() {
    return forecastData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.tempMin);
    }).toList();
  }

  double _getMinTemp() {
    return forecastData.map((f) => f.tempMin).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxTemp() {
    return forecastData.map((f) => f.tempMax).reduce((a, b) => a > b ? a : b);
  }
}