import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/providers/expediente_provider.dart';

class ExpedienteIndexScreen extends StatelessWidget {
  const ExpedienteIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expedienteProvider = Provider.of<ExpedienteProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.red[800],
        title: const Text(
          '📚 Expedientes Judiciales',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 26),
            onPressed: () => expedienteProvider.cargarExpedientes(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () => Navigator.pushNamed(context, '/expedientes/crear'),
          ),
        ],
      ),
      body:
          expedienteProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : expedienteProvider.expedientes.isEmpty
              ? const Center(
                child: Text(
                  'No hay expedientes registrados. 😕',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: expedienteProvider.expedientes.length,
                itemBuilder: (context, index) {
                  final expediente = expedienteProvider.expedientes[index];
                  return Dismissible(
                    key: Key(expediente.numeroExpediente.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('¿Eliminar expediente?'),
                              content: Text(
                                '¿Deseas eliminar permanentemente el expediente #${expediente.numeroExpediente}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (_) async {
                      await expedienteProvider.eliminarExpediente(
                        expediente.numeroExpediente!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Expediente #${expediente.numeroExpediente} eliminado',
                          ),
                          backgroundColor: Colors.red[700],
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: _buildExpedienteCard(context, expediente),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/expedientes/crear'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        backgroundColor: Colors.red[800],
      ),
    );
  }

  Widget _buildExpedienteCard(BuildContext context, Expediente expediente) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            () => Navigator.pushNamed(
              context,
              '/expedientes/editar',
              arguments: expediente.numeroExpediente,
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red[800],
                    child: Text(
                      expediente.numeroExpediente?.toString() ?? '-',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Expediente #${expediente.numeroExpediente ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.edit, color: Colors.grey),
                  //   onPressed: () {
                  //     Navigator.pushNamed(
                  //       context,
                  //       '/expedientes/editar',
                  //       arguments: expediente.numeroExpediente,
                  //     );
                  //   },
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                expediente.contenido,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: -8,
                children: [
                  _buildBadge(
                    'Demandante: ${expediente.demandanteNombre ?? expediente.demandanteCarnet}',
                    Colors.teal,
                  ),
                  _buildBadge(
                    'Demandado: ${expediente.demandadoNombre ?? expediente.demandadoCarnet}',
                    Colors.indigo,
                  ),
                  _buildBadge(
                    'Juez: ${expediente.juezNombre ?? expediente.juezCarnet}',
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
