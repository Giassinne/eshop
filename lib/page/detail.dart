import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Shop',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const ShopPage(),
    );
  }
}

class Product {
  final String name;
  final String imageUrl;
  final double price;

  Product({required this.name, required this.imageUrl, required this.price});
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final List<Product> _products = [
    Product(name: "T-shirt", imageUrl: "assets/images/img.png", price: 20.0),
    Product(name: "Sneakers", imageUrl: "assets/images/img_2.png", price: 50.0),
    Product(name: "Backpack", imageUrl: "assets/images/img_3.png", price: 30.0),
    Product(name: "Jeans", imageUrl: "assets/images/img_1.png", price: 40.0),
  ];

  final List<Product> _cart = [];

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ajouté au panier !')),
    );
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage(cart: _cart)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCart,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(product.imageUrl, height: 210, fit: BoxFit.cover),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text("\$${product.price}", style: const TextStyle(color: Colors.green)),
                ElevatedButton(
                  onPressed: () => _addToCart(product),
                  child: const Text("Ajouter au panier"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<Product> cart;

  const CartPage({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    double totalPrice = cart.fold(0, (sum, product) => sum + product.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
      ),
      body: cart.isEmpty
          ? const Center(
        child: Text("Votre panier est vide."),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final product = cart[index];
                return ListTile(
                  leading: Image.network(product.imageUrl, width: 50),
                  title: Text(product.name),
                  subtitle: Text("\$${product.price}"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Total : \$${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Commande passée avec succès !")),
              );
            },
            child: const Text("Passer la commande"),
          ),
        ],
      ),
    );
  }
}
