import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Öğrenci Yönetimi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OgrenciListesi(),
    );
  }
}

class OgrenciListesi extends StatefulWidget {
  const OgrenciListesi({super.key});

  @override
  State<OgrenciListesi> createState() => _OgrenciListesiState();
}

class _OgrenciListesiState extends State<OgrenciListesi> {
  List<dynamic> ogrenciler = [];
  bool isLoading = true;

  // Veri çekme (Read) işlemi
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/ogrenciler')); // Eğer gerçek cihaz kullanıyorsanız, IP adresini değiştirin
      print('API Yanıtı: ${response.body}'); // API'den gelen cevabı konsola yazdır
      if (response.statusCode == 200) {
        setState(() {
          ogrenciler = json.decode(response.body);
          print('Öğrenciler güncellendi: $ogrenciler'); // Güncellenen öğrenciler logu
          isLoading = false;
        });
      } else {
        throw Exception('Veri alınamadı, durum kodu: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Hata: $e');
    }
  }

  // Öğrenci ekleme (Create) işlemi
  Future<void> addOgrenci(String ad, String soyad, int bolumID) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/ogrenci'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ad': ad,
          'soyad': soyad,
          'bolumID': bolumID,
        }),
      );
      print('API Yanıtı: ${response.body}'); // API'den gelen cevabı kontrol et
      if (response.statusCode == 201) {
        print('Yeni öğrenci eklendi: $ad $soyad');
        fetchData(); // Yeni öğrenci eklendikten sonra listeyi güncelle
      } else {
        throw Exception('Öğrenci eklenemedi, durum kodu: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  // Öğrenci silme (Delete) işlemi
  Future<void> deleteOgrenci(int id) async {
    final response = await http.delete(Uri.parse('http://10.0.2.2:3000/ogrenci/$id'));

    print('API Yanıtı: ${response.body}'); // Silme yanıtını yazdır
    if (response.statusCode == 200) {
      print('Öğrenci silindi');
      fetchData(); // Listeyi güncelle
    } else {
      print('Silme işlemi başarısız: ${response.body}');
    }
  }

  // Öğrenci güncelleme (Update) işlemi
  Future<void> updateOgrenci(int id, String ad, String soyad, int bolumID) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/ogrenci/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ad': ad,
        'soyad': soyad,
        'bolumID': bolumID,
      }),
    );

    print('API Yanıtı: ${response.body}'); // Güncelleme yanıtını yazdır
    if (response.statusCode == 200) {
      print('Öğrenci güncellendi');
      fetchData(); // Listeyi güncelle
    } else {
      print('Güncelleme işlemi başarısız: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Listesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddOgrenciDialog(onAdd: addOgrenci);
                },
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ogrenciler.isEmpty
          ? const Center(child: Text('Hiç öğrenci yok'))
          : ListView.builder(
        itemCount: ogrenciler.length,
        itemBuilder: (context, index) {
          final ogrenci = ogrenciler[index];
          return ListTile(
            title: Text('${ogrenci['ad']} ${ogrenci['soyad']}'),
            subtitle: Text(
                'Öğrenci ID: ${ogrenci['ogrenciID']}, Bölüm ID: ${ogrenci['bolumID']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return UpdateOgrenciDialog(
                          ogrenci: ogrenci,
                          onUpdate: updateOgrenci,
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteOgrenci(ogrenci['ogrenciID']);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddOgrenciDialog extends StatefulWidget {
  final Function(String, String, int) onAdd;

  const AddOgrenciDialog({super.key, required this.onAdd});

  @override
  State<AddOgrenciDialog> createState() => _AddOgrenciDialogState();
}

class _AddOgrenciDialogState extends State<AddOgrenciDialog> {
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _bolumIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Öğrenci Ekle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _adController,
            decoration: const InputDecoration(labelText: 'Ad'),
          ),
          TextField(
            controller: _soyadController,
            decoration: const InputDecoration(labelText: 'Soyad'),
          ),
          TextField(
            controller: _bolumIDController,
            decoration: const InputDecoration(labelText: 'Bölüm ID'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onAdd(
              _adController.text,
              _soyadController.text,
              int.parse(_bolumIDController.text),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

class UpdateOgrenciDialog extends StatefulWidget {
  final dynamic ogrenci;
  final Function(int, String, String, int) onUpdate;

  const UpdateOgrenciDialog({super.key, required this.ogrenci, required this.onUpdate});

  @override
  State<UpdateOgrenciDialog> createState() => _UpdateOgrenciDialogState();
}

class _UpdateOgrenciDialogState extends State<UpdateOgrenciDialog> {
  late TextEditingController _adController;
  late TextEditingController _soyadController;
  late TextEditingController _bolumIDController;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(text: widget.ogrenci['ad']);
    _soyadController = TextEditingController(text: widget.ogrenci['soyad']);
    _bolumIDController = TextEditingController(text: widget.ogrenci['bolumID'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Öğrenci Güncelle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _adController,
            decoration: const InputDecoration(labelText: 'Ad'),
          ),
          TextField(
            controller: _soyadController,
            decoration: const InputDecoration(labelText: 'Soyad'),
          ),
          TextField(
            controller: _bolumIDController,
            decoration: const InputDecoration(labelText: 'Bölüm ID'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onUpdate(
              widget.ogrenci['ogrenciID'],
              _adController.text,
              _soyadController.text,
              int.parse(_bolumIDController.text),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Güncelle'),
        ),
      ],
    );
  }
}
