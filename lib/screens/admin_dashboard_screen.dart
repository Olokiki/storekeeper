import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'edit_product_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = ApiService.getAllProducts();
    });
  }

  void _deleteProduct(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ApiService.deleteProduct(id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
                _loadProducts();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error deleting product')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('No products found'),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Unit')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Actions')),
              ],
              rows: products
                  .map(
                    (product) => DataRow(
                  cells: [
                    DataCell(Text(product.id.toString())),
                    DataCell(Text(product.name)),
                    DataCell(Text(product.quantity.toString())),
                    // <CHANGE> Display unit
                    DataCell(Text(product.unit ?? 'units')),
                    // <CHANGE> Display Naira currency
                    DataCell(Text('₦${product.price.toStringAsFixed(2)}')),
                    DataCell(
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProductScreen(product: product),
                                ),
                              );
                              if (result == true) {
                                _loadProducts();
                              }
                            },
                            child: const Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _deleteProduct(product.id!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadProducts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}