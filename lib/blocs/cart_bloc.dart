import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartState {
  final List<CartItem> items;
  
  CartState({this.items = const []});

  double get totalAmount => 
      items.fold(0, (sum, item) => sum + item.total);

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);
}

class CartBloc extends Cubit<CartState> {
  CartBloc() : super(CartState());

  void addToCart(Product product) {
    final currentState = state;
    final currentItems = List<CartItem>.from(currentState.items);
    
    final existingIndex = currentItems.indexWhere(
      (item) => item.product.id == product.id
    );

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity += 1;
    } else {
      currentItems.add(CartItem(product: product));
    }

    emit(CartState(items: currentItems));
  }

  void removeFromCart(Product product) {
    final currentItems = List<CartItem>.from(state.items);
    currentItems.removeWhere((item) => item.product.id == product.id);
    emit(CartState(items: currentItems));
  }

  void updateQuantity(Product product, int quantity) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == product.id
    );
    
    if (index >= 0) {
      if (quantity <= 0) {
        currentItems.removeAt(index);
      } else {
        currentItems[index].quantity = quantity;
      }
      emit(CartState(items: currentItems));
    }
  }
}
