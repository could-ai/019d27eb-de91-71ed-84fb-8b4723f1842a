import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const ForecastingApp());
}

class ForecastingApp extends StatelessWidget {
  const ForecastingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Forecasting Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ForecastingDashboard(),
      },
    );
  }
}

class ForecastingDashboard extends StatefulWidget {
  const ForecastingDashboard({super.key});

  @override
  State<ForecastingDashboard> createState() => _ForecastingDashboardState();
}

class _ForecastingDashboardState extends State<ForecastingDashboard> {
  String _selectedModel = 'BiLSTM';
  int _forecastHorizon = 30;
  bool _isForecasting = false;
  
  List<FlSpot> _historicalData = [];
  List<FlSpot> _forecastData = [];
  
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _generateHistoricalData();
  }

  void _generateHistoricalData() {
    _historicalData = List.generate(100, (index) {
      double x = index.toDouble();
      // Simulate a complex time series with trend, seasonality, and noise
      double trend = x * 0.1;
      double seasonality = sin(x * 0.2) * 15;
      double noise = (_random.nextDouble() * 10) - 5;
      return FlSpot(x, 50 + trend + seasonality + noise);
    });
  }

  Future<void> _runForecast() async {
    setState(() {
      _isForecasting = true;
      _forecastData = [];
    });

    // Simulate network/processing delay for the AI model
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final lastSpot = _historicalData.last;
    List<FlSpot> newForecast = [];
    
    double currentTrend = lastSpot.x * 0.1;

    for (int i = 1; i <= _forecastHorizon; i++) {
      double x = lastSpot.x + i;
      double trend = x * 0.1;
      double seasonality = sin(x * 0.2) * 15;
      
      // Simulate different model behaviors
      double noise;
      if (_selectedModel == 'BiLSTM') {
        // BiLSTM might capture bidirectional context, resulting in smoother, more confident predictions
        noise = (_random.nextDouble() * 4) - 2;
      } else {
        // GRU might be slightly more reactive/volatile in this simulation
        noise = (_random.nextDouble() * 8) - 4;
      }
      
      newForecast.add(FlSpot(x, 50 + trend + seasonality + noise));
    }

    setState(() {
      _forecastData = newForecast;
      _isForecasting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Time-Series Forecasting', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Row(
        children: [
          // Left Sidebar for Controls
          Container(
            width: 300,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Model Configuration',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                
                const Text('Select Architecture', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedModel,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: ['GRU', 'BiLSTM'].map((String model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedModel = newValue;
                            _forecastData = []; // Clear previous forecast
                          });
                        }
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text('Forecast Horizon (Steps)', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _forecastHorizon.toDouble(),
                        min: 10,
                        max: 100,
                        divisions: 9,
                        label: _forecastHorizon.toString(),
                        onChanged: (value) {
                          setState(() {
                            _forecastHorizon = value.toInt();
                            _forecastData = []; // Clear previous forecast
                          });
                        },
                      ),
                    ),
                    Text('$_forecastHorizon', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                
                const Spacer(),
                
                // Model Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedModel == 'BiLSTM' ? 'BiLSTM Info' : 'GRU Info',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedModel == 'BiLSTM' 
                            ? 'Bidirectional LSTM processes data in both forward and backward directions, excellent for capturing complex patterns.'
                            : 'Gated Recurrent Unit is highly efficient and uses less memory while maintaining strong performance on sequential data.',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isForecasting ? null : _runForecast,
                    icon: _isForecasting 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          )
                        : const Icon(Icons.auto_graph),
                    label: Text(_isForecasting ? 'Running Model...' : 'Generate Forecast'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Right Main Area for Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Time-Series Visualization',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          _buildLegendItem('Historical Data', Colors.blue),
                          const SizedBox(width: 24),
                          _buildLegendItem('$_selectedModel Forecast', Colors.orange),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 20,
                            verticalInterval: 20,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 20,
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text('T+${value.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 20,
                                reservedSize: 42,
                                getTitlesWidget: (value, meta) {
                                  return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12, color: Colors.grey));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                          ),
                          minX: 0,
                          maxX: _historicalData.length + _forecastHorizon.toDouble() + 5,
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            // Historical Data Line
                            LineChartBarData(
                              spots: _historicalData,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.1),
                              ),
                            ),
                            // Forecast Data Line
                            if (_forecastData.isNotEmpty)
                              LineChartBarData(
                                spots: [_historicalData.last, ..._forecastData],
                                isCurved: true,
                                color: Colors.orange,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                dashArray: [5, 5], // Dashed line for forecast
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.orange.withOpacity(0.1),
                                ),
                              ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((LineBarSpot touchedSpot) {
                                  final textStyle = TextStyle(
                                    color: touchedSpot.bar.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  return LineTooltipItem(
                                    'Value: ${touchedSpot.y.toStringAsFixed(2)}',
                                    textStyle,
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
