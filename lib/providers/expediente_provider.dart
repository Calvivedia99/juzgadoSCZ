import 'package:flutter/material.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/services/expediente_service.dart';

class ExpedienteProvider with ChangeNotifier {
   final AuthProvider? _authProvider;
  final ExpedienteService _apiService = ExpedienteService();

  ExpedienteService get apiService => _apiService; // ← Agrega esta l
  List<Expediente> _expedientes = [];
  bool _isLoading = false;
  String? _error;
  Expediente? _expedienteSeleccionado;

  // Getters
  List<Expediente> get expedientes => _expedientes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Expediente? get expedienteSeleccionado => _expedienteSeleccionado;

  ExpedienteProvider(this._authProvider) {
    if (_authProvider?.user != null) {
      cargarExpedientes();
    }
  }

  Future<void> cargarExpedientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expedientes = await _apiService.getExpedientes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearExpediente(Map<String, dynamic> expedienteData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.crearExpediente(expedienteData);
      if (success) {
        await cargarExpedientes();
        return true;
      } else {
        _error = "No se pudo crear el expediente.";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarExpediente(
    int id,
    Map<String, dynamic> expedienteData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.actualizarExpediente(
        id,
        expedienteData,
      );
      if (success) {
        await cargarExpedientes();
        return true;
      } else {
        _error = "No se pudo actualizar el expediente.";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarExpediente(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.eliminarExpediente(id);
      if (success) {
        _expedientes.removeWhere((e) => e.numeroExpediente == id);
        notifyListeners();
        return true;
      } else {
        _error = "No se pudo eliminar el expediente.";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> obtenerDetallesExpediente(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final expediente = await _apiService.getExpedienteById(id);
      _expedienteSeleccionado = expediente;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Búsqueda simple por contenido o carnet involucrado
  List<Expediente> buscarExpedientes(String query) {
    final q = query.toLowerCase();
    return _expedientes
        .where(
          (e) =>
              e.contenido.toLowerCase().contains(q) ||
              e.demandanteCarnet.toLowerCase().contains(q) ||
              e.demandadoCarnet.toLowerCase().contains(q),
        )
        .toList();
  }
}
