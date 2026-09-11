import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const dataUrl = 'https://raw.githubusercontent.com/weatherstationsegamat-lgtm/WeatherStationSegamat/main/data.json';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});
  @override State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  ThemeMode mode = ThemeMode.system;
  bool english = true;
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SG Segamat Weather',
        themeMode: mode,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, brightness: Brightness.light),
        darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, brightness: Brightness.dark),
        home: HomePage(
          english: english,
          onLanguage: () => setState(() => english = !english),
          onTheme: () => setState(() => mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
        ),
      );
}

class HomePage extends StatefulWidget {
  final bool english;
  final VoidCallback onLanguage;
  final VoidCallback onTheme;
  const HomePage({super.key, required this.english, required this.onLanguage, required this.onTheme});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> records = [];
  bool loading = true;
  String? error;
  int tab = 0;
  String range = '24h';
  final Map<String, bool> alertEnabled = {'Temperature': true, 'UV': true, 'Humidity': true, 'Battery': true, 'Offline': true};
  final Map<String, double> thresholds = {'High temperature': 35, 'Low temperature': 20, 'High UV': 8, 'Low battery': 3.3, 'High humidity': 90};

  @override void initState() { super.initState(); load(); }

  Future<void> load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final r = await http.get(Uri.parse('$dataUrl?v=${DateTime.now().millisecondsSinceEpoch}'), headers: {'Cache-Control': 'no-cache'});
      if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
      final parsed = jsonDecode(r.body);
      if (parsed is! List || parsed.isEmpty) throw Exception('No weather records');
      final list = parsed.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      if (mounted) setState(() { records = list; loading = false; });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }

  double n(Map<String, dynamic> x, String k) => (x[k] as num?)?.toDouble() ?? double.nan;
  String f(double v, [int digits = 1]) => v.isNaN ? '--' : v.toStringAsFixed(digits);
  Map<String, dynamic> get latest => records.isEmpty ? {} : records.last;
  String t(String en, String bm) => widget.english ? en : bm;

  List<Map<String, dynamic>> filtered() {
    if (records.isEmpty) return [];
    final minutes = {'1h': 60, '6h': 360, '24h': 1440, '7d': 10080, '30d': 43200}[range] ?? 1440;
    final last = DateTime.tryParse(latest['timestamp']?.toString() ?? '');
    if (last == null) return records;
    return records.where((r) {
      final d = DateTime.tryParse(r['timestamp']?.toString() ?? '');
      return d != null && last.difference(d).inMinutes <= minutes;
    }).toList();
  }

  bool online() {
    final d = DateTime.tryParse(latest['timestamp']?.toString() ?? '');
    return d != null && DateTime.now().difference(d).inMinutes <= 10;
  }

  double avg(String key) {
    final vals = filtered().map((r) => n(r, key)).where((v) => !v.isNaN).toList();
    return vals.isEmpty ? double.nan : vals.reduce((a, b) => a + b) / vals.length;
  }
  double minV(String key) { final v = filtered().map((r) => n(r, key)).where((x) => !x.isNaN).toList(); return v.isEmpty ? double.nan : v.reduce(math.min); }
  double maxV(String key) { final v = filtered().map((r) => n(r, key)).where((x) => !x.isNaN).toList(); return v.isEmpty ? double.nan : v.reduce(math.max); }

  double dewPoint(double temp, double humidity) {
    if (temp.isNaN || humidity.isNaN || humidity <= 0) return double.nan;
    const a = 17.62, b = 243.12;
    final gamma = math.log(humidity / 100) + a * temp / (b + temp);
    return b * gamma / (a - gamma);
  }
  double heatIndex(double c, double rh) {
    if (c.isNaN || rh.isNaN) return double.nan;
    final f = c * 9 / 5 + 32;
    if (f < 80) return c;
    final hi = -42.379 + 2.04901523*f + 10.14333127*rh - 0.22475541*f*rh - 0.00683783*f*f - 0.05481717*rh*rh + 0.00122874*f*f*rh + 0.00085282*f*rh*rh - 0.00000199*f*f*rh*rh;
    return (hi - 32) * 5 / 9;
  }

  String direction(double deg) {
    if (deg.isNaN) return '--';
    const names = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW'];
    return names[((deg + 11.25) ~/ 22.5) % 16];
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(appBar: AppBar(title: const Text('SG Segamat Weather')), body: const Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(appBar: AppBar(title: const Text('SG Segamat Weather')), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off, size: 60), const SizedBox(height: 12), Text(t('Data unavailable', 'Data tidak tersedia'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(error!, textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton.icon(onPressed: load, icon: const Icon(Icons.refresh), label: Text(t('Retry', 'Cuba lagi')))]))));

    final pages = [dashboard(), history(), wind(), alerts(), more()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('SG Segamat Weather'),
        actions: [
          IconButton(tooltip: 'BM / EN', onPressed: widget.onLanguage, icon: const Icon(Icons.translate)),
          IconButton(tooltip: 'Theme', onPressed: widget.onTheme, icon: const Icon(Icons.brightness_6_outlined)),
          IconButton(tooltip: 'Refresh', onPressed: load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(onRefresh: load, child: pages[tab]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: [
        NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: t('Live', 'Live')),
        NavigationDestination(icon: const Icon(Icons.show_chart), label: t('History', 'Sejarah')),
        NavigationDestination(icon: const Icon(Icons.explore_outlined), selectedIcon: const Icon(Icons.explore), label: t('Wind', 'Angin')),
        NavigationDestination(icon: const Icon(Icons.notifications_outlined), selectedIcon: const Icon(Icons.notifications), label: t('Alerts', 'Amaran')),
        NavigationDestination(icon: const Icon(Icons.more_horiz), label: t('More', 'Lagi')),
      ]),
    );
  }

  Widget dashboard() {
    final temp = n(latest, 'temperature'), hum = n(latest, 'humidity'), wind = n(latest, 'wind_direction'), uv = n(latest, 'uv'), pressure = n(latest, 'pressure'), light = n(latest, 'visible_light'), alt = n(latest, 'altitude'), batt = n(latest, 'battery_v');
    final heat = heatIndex(temp, hum), dew = dewPoint(temp, hum);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.location_on), const SizedBox(width: 6), const Expanded(child: Text('Sungai Segamat, Johor', style: TextStyle(fontWeight: FontWeight.bold))), statusChip(online())]),
        const SizedBox(height: 20),
        Text('${f(temp)}°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
        Text(t('Current temperature', 'Suhu semasa')),
        const SizedBox(height: 8), Text('${t('Wind', 'Angin')}: ${f(wind)}° ${direction(wind)}', style: TextStyle(color: Colors.grey.shade700)),
        Text('${t('Last updated', 'Kemas kini')}: ${latest['timestamp'] ?? '--'} GMT+8', style: TextStyle(color: Colors.grey.shade700)),
      ]))),
      const SizedBox(height: 12),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5, children: [
        metric(Icons.water_drop, t('Humidity', 'Kelembapan'), hum, '%'), metric(Icons.explore, t('Wind direction', 'Arah angin'), wind, '° ${direction(wind)}'), metric(Icons.wb_sunny, 'UV', uv, ''), metric(Icons.speed, t('Pressure', 'Tekanan'), pressure, ' hPa'), metric(Icons.light_mode, t('Visible light', 'Cahaya nampak'), light, ''), metric(Icons.terrain, t('Altitude', 'Altitud'), alt, ' m'), metric(Icons.battery_full, t('Battery', 'Bateri'), batt, ' V'),
      ]),
      const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t('Temperature trend', 'Trend suhu'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12), chart('temperature', 220)]))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t('Comfort & analytics', 'Keselesaan & analitik'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Wrap(spacing: 8, runSpacing: 8, children: [infoChip(t('Heat index', 'Indeks haba'), '${f(heat)}°C'), infoChip(t('Dew point', 'Takat embun'), '${f(dew)}°C'), infoChip(t('Records', 'Rekod'), '${filtered().length}')])])])))
    ]);
  }

  Widget statusChip(bool ok) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: ok ? Colors.green.withValues(alpha: .14) : Colors.red.withValues(alpha: .14), borderRadius: BorderRadius.circular(20)), child: Text(ok ? '● ONLINE' : '● OFFLINE', style: TextStyle(color: ok ? Colors.green : Colors.red, fontWeight: FontWeight.bold)));
  Widget infoChip(String a, String b) => Chip(label: Text('$a: $b'));
  Widget metric(IconData icon, String label, double value, String unit) => Card(child: Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 24), const Spacer(), Text(label, style: const TextStyle(color: Colors.grey)), Text('${f(value)}$unit', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))])));

  Widget chart(String key, double height) {
    final data = filtered();
    if (data.length < 2) return SizedBox(height: height, child: Center(child: Text(t('Not enough history', 'Sejarah tidak mencukupi'))));
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) { final v = n(data[i], key); if (!v.isNaN) spots.add(FlSpot(i.toDouble(), v)); }
    if (spots.isEmpty) return SizedBox(height: height, child: const Center(child: Text('--')));
    return SizedBox(height: height, child: LineChart(LineChartData(minX: 0, maxX: math.max(1, data.length - 1).toDouble(), gridData: const FlGridData(show: true), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(isCurved: true, barWidth: 3, dotData: const FlDotData(show: false), spots: spots)])));
  }

  Widget history() {
    final data = filtered();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(t('History & graphs', 'Sejarah & graf'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
      SegmentedButton<String>(segments: const [ButtonSegment(value: '1h', label: Text('1h')), ButtonSegment(value: '6h', label: Text('6h')), ButtonSegment(value: '24h', label: Text('24h')), ButtonSegment(value: '7d', label: Text('7d')), ButtonSegment(value: '30d', label: Text('30d'))], selected: {range}, onSelectionChanged: (s) => setState(() => range = s.first)),
      const SizedBox(height: 14),
      for (final item in [('temperature','Temperature','°C'),('humidity','Humidity','%'),('pressure','Pressure','hPa'),('uv','UV',''),('visible_light','Visible light',''),('battery_v','Battery','V')]) Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${item.$2} ${item.$3}', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), chart(item.$1, 170), Wrap(spacing: 6, children: [infoChip('Min', f(minV(item.$1))), infoChip('Avg', f(avg(item.$1))), infoChip('Max', f(maxV(item.$1)))])]))),
      Card(child: ListTile(leading: const Icon(Icons.history), title: Text(t('Records', 'Rekod')), subtitle: Text('${data.length} ${t('records in selected range', 'rekod dalam julat dipilih')}'))),
    ];
  }

  Widget wind() {
    final w = n(latest, 'wind_direction');
    final data = filtered();
    final counts = <String, int>{};
    for (final r in data) { final d = direction(n(r, 'wind_direction')); if (d != '--') counts[d] = (counts[d] ?? 0) + 1; }
    final dominant = counts.entries.isEmpty ? '--' : counts.entries.reduce((a,b) => a.value >= b.value ? a : b).key;
    return ListView(padding: const EdgeInsets.all(16), children: [Text(t('Wind analysis', 'Analisis angin'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 14), Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Text(direction(w), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)), Text('${f(w)}°'), const SizedBox(height: 20), SizedBox(width: 230, height: 230, child: CustomPaint(painter: CompassPainter(w)))]))), const SizedBox(height: 12), Card(child: ListTile(leading: const Icon(Icons.explore), title: Text(t('Dominant direction', 'Arah dominan')), subtitle: Text('$dominant (${counts[dominant] ?? 0} records)'))), const SizedBox(height: 12), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t('Wind rose', 'Wind rose'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12), ...counts.entries.toList()..sort((a,b)=>b.value.compareTo(a.value)),].map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [SizedBox(width: 42, child: Text(e.key)), Expanded(child: LinearProgressIndicator(value: e.value / math.max(1, data.length))), const SizedBox(width: 8), Text('${e.value}')]))).toList()))), const SizedBox(height: 12), Card(child: ListTile(leading: const Icon(Icons.speed), title: Text(t('Wind speed', 'Kelajuan angin')), subtitle: Text(t('Not provided by the current station payload.', 'Tiada dalam data stesen semasa.'))))]);
  }

  Widget alerts() {
    final temp = n(latest,'temperature'), uv = n(latest,'uv'), hum = n(latest,'humidity'), batt = n(latest,'battery_v');
    final active = <String>[];
    if (alertEnabled['Temperature']! && !temp.isNaN && temp >= thresholds['High temperature']!) active.add('High temperature');
    if (alertEnabled['Temperature']! && !temp.isNaN && temp <= thresholds['Low temperature']!) active.add('Low temperature');
    if (alertEnabled['UV']! && !uv.isNaN && uv >= thresholds['High UV']!) active.add('High UV');
    if (alertEnabled['Humidity']! && !hum.isNaN && hum >= thresholds['High humidity']!) active.add('High humidity');
    if (alertEnabled['Battery']! && !batt.isNaN && batt > 0 && batt <= thresholds['Low battery']!) active.add('Low battery');
    if (alertEnabled['Offline']! && !online()) active.add('Station offline / stale data');
    return ListView(padding: const EdgeInsets.all(16), children: [Text(t('Alerts & thresholds', 'Amaran & ambang'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Card(child: ListTile(leading: Icon(active.isEmpty ? Icons.check_circle : Icons.warning, color: active.isEmpty ? Colors.green : Colors.orange), title: Text(active.isEmpty ? t('No active alerts', 'Tiada amaran aktif') : '${active.length} ${t('active alert(s)', 'amaran aktif')}'), subtitle: active.isEmpty ? Text(t('Station looks normal based on configured rules.', 'Stesen kelihatan normal berdasarkan peraturan.')) : Text(active.join(' • ')))), const SizedBox(height: 10), ...alertRow('Temperature', 'Temperature alerts', ['High temperature','Low temperature']), alertRow('UV','High UV',['High UV']), alertRow('Humidity','High humidity',['High humidity']), alertRow('Battery','Low battery',['Low battery']), alertRow('Offline','Offline / stale data',['Station offline / stale data'])]);
  }

  Widget alertRow(String key, String title, List<String> keys) => Card(child: ExpansionTile(title: Text(title), trailing: Switch(value: alertEnabled[key] ?? true, onChanged: (v) => setState(() => alertEnabled[key] = v),), children: [for (final k in keys) ListTile(title: Text(k), trailing: Text('${f(thresholds[k] ?? 0)}'))]));

  Widget more() => ListView(padding: const EdgeInsets.all(16), children: [Text(t('Tools & AI', 'Alat & AI'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Card(child: ListTile(leading: const Icon(Icons.psychology), title: Text(t('Ask SG Segamat AI', 'Tanya SG Segamat AI')), subtitle: Text(t('Ask about the live station data, trends and comfort.', 'Tanya tentang data stesen, trend dan keselesaan.')), onTap: showAi)), Card(child: ListTile(leading: const Icon(Icons.file_download), title: Text(t('Export & share CSV', 'Eksport & kongsi CSV')), subtitle: Text(t('Export the selected history range.', 'Eksport sejarah bagi julat dipilih.')), onTap: exportCsv)), Card(child: ListTile(leading: const Icon(Icons.calendar_month), title: Text(t('Daily / weekly report', 'Laporan harian / mingguan')), subtitle: Text(reportText()))), Card(child: ListTile(leading: const Icon(Icons.location_city), title: Text(t('Station selector', 'Pemilih stesen')), subtitle: const Text('SG_Segamat'), onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: Text(t('Stations', 'Stesen')), content: const Text('SG_Segamat\n\nAdditional stations can be added when their data sources are available.'), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('OK'))]))), Card(child: ListTile(leading: const Icon(Icons.map_outlined), title: Text(t('Station map', 'Peta stesen')), subtitle: Text(t('Map coordinates are not present in the current station data.', 'Koordinat peta tiada dalam data stesen semasa.')))), Card(child: ListTile(leading: const Icon(Icons.info_outline), title: const Text('SG Segamat Weather'), subtitle: const Text('Phases 1–9 feature set • GitHub data source • GMT+8'))]);

  String reportText() {
    final temp = n(latest,'temperature');
    return '${t('Current', 'Semasa')}: ${f(temp)}°C • ${t('24h average', 'Purata 24j')}: ${f(avg('temperature'))}°C • ${t('High', 'Tinggi')}: ${f(maxV('temperature'))}°C • ${t('Low', 'Rendah')}: ${f(minV('temperature'))}°C';
  }

  Future<void> showAi() async {
    final temp = n(latest,'temperature'), hum = n(latest,'humidity'), uv = n(latest,'uv'), wind = n(latest,'wind_direction');
    final text = '${t('Live answer based on the station payload:', 'Jawapan langsung berdasarkan data stesen:')}\n\n${t('Temperature', 'Suhu')}: ${f(temp)}°C\n${t('Humidity', 'Kelembapan')}: ${f(hum)}%\nUV: ${f(uv)}\n${t('Wind', 'Angin')}: ${direction(wind)} (${f(wind)}°)\n\n${temp >= thresholds['High temperature']! ? t('It is currently hot; take heat precautions.', 'Keadaan panas; ambil langkah berjaga-jaga haba.') : t('Temperature is below the configured high-temperature threshold.', 'Suhu di bawah ambang suhu tinggi yang ditetapkan.')}\n${uv >= thresholds['High UV']! ? t('UV is at the configured high-risk threshold.', 'UV mencapai ambang risiko tinggi yang ditetapkan.') : t('UV is below the configured high-risk threshold.', 'UV di bawah ambang risiko tinggi yang ditetapkan.')}\n\n${t('Trend: 24h average temperature is', 'Trend: purata suhu 24j ialah')} ${f(avg('temperature'))}°C.';
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(title: const Row(children: [Icon(Icons.psychology), SizedBox(width: 8), Text('SG Segamat AI')]), content: SingleChildScrollView(child: Text(text)), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('OK'))]));
  }

  Future<void> exportCsv() async {
    final data = filtered();
    final fields = ['station_name','timestamp','temperature','humidity','wind_direction','uv','visible_light','pressure','altitude','battery_v'];
    final rows = [fields.join(','), ...data.map((r) => fields.map((f) => '"${(r[f] ?? '').toString().replaceAll('"','""')}"').join(','))];
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/SG_Segamat_weather_${range}.csv');
    await file.writeAsString(rows.join('\n'));
    await Share.shareXFiles([XFile(file.path)], text: 'SG Segamat Weather CSV ($range)');
  }
}

class CompassPainter extends CustomPainter {
  final double degrees;
  CompassPainter(this.degrees);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width/2, s.height/2), r = s.shortestSide/2 - 8;
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;
    c.drawCircle(center, r, p);
    final labels = ['N','E','S','W'];
    for (var i=0;i<4;i++) { final a=i*math.pi/2; final pos=center+Offset(math.sin(a)*(r-22), -math.cos(a)*(r-22)); final tp=TextPainter(text: TextSpan(text:labels[i], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), textDirection: TextDirection.ltr)..layout(); tp.paint(c,pos-Offset(tp.width/2,tp.height/2)); }
    if (!degrees.isNaN) { final a=degrees*math.pi/180; final end=center+Offset(math.sin(a)*(r-35), -math.cos(a)*(r-35)); final q=Paint()..strokeWidth=5..strokeCap=StrokeCap.round; c.drawLine(center,end,q); }
  }
  @override bool shouldRepaint(covariant CompassPainter old) => old.degrees != degrees;
}
