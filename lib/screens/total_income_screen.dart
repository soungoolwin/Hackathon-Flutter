import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class TotalIncomeScreen extends StatelessWidget {
  const TotalIncomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_MonthlyIncomeData> monthlyData = _generateMonthlyIncomeData();
    final List<_YearlyIncomeData> yearlyData = _generateYearlyIncomeData();

    return Scaffold(
      body: SingleChildScrollView( // ✅ Fix overflow issue
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Revenue Overview",
                style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Monthly Revenue Line Chart
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(text: "Monthly Revenue"),
                  legend: Legend(isVisible: true),
                  series: <CartesianSeries<_MonthlyIncomeData, String>>[
                    LineSeries<_MonthlyIncomeData, String>(
                      name: "Revenue",
                      dataSource: monthlyData,
                      xValueMapper: (_MonthlyIncomeData income, _) => income.month,
                      yValueMapper: (_MonthlyIncomeData income, _) => income.revenue,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Yearly Revenue Bar Chart
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(text: "Yearly Revenue Comparison"),
                  legend: Legend(isVisible: false),
                  series: <CartesianSeries<_YearlyIncomeData, String>>[
                    BarSeries<_YearlyIncomeData, String>(
                      name: "Yearly Revenue",
                      dataSource: yearlyData,
                      xValueMapper: (_YearlyIncomeData income, _) => income.year,
                      yValueMapper: (_YearlyIncomeData income, _) => income.revenue,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Summary Section (Fake AI-generated insights)
              Card(
                color: Colors.blueGrey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "💰 AI Revenue Insights",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "The highest revenue this year was recorded in ${monthlyData[Random().nextInt(12)].month}."
                            "\nYear-over-year growth is ${yearlyData.last.revenue - yearlyData[yearlyData.length - 2].revenue} compared to last year."
                            "\nConsider promotions during low-revenue months to boost income.",
                        style: GoogleFonts.lato(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generates random sample data for monthly income
  static List<_MonthlyIncomeData> _generateMonthlyIncomeData() {
    List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    Random random = Random();
    return List.generate(12, (index) {
      return _MonthlyIncomeData(months[index], random.nextInt(30000) + 10000);
    });
  }

  // Generates random sample data for yearly income
  static List<_YearlyIncomeData> _generateYearlyIncomeData() {
    List<String> years = ["2020", "2021", "2022", "2023", "2024"];
    Random random = Random();
    return List.generate(years.length, (index) {
      return _YearlyIncomeData(years[index], random.nextInt(300000) + 100000);
    });
  }
}

// Model class for Monthly Income Data
class _MonthlyIncomeData {
  final String month;
  final int revenue;
  _MonthlyIncomeData(this.month, this.revenue);
}

// Model class for Yearly Income Data
class _YearlyIncomeData {
  final String year;
  final int revenue;
  _YearlyIncomeData(this.year, this.revenue);
}