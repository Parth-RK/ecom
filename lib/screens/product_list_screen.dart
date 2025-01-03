import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product_bloc.dart';
import 'product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<ProductBloc>().loadMoreProducts();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to calculate grid properties
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate number of columns based on screen width
    int crossAxisCount;
    double childAspectRatio;
    double padding;
    
    if (screenWidth > 1200) {
      crossAxisCount = 6;
      childAspectRatio = 0.8;
      padding = 16;
    } else if (screenWidth > 900) {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
      padding = 12;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.7;
      padding = 8;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.65;
      padding = 8;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Now'),
        actions: [
          // IconButton(icon: Icon(Icons.search), onPressed: () {}),
          // IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductStatus.loading:
              return Center(child: CircularProgressIndicator());
              
            case ProductStatus.success:
              return GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: padding,
                  mainAxisSpacing: padding,
                ),
                itemCount: state.products.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.products.length) {
                    return Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final product = state.products[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3, // Adjust image container size ratio
                            child: Stack(
                              children: [
                                Hero(
                                  tag: 'product-${product.id}',
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(8),
                                    child: Image.network(
                                      product.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: IconButton(
                                    icon: Icon(
                                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Toggle favorite
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2, // Adjust content container size ratio
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: screenWidth > 600 ? 14 : 12,
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${product.rating}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth > 600 ? 12 : 10,
                                              ),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: screenWidth > 600 ? 12 : 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '(${product.reviewCount})',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: screenWidth > 600 ? 12 : 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '₹${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: screenWidth > 600 ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              
            case ProductStatus.failure:
              return Center(child: Text(state.error));
              
            default:
              return Center(child: Text('Please fetch products'));
          }
        },
      ),
    );
  }
}
