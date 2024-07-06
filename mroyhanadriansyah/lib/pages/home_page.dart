import 'package:flutter/material.dart';
import 'package:mroyhanadriansyah/helpers/food_helper.dart';
import 'package:mroyhanadriansyah/models/food.dart';
import 'package:mroyhanadriansyah/pages/result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchNameController = TextEditingController();
  final FoodHelper foodHelper = FoodHelper.instance;
  late Future<List<Food>> _foods;

  @override
  void initState() {
    super.initState();
    _fetchDatabase();
  }

  void _fetchDatabase() {
    setState(() {
      _foods = foodHelper.getAll();
    });
  }

  void openDialog() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const Text('Cari makanan', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  )),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'ex. Seafood.',
                    ),
                    controller: searchNameController,
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                      
                     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ResultPage(name: searchNameController.text);
                      }));
                      
                      if (result == 'success') {
                        searchNameController.clear();
                        _fetchDatabase();
                      } 
                    }, 
                    style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.green),
                      foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
                    ),
                    child: const Text('Cari makanan')
                  )
                ],
              ),
            ),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Makanan', style: TextStyle(
          fontSize: 18,
        )),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Food>>(
        future: _foods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Text('Data makanan belum tersedia!', style: TextStyle(
                color: Colors.green,
              )),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 20),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Food food = snapshot.data![index];
                  return _cardFood(food);
                }
              ),
            );
          }
        }
      ),
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          onPressed: () {
            openDialog();
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.search, color: Colors.white),
        ),
      ),
    );
  }

  Widget _cardFood(Food food) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(food.name),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${food.category}, ${food.country}'),
              Image.network(food.image, width: 100)
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () {
                foodHelper.deleteData(food.id);
                _fetchDatabase();
              }, icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}