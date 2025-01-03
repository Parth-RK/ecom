import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState {
  final ProductStatus status;
  final List<Product> products;
  final String error;
  final bool isLoadingMore;
  final int currentPage;

  ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.error = '',
    this.isLoadingMore = false,
    this.currentPage = 1,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? error,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      error: error ?? this.error,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ProductBloc extends Cubit<ProductState> {
  ProductBloc() : super(ProductState());
  
  static const int _itemsPerPage = 10;
  
  Future<void> fetchProducts() async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await _fetchProductsFromApi(1);
      emit(state.copyWith(
        status: ProductStatus.success,
        products: products,
        currentPage: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadMoreProducts() async {
    if (state.isLoadingMore) return;
    
    try {
      emit(state.copyWith(isLoadingMore: true));
      final nextPage = state.currentPage + 1;
      final newProducts = await _fetchProductsFromApi(nextPage);
      
      if (newProducts.isEmpty) {
        emit(state.copyWith(isLoadingMore: false));
        return;
      }

      emit(state.copyWith(
        products: [...state.products, ...newProducts],
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      ));
    }
  }

  Future<List<Product>> _fetchProductsFromApi(int page) async {
    final response = await http.get(
      Uri.parse('https://fakestoreapi.com/products?limit=$_itemsPerPage&skip=${(page - 1) * _itemsPerPage}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
