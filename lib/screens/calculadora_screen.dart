import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ciudad.dart';
import '../services/air_quality_service.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _horasController = TextEditingController();
  final _service = AirQualityService();

  Ciudad? _ciudadSeleccionada;
  bool _cargando = false;
  double? _indiceCalculado;
  double? _pm25Promedio;

  @override
  void dispose() {
    _fechaController.dispose();
    _horasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00838F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF263238),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      final String fechaStr =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      setState(() => _fechaController.text = fechaStr);
    }
  }

  String _clasificarRiesgo(double indice) {
    if (indice < 100) return 'Bajo';
    if (indice <= 200) return 'Moderado';
    return 'Alto';
  }

  Color _colorSegunRiesgo(String nivel) {
    switch (nivel) {
      case 'Bajo':
        return const Color(0xFF2E7D32);
      case 'Moderado':
        return const Color(0xFFEF6C00);
      case 'Alto':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  IconData _iconoSegunRiesgo(String nivel) {
    switch (nivel) {
      case 'Bajo':
        return Icons.sentiment_very_satisfied_rounded;
      case 'Moderado':
        return Icons.sentiment_neutral_rounded;
      case 'Alto':
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }

  String _mensajeSegunRiesgo(String nivel) {
    switch (nivel) {
      case 'Bajo':
        return 'El aire está limpio. Disfruta tus actividades al aire libre.';
      case 'Moderado':
        return 'Considera reducir actividades prolongadas al aire libre.';
      case 'Alto':
        return 'Evita actividades al aire libre. Usa mascarilla si sales.';
      default:
        return '';
    }
  }

  Future<void> _calcularIndice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ciudadSeleccionada == null) return;

    setState(() {
      _cargando = true;
      _indiceCalculado = null;
      _pm25Promedio = null;
    });

    try {
      final double promedioPM25 = await _service.obtenerPromedioPM25(
        latitud: _ciudadSeleccionada!.latitud,
        longitud: _ciudadSeleccionada!.longitud,
        fecha: _fechaController.text,
      );

      final double horas = double.parse(_horasController.text);
      final double indice = promedioPM25 * horas;

      setState(() {
        _pm25Promedio = promedioPM25;
        _indiceCalculado = indice;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? nivel =
        _indiceCalculado != null ? _clasificarRiesgo(_indiceCalculado!) : null;
    final Color colorPrincipal =
        nivel != null ? _colorSegunRiesgo(nivel) : const Color(0xFF00838F);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorPrincipal.withOpacity(0.15),
              const Color(0xFFE0F7FA).withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorPrincipal.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.air_rounded,
                            size: 48,
                            color: colorPrincipal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Calidad del Aire',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Calcula tu exposición diaria',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tarjeta del formulario
                  Card(
                    elevation: 8,
                    shadowColor: colorPrincipal.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Dropdown ciudad
                          DropdownButtonFormField<Ciudad>(
                            decoration: InputDecoration(
                              labelText: 'Ciudad',
                              prefixIcon: const Icon(Icons.location_city_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            value: _ciudadSeleccionada,
                            items: ciudadesColombia.map((ciudad) {
                              return DropdownMenuItem<Ciudad>(
                                value: ciudad,
                                child: Text(ciudad.nombre),
                              );
                            }).toList(),
                            onChanged: (Ciudad? nuevaCiudad) {
                              setState(() => _ciudadSeleccionada = nuevaCiudad);
                            },
                            validator: (value) =>
                                value == null ? 'Seleccione una ciudad' : null,
                          ),
                          const SizedBox(height: 16),

                          // Campo fecha
                          TextFormField(
                            controller: _fechaController,
                            readOnly: true,
                            onTap: _seleccionarFecha,
                            decoration: InputDecoration(
                              labelText: 'Fecha de consulta',
                              prefixIcon: const Icon(Icons.calendar_today_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Seleccione una fecha'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          // Campo horas (con validación estricta)
                          TextFormField(
                            controller: _horasController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              // Solo permite números y un punto decimal (máx 2 dígitos + 2 decimales)
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Horas de exposición',
                              prefixIcon: const Icon(Icons.access_time_rounded),
                              suffixText: 'hrs',
                              hintText: 'Ej: 8 o 5.5',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese las horas';
                              }
                              final horas = double.tryParse(value);
                              if (horas == null) {
                                return 'Ingrese un número válido';
                              }
                              if (horas <= 0) {
                                return 'Las horas deben ser mayores a 0';
                              }
                              if (horas > 24) {
                                return 'Máximo 24 horas por día';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Botón
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _cargando ? null : _calcularIndice,
                              icon: _cargando
                                  ? const SizedBox.shrink()
                                  : const Icon(Icons.calculate_rounded),
                              label: _cargando
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Calcular Índice',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorPrincipal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tarjeta de resultado
                  if (_indiceCalculado != null && nivel != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      child: Card(
                        elevation: 8,
                        shadowColor: colorPrincipal.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorPrincipal.withOpacity(0.1),
                                Colors.white,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _iconoSegunRiesgo(nivel),
                                size: 64,
                                color: colorPrincipal,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nivel de Riesgo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nivel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: colorPrincipal,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: colorPrincipal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Índice de exposición',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      _indiceCalculado!.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: colorPrincipal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Info PM2.5
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _infoChip(
                                    icon: Icons.cloud_outlined,
                                    label: 'PM2.5 prom.',
                                    value:
                                        '${_pm25Promedio!.toStringAsFixed(1)} µg/m³',
                                  ),
                                  _infoChip(
                                    icon: Icons.schedule_outlined,
                                    label: 'Exposición',
                                    value: '${_horasController.text} hrs',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: colorPrincipal, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _mensajeSegunRiesgo(nivel),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Pie de página
                  Text(
                    'Datos: Open-Meteo Air Quality API',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}