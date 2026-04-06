import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Manager',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('items');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['Item'];
      _priceController.text = documentSnapshot['Price'].toString();
      _quantityController.text = documentSnapshot['Quantity'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20, left: 20, right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item'),
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
               TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(action == 'create' ? 'Create' : 'Update'),
                onPressed: () async {
                  String name = _nameController.text;
                  double price = double.parse(_priceController.text);
                  if (name.isNotEmpty) {
                    if (action == 'create') {
                      await _products.add({"name": name, "price": price});
                    }
                    if (action == 'update') {
                      await _products.doc(documentSnapshot!.id).update({
                        "name": name, "price": price,
                      });
                    }
                    _nameController.text = '';
                    _priceController.text = '';
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  // TODO: Complete this function!
  Future<void> _deleteItem(String itemId) async {
    // Your code here
    String action = 'delete';
    
    ElevatedButton(
                child: Text(action == 'create' ? 'Create' : 'Update'),
                onPressed: () async {
                  String name = _nameController.text;
                  double price = double.parse(_priceController.text);
                  if (name.isNotEmpty) {
                    if (action == 'delete') {
                      await _products.doc(itemId).delete();
                    }
                    _nameController.text = '';
                    _priceController.text = '';
                    Navigator.of(context).pop();
                  }
                },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have successfully deleted a product')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Operations')),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['price'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _createOrUpdate(documentSnapshot),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteItem(documentSnapshot.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}