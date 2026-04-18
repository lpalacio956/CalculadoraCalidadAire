class Ciudad {
  final String nombre;
  final double latitud;
  final double longitud;

  const Ciudad({
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });
}

// Lista de ciudades de Colombia disponibles
const List<Ciudad> ciudadesColombia = [
  Ciudad(nombre: 'Bogotá', latitud: 4.61, longitud: -74.08),
  Ciudad(nombre: 'Medellín', latitud: 6.25, longitud: -75.56),
  Ciudad(nombre: 'Cali', latitud: 3.45, longitud: -76.53),
  Ciudad(nombre: 'Barranquilla', latitud: 10.96, longitud: -74.80),
  Ciudad(nombre: 'Cartagena', latitud: 10.39, longitud: -75.51),
  Ciudad(nombre: 'Bucaramanga', latitud: 7.12, longitud: -73.12),
  Ciudad(nombre: 'Pereira', latitud: 4.81, longitud: -75.69),
  Ciudad(nombre: 'Santa Marta', latitud: 11.24, longitud: -74.20),
];