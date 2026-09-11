import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

const dataUrl = 'https://raw.githubusercontent.com/weatherstationsegamat-lgtm/WeatherStationSegamat/main/data.json';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SG Segamat Weather',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> records = [];
  bool loading = true;
  String? error;

  @override void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try {
      final r = await http.get(Uri.parse(dataUrl), headers: {'Cache-Control': 'no-cache'});
      if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
      final parsed = jsonDecode(r.body);
      if (parsed is! List || parsed.isEmpty) throw Exception('No weather records');
      setState(() { records = parsed; loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  double n(Map<String,dynamic> x, String k) => (x[k] as num?)?.toDouble() ?? double.nan;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(appBar: AppBar(title: const Text('SG Segamat Weather')), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off, size: 56), const SizedBox(height: 12), Text('Data unavailable\n$error', textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton.icon(onPressed: load, icon: const Icon(Icons.refresh), label: const Text('Retry'))]))));
    final latest = Map<String,dynamic>.from(records.last as Map);
    final ts = latest['timestamp']?.toString() ?? '--';
    final temp = n(latest,'temperature');
    final hum = n(latest,'humidity');
    final wind = n(latest,'wind_direction');
    final uv = n(latest,'uv');
    final pressure = n(latest,'pressure');
    final light = n(latest,'visible_light');
    final altitude = n(latest,'altitude');
    final recent = records.length > 24 ? records.sublist(records.length-24) : records;

    return Scaffold(
      appBar: AppBar(title: const Text('SG Segamat Weather'), actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))]),
      body: RefreshIndicator(onRefresh: load, child: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.location_on), const SizedBox(width: 6), const Text('Sungai Segamat, Johor', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)), child: const Text('● ONLINE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 22),
          Text('${temp.isNaN ? '--' : temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
          const Text('Current temperature'),
          const SizedBox(height: 8), Text('Last updated: $ts', style: TextStyle(color: Colors.grey.shade700)),
        ]))),
        const SizedBox(height: 12),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.55, children: [
          metric(Icons.water_drop, 'Humidity', hum, '%'),
          metric(Icons.explore, 'Wind direction', wind, '°'),
          metric(Icons.wb_sunny, 'UV', uv, ''),
          metric(Icons.speed, 'Pressure', pressure, ' hPa'),
          metric(Icons.light_mode, 'Visible light', light, ''),
          metric(Icons.terrain, 'Altitude', altitude, ' m'),
        ]),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.fromLTRB(14, 16, 14, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Temperature trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18), SizedBox(height: 220, child: LineChart(LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(isCurved: true, barWidth: 3, dotData: const FlDotData(show: false), spots: [for (int i=0;i<recent.length;i++) FlSpot(i.toDouble(), n(Map<String,dynamic>.from(recent[i] as Map),'temperature'))]),
          ]))),
        ]))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: const Text('Weather Station Sungai Segamat\nLive data from the project weather station.'))),
        const SizedBox(height: 30),
      ])),
    );
  }

  Widget metric(IconData icon, String label, double value, String unit) => Card(child: Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 24), const Spacer(), Text(label, style: TextStyle(color: Colors.grey)), Text('${value.isNaN ? '--' : value.toStringAsFixed(1)}$unit', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])));
}
