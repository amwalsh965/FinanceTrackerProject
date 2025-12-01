import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphsPage extends StatefulWidget {
  final List<Map<String, dynamic>> expenses;
  const GraphsPage({super.key, required this.expenses});

  @override
  State<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {
  late List<_DailySpending> dailyData;
  late List<_DailySpending> cumulativeData;

  @override
  void initState() {
    super.initState();
    dailyData = _calculateDailySpending(widget.expenses);
    cumulativeData = _calculateCumulative(dailyData);
  }

  List<_DailySpending> _calculateDailySpending(
      List<Map<String, dynamic>> expenses) {
    Map<DateTime, double> totals = {};

    print(expenses);

    for (var e in expenses) {
      DateTime date = DateTime.parse(e["date"]).toLocal();
      DateTime dayOnly = DateTime(date.year, date.month, date.day);
      double amount = double.tryParse(e["amount"].toString()) ?? 0;

      totals[dayOnly] = (totals[dayOnly] ?? 0) + amount;
    }

    return totals.entries.map((e) => _DailySpending(e.key, e.value)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<_DailySpending> _calculateCumulative(List<_DailySpending> daily) {
    double runningTotal = 0;
    return daily.map((d) {
      runningTotal += d.amount;
      return _DailySpending(d.date, runningTotal);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spending Graphs")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Cumulative Spending (Year)",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            if (cumulativeData.isEmpty)
              const Center(child: Text("No data to Display"))
            else
              _buildLineChart(cumulativeData),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<_DailySpending> data) {
    final spots = data
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.amount))
        .toList();
    if (spots.isEmpty) {
      return const Text("No data");
    }

    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (maxY <= 0 || maxY.isNaN) maxY = 1;

    int labelCount = 10;
    List<int> labelIndicies = [];
    if (data.length <= labelCount) {
      labelIndicies = List.generate(data.length, (i) => i);
    } else {
      labelIndicies = List.generate(labelCount,
          (i) => (i * (data.length - 1) / (labelCount - 1)).round());
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: spots,
                  barWidth: 3,
                  color: Colors.blue,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Colors.blue),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        );
                      }),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (!labelIndicies.contains(index) ||
                            index < 0 ||
                            index >= data.length) {
                          return Container();
                        }
                        final date = data[index].date;
                        return Text(
                          "${date.month}/${date.day}",
                          style: const TextStyle(fontSize: 10),
                        );
                      }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailySpending {
  final DateTime date;
  final double amount;
  _DailySpending(this.date, this.amount);
}
