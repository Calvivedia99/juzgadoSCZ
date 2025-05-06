import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/services/expediente_service.dart';

class ExpedienteCreateScreen extends StatefulWidget {
  const ExpedienteCreateScreen({super.key});

  @override
  State<ExpedienteCreateScreen> createState() => _ExpedienteCreateScreenState();
}

class _ExpedienteCreateScreenState extends State<ExpedienteCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contenidoController = TextEditingController();

  final _demandanteController = TextEditingController();
  String? _demandanteNombre;

  final _demandadoController = TextEditingController();
  String? _demandadoNombre;

  final _abogadoDemandanteController = TextEditingController();
  String? _abogadoDemandanteNombre;

  final _abogadoDemandadoController = TextEditingController();
  String? _abogadoDemandadoNombre;

  final _juezController = TextEditingController();
  String? _juezNombre;

  late ExpedienteService api;

  @override
  void initState() {
    super.initState();
    api = context.read<ExpedienteProvider>().apiService;
  }

  Future<void> _buscarNombrePorCarnet(
    String carnet,
    Future<List<Map<String, dynamic>>> Function() fetchList,
    void Function(String) setter,
  ) async {
    final lista = await fetchList();
    final encontrado = lista.firstWhere(
      (e) => e['carnet_identidad'] == carnet,
      orElse: () => {},
    );
    if (encontrado.isNotEmpty) {
      setter('${encontrado['nombre']} ${encontrado['apellido']}');
    } else {
      setter('No encontrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final expedienteProvider = Provider.of<ExpedienteProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        elevation: 4,
        title: const Text('📝 Crear Expediente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Expediente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildCarnetField(
                label: 'Carnet del Demandante',
                controller: _demandanteController,
                nombre: _demandanteNombre,
                onBuscar:
                    (c) => _buscarNombrePorCarnet(
                      c,
                      api.getClientes,
                      (v) => setState(() => _demandanteNombre = v),
                    ),
              ),
              const SizedBox(height: 16),
              _buildCarnetField(
                label: 'Carnet del Demandado',
                controller: _demandadoController,
                nombre: _demandadoNombre,
                onBuscar:
                    (c) => _buscarNombrePorCarnet(
                      c,
                      api.getClientes,
                      (v) => setState(() => _demandadoNombre = v),
                    ),
              ),
              const SizedBox(height: 16),
              _buildCarnetField(
                label: 'Carnet Abogado Demandante',
                controller: _abogadoDemandanteController,
                nombre: _abogadoDemandanteNombre,
                onBuscar:
                    (c) => _buscarNombrePorCarnet(
                      c,
                      api.getAbogados,
                      (v) => setState(() => _abogadoDemandanteNombre = v),
                    ),
              ),
              const SizedBox(height: 16),
              _buildCarnetField(
                label: 'Carnet Abogado Demandado',
                controller: _abogadoDemandadoController,
                nombre: _abogadoDemandadoNombre,
                onBuscar:
                    (c) => _buscarNombrePorCarnet(
                      c,
                      api.getAbogados,
                      (v) => setState(() => _abogadoDemandadoNombre = v),
                    ),
              ),
              const SizedBox(height: 16),
              _buildCarnetField(
                label: 'Carnet del Juez',
                controller: _juezController,
                nombre: _juezNombre,
                onBuscar:
                    (c) => _buscarNombrePorCarnet(
                      c,
                      api.getJueces,
                      (v) => setState(() => _juezNombre = v),
                    ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _contenidoController,
                decoration: InputDecoration(
                  labelText: 'Contenido del expediente',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Este campo es requerido'
                            : null,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await expedienteProvider.crearExpediente({
                        'demandante_carnet': _demandanteController.text.trim(),
                        'demandado_carnet': _demandadoController.text.trim(),
                        'abogado_demandante_carnet':
                            _abogadoDemandanteController.text.trim(),
                        'abogado_demandado_carnet':
                            _abogadoDemandadoController.text.trim(),
                        'juez_carnet': _juezController.text.trim(),
                        'contenido': _contenidoController.text.trim(),
                      });
                      if (success && mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Guardar Expediente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarnetField({
    required String label,
    required TextEditingController controller,
    required String? nombre,
    required ValueChanged<String> onBuscar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            if (value.length >= 3) onBuscar(value);
          },
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Este campo es requerido'
                      : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Nombre encontrado',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          controller: TextEditingController(text: nombre ?? ''),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _contenidoController.dispose();
    _demandanteController.dispose();
    _demandadoController.dispose();
    _abogadoDemandanteController.dispose();
    _abogadoDemandadoController.dispose();
    _juezController.dispose();
    super.dispose();
  }
}
