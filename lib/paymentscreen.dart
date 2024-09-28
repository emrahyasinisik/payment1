import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late final Future<PaymentConfiguration> _googlePayConfigFuture;

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var item in demoItems) {
      totalPrice += item['price'] * item['numOfItem'];
    }
    return totalPrice;
  }

  @override
  void initState() {
    super.initState();
    _googlePayConfigFuture =
        PaymentConfiguration.fromAsset('json/google_pay_config.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Your Orders"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              ...List.generate(
                demoItems.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: OrderedItemCard(
                    title: demoItems[index]["title"],
                    description:
                        "Shortbread, chocolate turtle cookies, and red velvet.",
                    numOfItem: demoItems[index]["numOfItem"],
                    price: demoItems[index]["price"].toDouble(),
                  ),
                ),
              ),
              PriceRow(text: "Subtotal", price: calculateTotalPrice()),
              const SizedBox(height: 8),
              const PriceRow(text: "Delivery", price: 0),
              TotalPrice(price: calculateTotalPrice()),
              const SizedBox(height: 32),
              FutureBuilder<PaymentConfiguration>(
                future: _googlePayConfigFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return GooglePayButton(
                      paymentConfiguration: snapshot.data!,
                      paymentItems: [
                        PaymentItem(
                          label: 'Total',
                          amount: calculateTotalPrice().toStringAsFixed(2),
                          status: PaymentItemStatus.final_price,
                        ),
                      ],
                      onPaymentResult: (paymentResult) {
                        print('Payment Result: $paymentResult');
                      },
                    );
                  } else {
                    return const Text('Unknown error occurred.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TotalPrice extends StatelessWidget {
  const TotalPrice({
    super.key,
    required this.price,
  });

  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text.rich(
          TextSpan(
            text: "Total ",
            style: TextStyle(
                color: Color(0xFF22A45D), fontWeight: FontWeight.w500),
            children: [
              TextSpan(
                text: "(incl. VAT)",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        Text(
          "\$$price",
          style: const TextStyle(
              color: Color(0xFF22A45D), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.text,
    required this.price,
  });

  final String text;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        Text(
          "\$$price",
          style: const TextStyle(color: Color(0xFF010F07)),
        )
      ],
    );
  }
}

class OrderedItemCard extends StatelessWidget {
  const OrderedItemCard({
    super.key,
    required this.numOfItem,
    required this.title,
    required this.description,
    required this.price,
  });
  final int numOfItem;
  final String? title, description;
  final double? price;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumOfItems(numOfItem: numOfItem),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "USD$price",
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: const Color(0xFF22A45D)),
            )
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}

class NumOfItems extends StatelessWidget {
  const NumOfItems({
    super.key,
    required this.numOfItem,
  });

  final int numOfItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
            width: 0.5, color: const Color(0xFF868686).withOpacity(0.3)),
      ),
      child: Text(
        numOfItem.toString(),
        style: Theme.of(context)
            .textTheme
            .labelLarge!
            .copyWith(color: const Color(0xFF22A45D)),
      ),
    );
  }
}

const List<Map> demoItems = [
  {
    "title": "Kadın bluz",
    "price": 10,
    "numOfItem": 1,
  },
  {
    "title": "Erkek Pantolon",
    "price": 10,
    "numOfItem": 1,
  },
  {
    "title": "Oyster Dish",
    "price": 10,
    "numOfItem": 1,
  },
  {
    "title": "Erkek Gömlek",
    "price": 10,
    "numOfItem": 1,
  },
];
