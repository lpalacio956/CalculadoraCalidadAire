import 'dart:convert';
import 'package:http/http.dart' as http;

class AirQualityService {
  static const String _baseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  /// Consulta la API de Open-Meteo y retorna el promedio diario de PM2.5
  Future<double> obtenerPromedioPM25({
    required double latitud,
    required double longitud,
    required String fecha, // formato: YYYY-MM-DD
  }) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$latitud&longitude=$longitud'
      '&hourly=pm2_5&start_date=$fecha&end_date=$fecha',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al consultar la API: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic>? valores = data['hourly']?['pm2_5'];

    if (valores == null || valores.isEmpty) {
      throw Exception('No hay datos de PM2.5 para esa fecha');
    }

    // Filtramos valores nulos y calculamos el promedio
    final List<double> valoresValidos = valores
        .where((v) => v != null)
        .map<double>((v) => (v as num).toDouble())
        .toList();

    if (valoresValidos.isEmpty) {
      throw Exception('No hay valores válidos de PM2.5');
    }

    final double suma = valoresValidos.reduce((a, b) => a + b);
    return suma / valoresValidos.length;
  }
}