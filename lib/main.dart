import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    theme: ThemeData(
      primaryColor: Colors.purple,
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    if (_scanBarcode.isNotEmpty) {
      String name = '';
      double price = 0.0;
      int quantity = 0;
      int shelfLife = 4;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Restock Item'),
          content: Form(
            key: GlobalKey(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Product')
                      .doc(_scanBarcode)
                      .get(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data.data();
                      final name = data['name'] ?? '';
                      final price = data['price'] ?? 0.0;
                      final shelfLife = data['shelfLife'] ?? 0.0;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Product: ',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Price: RM',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                price.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Shelf Life: ',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                shelfLife.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => quantity = int.parse(value),
                          ),
                        ],
                      );
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await storeBarcode(name, price, shelfLife, quantity);
              },
              child: Text(
                'Restock',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> scanBarcodeSell() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    if (_scanBarcode.isNotEmpty) {
      final currentContext = context;

      await showDialog(
        context: currentContext,
        builder: (context) => AlertDialog(
          title: Text('Delete Item from Inventory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Do you want to deduct one item from the inventory?',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'No',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await FirebaseFirestore.instance
                    .collection('Product')
                    .doc(_scanBarcode)
                    .update({'quantity': FieldValue.increment(-1)});

                final updatedQuantitySnapshot = await FirebaseFirestore.instance
                    .collection('Product')
                    .doc(_scanBarcode)
                    .get();

                final updatedQuantity =
                    updatedQuantitySnapshot.data()?['quantity'];

                if (updatedQuantity != null) {
                  showDialog(
                    context: currentContext,
                    builder: (context) => AlertDialog(
                      title: Text('Item Quantity'),
                      content: Text('Updated quantity: $updatedQuantity'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: currentContext,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to retrieve the updated quantity.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> storeBarcode(
      String name, double price, int shelfLife, int quantity) async {
    CollectionReference products =
        FirebaseFirestore.instance.collection('Product');

    DocumentReference product = products.doc(_scanBarcode);

    await product.set(
      {
        'quantity': quantity,
      },
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Smart Stock'),
          ),
          body: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple, Colors.deepPurple],
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: Duration(seconds: 1),
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/SmartStock.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      AnimatedOpacity(
                        duration: Duration(seconds: 1),
                        opacity: _scanBarcode.isEmpty ? 0 : 1,
                        child: Text(
                          'Scan result: $_scanBarcode',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => scanBarcode(),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 100, 147, 46),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text('Restock'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => scanBarcodeSell(),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 44, 143, 189),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text('Sell Product'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
