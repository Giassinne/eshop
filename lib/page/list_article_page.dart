import 'dart:convert';

import 'package:eshop/main.dart';
import 'package:eshop/page/cart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../article.dart';

class ListeArticlePage extends StatelessWidget {
  ListeArticlePage({super.key});

  final article = Article(
    "Sac a dos",
    "Cette version de la sneaker LV Trainer associe du denim Denim au cuir de veau lisse, "
        "un mélange de matières qui souligne la construction élaborée de la ligne nécessitant sept heures d’assemblage.",
    1080.0,
    "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
    "Wearable",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('EPSI Shop'),
          actions: [
            IconButton(
              onPressed: () => context.go("/cart"),
              icon: Badge(
                label:
                Text(context.watch<Cart>().getAll().length.toString()),
                child: const Icon(Icons.shopping_cart),
              ),
            )
          ],
        ),
        body: FutureBuilder<List<Article>>(
            future: fetchListArticle(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null)
                return ListArticles( listArticle: snapshot.data!,);
              else if (snapshot.hasError)
                return Text(snapshot.error.toString());
              else
                return CircularProgressIndicator();
            }
        ));
  }
}

class ListArticles extends StatelessWidget {
  final List<Article> listArticle;
  const ListArticles({
    super.key,
    required this.listArticle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listArticle.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () => context.go('/detail', extra: listArticle[index]),
        leading: Image.network(
          listArticle[index].image,
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        ),
        title: Text(listArticle[index].nom),
      ),
    );
  }
}


Future<List<Article>> fetchListArticle() async {

  final res = await get(Uri.parse("https://fakestoreapi.com/products"));

  if (res.statusCode == 200) {

    print("réponse ${res.body}");
    final listMapArticles = jsonDecode(res.body) as List<dynamic>;
    return listMapArticles
        .map((map) => Article(
      map["title"],
      map["description"],
      map["price"],
      map["image"],
      map["category"],
    ))
        .toList();
  } else {

    throw Exception('Chargement des articles, code: ${res.statusCode}');
  }
}
