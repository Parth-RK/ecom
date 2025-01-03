import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState {
  final ProductStatus status;
  final List<Product> products;
  final String error;

  ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.error = '',
  });
}

class ProductBloc extends Cubit<ProductState> {
  ProductBloc() : super(ProductState());

  Future<void> fetchProducts() async {
    emit(ProductState(status: ProductStatus.loading));
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final products = json.map((product) => Product.fromJson(product)).toList();
        emit(ProductState(status: ProductStatus.success, products: products));
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      emit(ProductState(status: ProductStatus.failure, error: e.toString()));
    }
  }
}
