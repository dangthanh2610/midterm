import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:productform/showcustomdelightbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  CollectionReference products =
      FirebaseFirestore.instance.collection('product');
    void _addProduct() {
  products.add({
    'Name': _nameController.text,
    'Category': _categoryController.text,
    'Price': _priceController.text,
  }).then((_) {
    // Show success toast
   showCustomDelightToastBar(context, "Thêm thành công sản phẩm !");
  }).catchError((error) {
    // Show error toast if there's an issue
    showCustomDelightToastBar(context, "Thêm sản phẩm thất bại !");
  });
  
  _nameController.clear();
  _categoryController.clear();
  _priceController.clear();
}

      void _deleteProduct(String productId) {
        products.doc(productId).delete();
      }

      void _editProduct(DocumentSnapshot product) {
        _nameController.text = product['Name'];
        _categoryController.text = product['Category'];
        _priceController.text = product['Price'];

        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text('Edit product'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                 const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: const Text('Cancel')),
              ElevatedButton(onPressed: () {
                _updateProduct(product.id);
              }, child: const Text('Update')),
            ],
          );
        });
      }                                                                                                                                                                                                     

      void _updateProduct(String productId) {
        products.doc(productId).update({
          'Name': _nameController.text,
          'Category': _categoryController.text,
          'Price': _priceController.text,
        }
        );
      }


 @override
Widget build(BuildContext context) {
  return Scaffold(  
    body: Stack(
      children: [
     ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), // Điều chỉnh giá trị sigma để tăng/giảm độ mờ
        child: Container(
          height: double.infinity,
          width: double.infinity,
         
        ),
      ),
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20,top: 20,left: 10, right: 10),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  height: 50,
                   child: const  Row(children: [Text("Danh Sách",style: const TextStyle(
                          fontSize: 30,
                          color: Colors.blue,
                          fontFamily: 'OpenSans',
                        ),),SizedBox(width: 8,),Text("Sản Phẩm",style: const TextStyle(
                          fontSize: 30,
                          color: Colors.blue,
                          fontFamily: 'OpenSans',
                        ),)],),
                 
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá sản phẩm'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addProduct,
                
                child:   Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 50,
                                decoration: BoxDecoration(
                                                              
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Center(
                                    child: Text(
                                  "Thêm sản phẩm",
                                  style: TextStyle(
                                  
                                      fontSize: 15,
                                      color: Colors.blue),
                                )),
                              ),
                            ),
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: products.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No products available.');
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var product = snapshot.data!.docs[index];
                      return Dismissible(
                        key: Key(product.id),
                        background: Container(
                          color: const Color.fromARGB(255, 207, 15, 15),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteProduct(product.id);
                        },
                        direction: DismissDirection.endToStart,
                        child: Container(
                    
                          decoration: BoxDecoration(  borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.black),
                            boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2),spreadRadius: 1,blurRadius: 2)], ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Tên sản phẩm : ${product['Name']}'),
                             
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Loại: ${product['Category']}'),
                                Text('Giá : ${product['Price']} VND'),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () => _editProduct(product),
                              icon: const Icon(Icons.edit),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ]
    ),
  );
  }
}

extension on Object {
  get docs => null;
}
