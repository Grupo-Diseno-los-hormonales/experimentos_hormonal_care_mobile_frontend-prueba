import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/pages/support_chat_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/appointment_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/appointment_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/doctors_list_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/treatment_tracker/domain/models/log_entry_model.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TreatmentTrackerScreen extends StatefulWidget {
  const TreatmentTrackerScreen({Key? key}) : super(key: key);

  @override
  State<TreatmentTrackerScreen> createState() => _TreatmentTrackerScreenState();
}

class _TreatmentTrackerScreenState extends State<TreatmentTrackerScreen> {

  int? patientId;

  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  
  int _streakCount = 0;
  List<bool> _weeklyProgress = List.filled(7, false);
  List<LogEntry> _logHistory = [];
  
  // Clave para almacenar datos en SharedPreferences
  final String _streakKey = 'streak_count';
  final String _lastLogDateKey = 'last_log_date';
  final String _weeklyProgressKey = 'weekly_progress';
  final String _logHistoryKey = 'log_history';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Cargar datos guardados
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _streakCount = prefs.getInt(_streakKey) ?? 0;
      
      // Cargar progreso semanal
      final weeklyProgressList = prefs.getStringList(_weeklyProgressKey);
      if (weeklyProgressList != null) {
        _weeklyProgress = weeklyProgressList.map((e) => e == 'true').toList();
      } else {
        // Inicializar el progreso semanal basado en el día actual
        _initializeWeeklyProgress();
      }
      
      // Cargar historial de registros
      final logHistoryJson = prefs.getStringList(_logHistoryKey);
      if (logHistoryJson != null) {
        _logHistory = logHistoryJson
            .map((json) => LogEntry.fromJson(json))
            .toList();
      }
    });
    
    // Verificar si se perdió la racha
    _checkStreakContinuity();
  }
  
  // Inicializar el progreso semanal basado en el día actual
  void _initializeWeeklyProgress() {
    final now = DateTime.now();
    final currentWeekday = now.weekday % 7; // 0 = domingo, 1 = lunes, ..., 6 = sábado
    
    _weeklyProgress = List.generate(7, (index) {
      // Marcar días pasados de la semana actual como no completados
      return false;
    });
  }
  
  // Verificar si se perdió la racha
  void _checkStreakContinuity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogDateStr = prefs.getString(_lastLogDateKey);
    
    if (lastLogDateStr != null) {
      final lastLogDate = DateTime.parse(lastLogDateStr);
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      
      // Si el último registro fue antes de ayer, se perdió la racha
      if (lastLogDate.isBefore(yesterday)) {
        setState(() {
          _streakCount = 0;
          _saveStreakData();
        });
      }
    }
  }
  
  // Guardar datos de racha
  Future<void> _saveStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, _streakCount);
    
    // Guardar progreso semanal
    final weeklyProgressList = _weeklyProgress.map((e) => e.toString()).toList();
    await prefs.setStringList(_weeklyProgressKey, weeklyProgressList);
    
    // Guardar historial de registros
    final logHistoryJson = _logHistory.map((entry) => entry.toJson()).toList();
    await prefs.setStringList(_logHistoryKey, logHistoryJson);
  }
  
  // Actualizar racha cuando se registran datos
  void _updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final prefs = await SharedPreferences.getInstance();
    
    // Obtener la fecha del último registro
    final lastLogDateStr = prefs.getString(_lastLogDateKey);
    DateTime? lastLogDate;
    if (lastLogDateStr != null) {
      lastLogDate = DateTime.parse(lastLogDateStr);
    }
    
    // Si es el primer registro o si el último registro fue ayer, incrementar la racha
    if (lastLogDate == null) {
      setState(() {
        _streakCount = 1;
      });
    } else if (lastLogDate.isBefore(today)) {
      // Si el último registro fue de un día anterior (no hoy)
      final difference = today.difference(lastLogDate).inDays;
      
      if (difference == 1) {
        // Si fue exactamente ayer, incrementar la racha
        setState(() {
          _streakCount++;
        });
      } else {
        // Si fue hace más de un día, reiniciar la racha
        setState(() {
          _streakCount = 1;
        });
      }
    }
    
    // Actualizar el día de la semana en el progreso semanal
    final weekday = now.weekday % 7; // 0 = domingo, 1 = lunes, ..., 6 = sábado
    setState(() {
      _weeklyProgress[weekday] = true;
    });
    
    // Guardar la fecha del último registro
    await prefs.setString(_lastLogDateKey, today.toIso8601String());
    
    // Guardar los datos actualizados
    _saveStreakData();
  }
  
  // Guardar el registro diario
  void _saveLog() {
    // Validar que ambos campos estén completos
    if (_glucoseController.text.isEmpty || _insulinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both glucose and insulin values'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Convertir valores a números
    final glucoseValue = double.tryParse(_glucoseController.text);
    final insulinValue = double.tryParse(_insulinController.text);
    
    if (glucoseValue == null || insulinValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Crear nuevo registro
    final now = DateTime.now();
    final newEntry = LogEntry(
      date: now,
      glucose: glucoseValue,
      insulin: insulinValue,
    );
    
    // Agregar al historial
    setState(() {
      _logHistory.insert(0, newEntry); // Agregar al inicio de la lista
      if (_logHistory.length > 30) {
        _logHistory = _logHistory.sublist(0, 30); // Mantener solo los últimos 30 registros
      }
    });
    
    // Actualizar racha
    _updateStreak();
    
    // Limpiar campos
    _glucoseController.clear();
    _insulinController.clear();
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  @override
  void dispose() {
    _glucoseController.dispose();
    _insulinController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Logo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2D1F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "HC",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "HormonalCare",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 40),
              
              // Contador de racha
              Center(
                child: Column(
                  children: [
                    Text(
                      "$_streakCount",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "days streak",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Visualización semanal
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Días de la semana
                    // ignore: prefer_const_constructors
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Text("S", style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("M", style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("T", style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("W", style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("T", style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("F", style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("S", style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Círculos de progreso
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _weeklyProgress[index]
                                ? const Color(0xFFBFA2C7)
                                : Colors.grey.shade200,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      "Keep going like this!",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Sección de hoy
              const Text(
                "Today",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo de glucosa
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFBFA2C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      "Blood glucose",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _glucoseController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                          suffixText: "mg/dL",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Campo de insulina
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFBFA2C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      "Insulin",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _insulinController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                          suffixText: "units",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Botón de guardar
              Center(
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _saveLog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C7FA3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Save"),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
               // Historial de registros
            const Text(
              "LOG HISTORY",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: _logHistory.isEmpty
                  ? [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No logs yet"),
                        ),
                      )
                    ]
                  : _logHistory.take(3).map((entry) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  _formatLogDate(entry.date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${entry.glucose.toStringAsFixed(0)} mg/dL",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    }).toList(),
            ),

            // --- Botón de soporte al final de la sección de perfil ---
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F7193),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.support_agent, color: Colors.white),
                label: const Text(
                  'Soporte HormonalCare',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SupportChatScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
    bottomNavigationBar: CustomBottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreenPatient()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorListScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppointmentScreenPatient()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TreatmentTrackerScreen()),
            );
            break;
        }
      },
    ),
  );
}
  
  // Formatear fecha para el historial
  String _formatLogDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final logDate = DateTime(date.year, date.month, date.day);
    
    if (logDate == today) {
      return "TODAY";
    } else if (logDate == yesterday) {
      return "YESTERDAY";
    } else {
      return DateFormat('EEE, MMM d').format(date).toUpperCase();
    }
  }
}