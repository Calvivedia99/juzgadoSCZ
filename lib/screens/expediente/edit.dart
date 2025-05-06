import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/services/expediente_service.dart';

class ExpedienteEditScreen extends StatefulWidget {
  const ExpedienteEditScreen({super.key});

  @override
  State<ExpedienteEditScreen> createState() => _ExpedienteEditScreenState();
}

class _ExpedienteEditScreenState extends State<ExpedienteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contenidoController = TextEditingController();
  final _demandanteController = TextEditingController();
  final _demandadoController = TextEditingController();
  final _abogadoDemandanteController = TextEditingController();
  final _abogadoDemandadoController = TextEditingController();
  final _juezController = TextEditingController();

  String? _demandanteNombre;
  String? _demandadoNombre;
  String? _abogadoDemandanteNombre;
  String? _abogadoDemandadoNombre;
  String? _juezNombre;

  ExpedienteService? _api;
  int? expedienteId;
  bool _datosCargados = false;

  @override
  void initState() {
    super.initState();
    _api = ExpedienteService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_datosCargados) {
      expedienteId = ModalRoute.of(context)!.settings.arguments as int?;
      if (expedienteId != null) {
        final provider = Provider.of<ExpedienteProvider>(context, listen: false);
        provider.obtenerDetallesExpediente(expedienteId!).then((_) async {
          final exp = provider.expedienteSeleccionado;
          if (exp != null) {
            _contenidoController.text = exp.contenido;
            _demandanteController.text = exp.demandanteCarnet;
            _demandadoController.text = exp.demandadoCarnet;
            _abogadoDemandanteController.text = exp.abogadoDemandanteCarnet;
            _abogadoDemandadoController.text = exp.abogadoDemandadoCarnet;
            _juezController.text = exp.juezCarnet;

            await _buscarNombre(exp.demandanteCarnet, 'demandante');
            await _buscarNombre(exp.demandadoCarnet, 'demandado');
            await _buscarNombre(exp.abogadoDemandanteCarnet, 'abogado_demandante');
            await _buscarNombre(exp.abogadoDemandadoCarnet, 'abogado_demandado');
            await _buscarNombre(exp.juezCarnet, 'juez');

            setState(() {
              _datosCargados = true;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expediente no encontrado.'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
          }
        });
      }
    }
  }

  Future<void> _buscarNombre(String carnet, String tipo) async {
    final lista = tipo == 'juez'
        ? await _api!.getJueces()
        : tipo.contains('abogado')
            ? await _api!.getAbogados()
            : await _api!.getClientes();
    final persona = lista.firstWhere(
      (e) => e['carnet_identidad'] == carnet,
      orElse: () => {},
    );
    if (mounted) {
      setState(() {
        final nombre = persona.isNotEmpty ? '${persona['nombre']} ${persona['apellido']}' : null;
        switch (tipo) {
          case 'demandante':
            _demandanteNombre = nombre;
            break;
          case 'demandado':
            _demandadoNombre = nombre;
            break;
          case 'abogado_demandante':
            _abogadoDemandanteNombre = nombre;
            break;
          case 'abogado_demandado':
            _abogadoDemandadoNombre = nombre;
            break;
          case 'juez':
            _juezNombre = nombre;
            break;
        }
      });
    }
  }

  Widget _buildCarnetNombreField({
    required String label,
    required TextEditingController controller,
    required String tipo,
    String? nombre,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Carnet del $label',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            if (value.trim().length >= 3) {
              _buscarNombre(value.trim(), tipo);
            }
          },
          validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            nombre ?? 'Desconocido',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final expedienteProvider = Provider.of<ExpedienteProvider>(context);
    final esEdicion = expedienteId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        elevation: 4,
        title: Text(esEdicion ? '✏️ Editar Expediente' : '📝 Crear Expediente'),
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
              _buildCarnetNombreField(
                label: 'Demandante',
                controller: _demandanteController,
                tipo: 'demandante',
                nombre: _demandanteNombre,
              ),
              const SizedBox(height: 16),
              _buildCarnetNombreField(
                label: 'Demandado',
                controller: _demandadoController,
                tipo: 'demandado',
                nombre: _demandadoNombre,
              ),
              const SizedBox(height: 16),
              _buildCarnetNombreField(
                label: 'Abogado Demandante',
                controller: _abogadoDemandanteController,
                tipo: 'abogado_demandante',
                nombre: _abogadoDemandanteNombre,
              ),
              const SizedBox(height: 16),
              _buildCarnetNombreField(
                label: 'Abogado Demandado',
                controller: _abogadoDemandadoController,
                tipo: 'abogado_demandado',
                nombre: _abogadoDemandadoNombre,
              ),
              const SizedBox(height: 16),
              _buildCarnetNombreField(
                label: 'Juez Asignado',
                controller: _juezController,
                tipo: 'juez',
                nombre: _juezNombre,
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
                validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        'demandante_carnet': _demandanteController.text.trim(),
                        'demandado_carnet': _demandadoController.text.trim(),
                        'abogado_demandante_carnet': _abogadoDemandanteController.text.trim(),
                        'abogado_demandado_carnet': _abogadoDemandadoController.text.trim(),
                        'juez_carnet': _juezController.text.trim(),
                        'contenido': _contenidoController.text.trim(),
                      };
                      final success = esEdicion
                          ? await expedienteProvider.actualizarExpediente(expedienteId!, data)
                          : await expedienteProvider.crearExpediente(data);
                      if (success && mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  icon: const Icon(Icons.save_alt),
                  label: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
