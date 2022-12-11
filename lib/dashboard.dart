// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'sql_helper.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> _datas = [];

  bool _loading = true;
  void _perbaruiData() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _datas = data;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _perbaruiData();
  }

  final TextEditingController _bukuController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  void _munculData(int? id) async {
    if (id != null) {
      final existingJournal =
          _datas.firstWhere((element) => element['id'] == id);
      _bukuController.text = existingJournal['buku'];
      _keteranganController.text = existingJournal['keterangan'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _bukuController,
              decoration: const InputDecoration(hintText: 'Masukan nama buku'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _keteranganController,
              decoration: const InputDecoration(hintText: 'Masukan keterangan'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _tambahItem();
                }
                if (id != null) {
                  await _updateItem(id);
                }
                _bukuController.text = '';
                _keteranganController.text = '';
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Tambah' : 'Edit'),
            )
          ],
        ),
      ),
    );
  }

// Menambahkan data
  Future<void> _tambahItem() async {
    await SQLHelper.createItem(
        _bukuController.text, _keteranganController.text);
    _perbaruiData();
  }

  // Mengupdate data
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _bukuController.text, _keteranganController.text);
    _perbaruiData();
  }

  // Menghapus data
  void _hapusItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data berhasil di hapus'),
    ));
    _perbaruiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perpustakaan'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _datas.length,
              itemBuilder: (context, index) => Card(
                color: Colors.green[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_datas[index]['buku']),
                    subtitle: Text(_datas[index]['keterangan']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _munculData(_datas[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _hapusItem(_datas[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _munculData(null),
        tooltip: 'Masuk',
        label: const Text('Tambah'),
        backgroundColor: Colors.blueGrey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
