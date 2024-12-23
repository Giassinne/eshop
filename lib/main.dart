import 'package:eshop/page/cart.dart';
import 'package:eshop/page/detail_article_page.dart';
import 'package:eshop/page/list_article_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'article.dart';
import 'page/cart_page.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  final router = GoRouter(routes: [
    GoRoute(path: "/",
        builder: (ctx, state) => ListeArticlePage(),
        routes: [
          GoRoute(
              path: "detail",
              builder: (ctx, state) =>
                  DetailArticlePage(article: state.extra as Article)
          ),
          GoRoute(
            path: '/cart',
            builder: (ctx, state) => const CartPage(),
          ),
        ]
    )
  ]);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Cart(),
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
      ),
    );
  }
}