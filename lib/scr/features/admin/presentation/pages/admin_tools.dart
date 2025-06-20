import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/admin_chat_section.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'send_notice.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';

class AdminToolsScreen extends StatefulWidget {
  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen> with TickerProviderStateMixin {
  
  late TabController _tabController;
  late AnimationController _animationController;
  final AuthService _authService = AuthService();

Future<void> _logout() async {
  await _authService.logout();
  if (!mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => SignIn()),
    (route) => false,
  );
}

 @override
void initState() {
  _tabController = TabController(length: 5, vsync: this); // Cambia a 5
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();
  super.initState();
}

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Fondo animado morado clarito
        return Scaffold(
          backgroundColor: const Color(0xFFF3EAF7),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF3EAF7),
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                const SizedBox(width: 16),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Color(0xFF4B006E),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F7193),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                color: const Color(0xFFF3EAF7),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFFE5DDE6),
                  ),
                  labelColor: const Color(0xFF8F7193),
                  unselectedLabelColor: const Color(0xFF4B006E),
                  tabs: const [
                    Tab(text: 'Dashboard'),
                    Tab(text: 'Stats'),
                    Tab(text: 'Avisos'),
                    Tab(text: 'Chat'),
                    Tab(text: 'Logs'),

                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              // Fondo animado con gradiente morado claro
              Positioned.fill(
                child: AnimatedGradientBackground(animation: _animationController),
              ),
                      TabBarView(
            controller: _tabController,
            children: [
              _DashboardSection(animation: _animationController),
              _StatsSection(animation: _animationController),
              SendNoticeScreen(),
              AdminGlobalChatSection(), // <-- Aquí agregas el chat
              _LogsSection(animation: _animationController),
            ],
          ),
            ],
          ),
        );
      },
    );
  }
}

// Fondo animado con gradiente morado claro
class AnimatedGradientBackground extends StatelessWidget {
  final Animation<double> animation;
  const AnimatedGradientBackground({required this.animation});
  @override
  Widget build(BuildContext context) {
    final t = animation.value;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + 2 * t, -1 + 2 * t),
          end: Alignment(1 - 2 * t, 1 - 2 * t),
          colors: [
            Color.lerp(const Color(0xFFF3EAF7), const Color(0xFFE5DDE6), sin(t * pi) * 0.5 + 0.5)!,
            Color.lerp(const Color(0xFFE5DDE6), const Color(0xFFF3EAF7), cos(t * pi) * 0.5 + 0.5)!,
          ],
        ),
      ),
    );
  }
}

// DASHBOARD
class _DashboardSection extends StatelessWidget {
  final Animation<double> animation;
  _DashboardSection({required this.animation});

  final stats = const [
    {'label': 'Avisos enviados', 'value': '15,000'},
    {'label': 'Logs registrados', 'value': '45,633'},
    {'label': 'Pacientes reasignados', 'value': '3,012'},
    {'label': 'Intentos fallidos', 'value': '87'},
    {'label': 'Nuevos usuarios', 'value': '124'},
    {'label': 'Tiempo resp. prom.', 'value': '2h 14m'},
    {'label': 'Tickets abiertos', 'value': '16'},
  ];

  final recent = const [
    '[06/06 14:20] User ana99 cambió contraseña',
    '[06/06 14:10] Aviso enviado a todos los doctores',
    '[06/06 13:58] Nuevo usuario juanita23 registrado',
    '[06/06 13:45] Doctor rmendoza reasignado a paciente #303',
    '[06/06 13:30] Ticket de soporte resuelto',
  ];

  final errors = const [
    '🔴 [06/06 14:00] 500 Error en /api/assign-doctor',
    '🔴 [06/06 13:40] Timeout en /api/support',
  ];

  final ips = const [
    '⚠️ 192.168.1.44 — 5 intentos fallidos',
    '⚠️ 190.12.55.88 — 3 intentos fallidos',
  ];

  final alerts = const [
    '🕵️ admin1 inició sesión desde ubicación inusual',
    '🕵️ Intento de acceso no autorizado a /admin/reassign',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: stats.map((stat) => _StatCard(label: stat['label']!, value: stat['value']!, animation: animation)).toList(),
          ),
          const SizedBox(height: 24),
          _CurvedCard(
            animation: animation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Actividad Reciente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF8F7193))),
                ...recent.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(e, style: const TextStyle(color: Color(0xFF4B006E))),
                )),
                const Divider(height: 24),
                const Text('Errores críticos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ...errors.map((e) => Text(e, style: const TextStyle(color: Colors.red))),
                const Divider(height: 24),
                const Text('IPs sospechosas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ...ips.map((e) => Text(e, style: const TextStyle(color: Colors.orange))),
                const Divider(height: 24),
                const Text('Alertas de comportamiento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                ...alerts.map((e) => Text(e, style: const TextStyle(color: Colors.deepPurple))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Animation<double> animation;
  const _StatCard({required this.label, required this.value, required this.animation});
  @override
  Widget build(BuildContext context) {
    return _CurvedCard(
      animation: animation,
      width: 150,
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: double.tryParse(value.replaceAll(',', '')) ?? 0),
            duration: const Duration(milliseconds: 900),
            builder: (context, val, _) => Text(
              val.toInt().toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF7C3AED)),
            ),
          ),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8F7193))),
        ],
      ),
    );
  }
}

