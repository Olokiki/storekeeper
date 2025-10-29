import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000/api";

  // CREATE - Add product to backend

  static Future<Product?> createProduct({
    required String name,
    required int quantity,
    required double price,
    String? unit,
    String? imagePath,
  }) async {
    try {
      print('[v0] Creating product: $name');
      print('[v0] API URL: $baseUrl/products');

      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'quantity': quantity,
          'unit': unit ?? 'units',
          'price': price,
          'imagePath': imagePath,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Backend not responding');
        },
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 201) {
        return Product.fromMap(jsonDecode(response.body));
      } else {
        print('[v0] Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create product: ${response.body}');
      }
    } catch (e) {
      print('[v0] Exception: $e');
      rethrow;
    }
  }

  // READ - Get all products from backend
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromMap(json)).toList();
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // UPDATE - Edit product on backend
  static Future<Product?> updateProduct({
    required int id,
    required String name,
    required int quantity,
    required double price,
    String? unit,
    String? imagePath,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'quantity': quantity,
          'unit': unit ?? 'units',
          'price': price,
          'imagePath': imagePath,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        return Product.fromMap(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print('[v0] Update error: $e');
      rethrow;
    }
  }

  // DELETE - Remove product from backend
  static Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
}