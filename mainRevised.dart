import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const FirstResponderApp());
}

class FirstResponderApp extends StatelessWidget {
  const FirstResponderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirstResponder',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      home: const MedicalDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VitalReading {
  final int systolic;
  final int diastolic;
  final int heartRate;
  final int spo2;
  final DateTime timestamp;

  VitalReading({
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.spo2,
    required this.timestamp,
  });
}

class MedicalDashboard extends StatefulWidget {
  const MedicalDashboard({super.key});

  @override
  State<MedicalDashboard> createState() => _MedicalDashboardState();
}

class _MedicalDashboardState extends State<MedicalDashboard> {
  
  // Medical readings
  int systolic = 120;
  int diastolic = 80;
  int heartRate = 72;
  int spo2 = 98;
  bool isConnected = true;
  bool isDarkMode = false;
  
  Timer? _dataTimer;
  List<VitalReading> savedReadings = [];
  
  @override
  void initState() {
    super.initState();
    _simulateDataUpdates();
  }
  
  void _simulateDataUpdates() {
    _dataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Simulate realistic medical data variations
          systolic = 115 + Random().nextInt(20);
          diastolic = 75 + Random().nextInt(15);
          heartRate = 65 + Random().nextInt(25);
          spo2 = 95 + Random().nextInt(5);
          isConnected = Random().nextBool() ? true : Random().nextInt(10) > 1;
        });
      }
    });
  }
  
  void _refreshReadings() {
    setState(() {
      systolic = 115 + Random().nextInt(20);
      diastolic = 75 + Random().nextInt(15);
      heartRate = 65 + Random().nextInt(25);
      spo2 = 95 + Random().nextInt(5);
      isConnected = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Readings refreshed'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _saveReading() {
    final reading = VitalReading(
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      spo2: spo2,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      savedReadings.insert(0, reading);
      if (savedReadings.length > 50) {
        savedReadings.removeLast();
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reading saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }
  
  void _sendToHospital() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send to Hospital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select nearby hospital:'),
            const SizedBox(height: 16),
            _buildHospitalOption('General Hospital', '0.5 km'),
            _buildHospitalOption('Emergency Medical Center', '1.2 km'),
            _buildHospitalOption('City Hospital', '2.1 km'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Patient data sent to hospital'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHospitalOption(String name, String distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.local_hospital),
        title: Text(name),
        subtitle: Text(distance),
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sending data to $name...'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
  
  void _showSavedReadings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saved Readings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: savedReadings.isEmpty
                  ? const Center(
                      child: Text(
                        'No saved readings yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: savedReadings.length,
                      itemBuilder: (context, index) {
                        final reading = savedReadings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              'BP: ${reading.systolic}/${reading.diastolic} | HR: ${reading.heartRate} | SpO2: ${reading.spo2}%',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${reading.timestamp.toString().substring(0, 19)}',
                            ),
                            trailing: Icon(
                              Icons.circle,
                              color: _getVitalColor('bp', reading.systolic),
                              size: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _dataTimer?.cancel();
    super.dispose();
  }
  
  Color _getVitalColor(String vital, int value) {
    switch (vital) {
      case 'bp':
        if (systolic > 140 || diastolic > 90) return Colors.red.shade400;
        if (systolic < 90 || diastolic < 60) return Colors.orange.shade400;
        return Colors.green.shade400;
      case 'hr':
        if (value > 100 || value < 60) return Colors.orange.shade400;
        return Colors.green.shade400;
      case 'spo2':
        if (value < 95) return Colors.red.shade400;
        if (value < 98) return Colors.orange.shade400;
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Theme(
      data: isDarkMode 
          ? ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2563EB),
                brightness: Brightness.dark,
              ),
              fontFamily: 'Inter',
            )
          : ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2563EB),
                brightness: Brightness.light,
              ),
              fontFamily: 'Inter',
            ),
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'FirstResponder',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient Monitor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Real-time vital signs monitoring',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _refreshReadings,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveReading,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showSavedReadings,
                      icon: const Icon(Icons.history),
                      label: const Text('View History'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _sendToHospital,
                      icon: const Icon(Icons.local_hospital),
                      label: const Text('Send to Hospital'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                  children: [
                    _buildVitalCard(
                      title: 'Blood Pressure',
                      value: '$systolic/$diastolic',
                      unit: 'mmHg',
                      icon: Icons.favorite,
                      color: _getVitalColor('bp', systolic),
                    ),
                    _buildVitalCard(
                      title: 'Heart Rate',
                      value: '$heartRate',
                      unit: 'bpm',
                      icon: Icons.monitor_heart,
                      color: _getVitalColor('hr', heartRate),
                    ),
                    _buildVitalCard(
                      title: 'Oxygen Saturation',
                      value: '$spo2',
                      unit: '%',
                      icon: Icons.air,
                      color: _getVitalColor('spo2', spo2),
                    ),
                    _buildVitalCard(
                      title: 'Temperature',
                      value: '98.6',
                      unit: '°F',
                      icon: Icons.thermostat,
                      color: Colors.blue.shade400,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Stable',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildVitalCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    final isDark = isDarkMode;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}