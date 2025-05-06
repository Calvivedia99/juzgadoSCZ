import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:si2/models/expediente_model.dart';

class ExpedienteService {
  final String baseUrl =
      'http://172.20.171.43:3001/api'; // Ajusta IP a tu red local
  final storage = const FlutterSecureStorage();

  // Obtener todos los expedientes (Admin o asistente)
  Future<List<Expediente>> getExpedientes() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('$baseUrl/expedientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Expediente.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener expedientes: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getExpedientes: $e');
      rethrow;
    }
  }

  // Obtener expediente por ID
  Future<Expediente> getExpedienteById(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Expediente.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener expediente: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error en getExpedienteById: $e');
      rethrow;
    }
  }

  // Crear expediente
  Future<bool> crearExpediente(Map<String, dynamic> data) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.post(
        Uri.parse('$baseUrl/expedientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('Error en crearExpediente: $e');
      return false;
    }
  }

  // Actualizar expediente
  Future<bool> actualizarExpediente(int id, Map<String, dynamic> data) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.put(
        Uri.parse('$baseUrl/expedientes/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error en actualizarExpediente: $e');
      return false;
    }
  }

  // Eliminar expediente
  Future<bool> eliminarExpediente(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.delete(
        Uri.parse('$baseUrl/expedientes/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error en eliminarExpediente: $e');
      return false;
    }
  }

  // Obtener expedientes por abogado
  Future<List<Expediente>> getExpedientesPorAbogado(String carnet) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/abogado/$carnet'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Expediente.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error en getExpedientesPorAbogado: $e');
      return [];
    }
  }

  // Obtener expedientes por juez
  Future<List<Expediente>> getExpedientesPorJuez(String carnet) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('$baseUrl/expedientes/juez/$carnet'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Expediente.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error en getExpedientesPorJuez: $e');
      return [];
    }
  }

  // Obtener listas auxiliares
  Future<List<Map<String, dynamic>>> getClientes() async {
    return _getLista('$baseUrl/clientes');
  }

  Future<List<Map<String, dynamic>>> getAbogados() async {
    return _getLista('$baseUrl/abogados');
  }

  Future<List<Map<String, dynamic>>> getJueces() async {
    return _getLista('$baseUrl/jueces');
  }

  // Auxiliar para listas
  Future<List<Map<String, dynamic>>> _getLista(String url) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error en _getLista: $e');
      return [];
    }
  }
}