// STATS
class _StatsSection extends StatelessWidget {
  final Animation<double> animation;
  _StatsSection({required this.animation});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CurvedCard(
          animation: animation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Consultas vs Seguimientos (Mensual)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8F7193))),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v,_) {
                      const months = ['Ene','Feb','Mar','Abr','May'];
                      return Text(months[v.toInt()%5], style: const TextStyle(color: Color(0xFF8F7193)));
                    }))),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                          toY: 4,
                          color: Color.lerp(const Color(0xFFa18cd1), const Color(0xFFfbc2eb), animation.value)!,
                          borderRadius: BorderRadius.circular(8),
                          width: 18,
                        ),
                        BarChartRodData(
                          toY: 2.4,
                          color: Color.lerp(const Color(0xFFfbc2eb), const Color(0xFFa18cd1), animation.value)!,
                          borderRadius: BorderRadius.circular(8),
                          width: 18,
                        ),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 3, color: Color.lerp(const Color(0xFFa18cd1), const Color(0xFFfbc2eb), animation.value)!, borderRadius: BorderRadius.circular(8), width: 18),
                        BarChartRodData(toY: 1.39, color: Color.lerp(const Color(0xFFfbc2eb), const Color(0xFFa18cd1), animation.value)!, borderRadius: BorderRadius.circular(8), width: 18),
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 2, color: Color.lerp(const Color(0xFFa18cd1), const Color(0xFFfbc2eb), animation.value)!, borderRadius: BorderRadius.circular(8), width: 18),
                        BarChartRodData(toY: 9.8, color: Color.lerp(const Color(0xFFfbc2eb), const Color(0xFFa18cd1), animation.value)!, borderRadius: BorderRadius.circular(8), width: 18),
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(toY: 2.78, color: Color.lerp(const Color(0xFFa18cd1), const Color(0xFFfbc2eb), animation.value)!, borderRadius: BorderRadius.circular(8), width: 18),
                        BarChartRodData(toY: 3.9, color: Color.lerp(const Color(0xFFfbc2eb), const Color(0xFFa18cd1), animation.value)!, borderRadius: BorderRadius.circular(8), width: 18),
                      ]),
                      BarChartGroupData(x: 4, barRods: [
                        BarChartRodData(toY: 1.89, color: Color.lerp(const Color(0xFFa18cd1), const Color(0xFFfbc2eb), animation.value)!, borderRadius: BorderRadius.circular(8), width: 18),
                        BarChartRodData(toY: 4.8, color: Color.lerp(const Color(0xFFfbc2eb), const Color(0xFFa18cd1), animation.value)!, borderRadius: BorderRadius.circular(8), width: 18),
                      ]),
                    ],
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 900),
                  swapAnimationCurve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _CurvedCard(
          animation: animation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Distribución de roles', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8F7193))),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 40,
                        color: Color.lerp(const Color(0xFFa18cd1), const Color(0xFFfbc2eb), animation.value)!,
                        title: 'Doctores',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 30,
                        color: Color.lerp(const Color(0xFFfbc2eb), const Color(0xFFa18cd1), animation.value)!,
                        title: 'Pacientes',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 10,
                        color: Color.lerp(const Color(0xFF7c3aed), const Color(0xFFa18cd1), animation.value)!,
                        title: 'Admins',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                    sectionsSpace: 4,
                    centerSpaceRadius: 30,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 900),
                  swapAnimationCurve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// LOGS
class _LogsSection extends StatelessWidget {
  final Animation<double> animation;
  _LogsSection({required this.animation});
  final logs = const [
    {
      'timestamp': '2025-06-13 22:14',
      'user': 'admin@hormonalcare.com',
      'event': 'Login Success',
      'ip': '192.168.0.12',
      'risk': 'Bajo',
      'details': 'Lima, Perú\nChrome en Windows'
    },
    {
      'timestamp': '2025-06-13 22:20',
      'user': 'ana.romero@hormonalcare.com',
      'event': 'Intento fallido',
      'ip': '192.168.0.42',
      'risk': 'Medio',
      'details': 'Lima, Perú\nEdge en Windows'
    },
    {
      'timestamp': '2025-06-13 23:01',
      'user': 'admin@hormonalcare.com',
      'event': 'Eliminación de usuario',
      'ip': '10.0.0.1',
      'risk': 'Alto',
      'details': 'Lima, Perú\nSafari en macOS'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CurvedCard(
          animation: animation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Logs de acceso y actividad', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8F7193))),
              const SizedBox(height: 8),
              ...logs.map((log) => ExpansionTile(
                title: Text('${log['timestamp']} - ${log['user']}'),
                subtitle: Text('${log['event']} (${log['risk']})'),
                children: [
                  ListTile(
                    title: Text('IP: ${log['ip']}'),
                    subtitle: Text(log['details']!),
                  ),
                ],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFFF6F2FF),
                collapsedBackgroundColor: Colors.white,
                textColor: const Color(0xFF4B006E),
                iconColor: const Color(0xFF8F7193),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

// CARD CURVA REUTILIZABLE CON MARCO ANIMADO
class _CurvedCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final Animation<double> animation;
  const _CurvedCard({required this.child, this.width, required this.animation});
  @override
  Widget build(BuildContext context) {
    final t = animation.value;
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color.lerp(const Color(0xFFa18cd1), const Color(0xFFfbc2eb), t)!,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(const Color(0xFFa18cd1), const Color(0xFFfbc2eb), t)!.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}