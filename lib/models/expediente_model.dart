class Expediente {
  final int? numeroExpediente;
  final String contenido;

  final String demandanteCarnet;
  final String demandanteNombre;
  final String demandanteApellido;

  final String demandadoCarnet;
  final String demandadoNombre;
  final String demandadoApellido;

  final String abogadoDemandanteCarnet;
  final String abogadoDemandanteNombre;
  final String abogadoDemandanteApellido;

  final String abogadoDemandadoCarnet;
  final String abogadoDemandadoNombre;
  final String abogadoDemandadoApellido;

  final String juezCarnet;
  final String juezNombre;
  final String juezApellido;

  Expediente({
    this.numeroExpediente,
    required this.contenido,
    required this.demandanteCarnet,
    required this.demandanteNombre,
    required this.demandanteApellido,
    required this.demandadoCarnet,
    required this.demandadoNombre,
    required this.demandadoApellido,
    required this.abogadoDemandanteCarnet,
    required this.abogadoDemandanteNombre,
    required this.abogadoDemandanteApellido,
    required this.abogadoDemandadoCarnet,
    required this.abogadoDemandadoNombre,
    required this.abogadoDemandadoApellido,
    required this.juezCarnet,
    required this.juezNombre,
    required this.juezApellido,
  });

  factory Expediente.fromJson(Map<String, dynamic> json) {
    return Expediente(
      numeroExpediente: json['numero_expediente'],
      contenido: json['contenido'],
      demandanteCarnet: json['demandante_carnet'],
      demandanteNombre: json['demandante_nombre'],
      demandanteApellido: json['demandante_apellido'],
      demandadoCarnet: json['demandado_carnet'],
      demandadoNombre: json['demandado_nombre'],
      demandadoApellido: json['demandado_apellido'],
      abogadoDemandanteCarnet: json['abogado_demandante_carnet'],
      abogadoDemandanteNombre: json['abogado_demandante_nombre'],
      abogadoDemandanteApellido: json['abogado_demandante_apellido'],
      abogadoDemandadoCarnet: json['abogado_demandado_carnet'],
      abogadoDemandadoNombre: json['abogado_demandado_nombre'],
      abogadoDemandadoApellido: json['abogado_demandado_apellido'],
      juezCarnet: json['juez_carnet'],
      juezNombre: json['juez_nombre'],
      juezApellido: json['juez_apellido'],
    );
  }
}
