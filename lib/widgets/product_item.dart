import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: true);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                try {
                  await product.toggleFavoriteStatus(
                      Provider.of<Auth>(context, listen: false).token,
                      Provider.of<Auth>(context, listen: false).userId);
                } catch (error) {
                  showDialog(
                      context: context,
                      builder: (con) => AlertDialog(
                            title: Text('Oops! Error'),
                            content: Text(error.toString()),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Okay'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ));
                }
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              if (product.quantity <= 0) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Invalid transaction'),
                    content: Text('No more items to be sold!'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Roger that'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      )
                    ],
                  ),
                );
                return;
              }
              product.itemOrdered();
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added item to cart!',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            color: product.quantity <= 0
                ? Colors.white54
                : Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
