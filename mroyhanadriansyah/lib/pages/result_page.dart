import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mroyhanadriansyah/helpers/food_helper.dart';

class ResultPage extends StatefulWidget {
  final String name;

  const ResultPage({super.key, required this.name});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final FoodHelper foodHelper = FoodHelper.instance;
  
  Future<dynamic> getDataFromAPI() async {
    final response = await http.get(Uri.parse("https://www.themealdb.com/api/json/v1/1/search.php?s=${widget.name}"));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'];
    } else {
      throw Exception('Terjadi kesalahan error!');
    }
  }
  
  void _handleButtonClick(BuildContext context, dynamic food) {
    foodHelper.insertData(food['strMeal'], food['strCategory'], food['strArea'], "${food['strMealThumb']}/preview");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Proses Berhasil!'),
          content: const Text('Data makanan berhasil disimpan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void redirectBack() {
      Navigator.pop(context, 'success');
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light
        )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Hasil Pencarian", style: TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: Colors.green,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              redirectBack();
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          )
        ),
        body: FutureBuilder(
          future: getDataFromAPI(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Text('Data makananan tidak ditemukan.', style: TextStyle(
                  color: Colors.red,
                )),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 20),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final food = snapshot.data![index];
                    return _cardFood(context, food);
                  }
                ),
              );
            }
          }
        ),
      ),
    );
  }

  Widget _cardFood(BuildContext context, dynamic food) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(food!['strMeal']),
          subtitle: Text('${food!['strCategory']}, ${food!['strArea']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () {
                _handleButtonClick(context, food);
              }, icon: const Icon(Icons.save, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}