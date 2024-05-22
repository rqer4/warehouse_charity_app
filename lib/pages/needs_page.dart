import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:synny_space/items_list/items_list.dart';
import 'package:synny_space/screens/find_by_code.dart';
import 'package:synny_space/widgets/item_adding.dart';
import 'package:synny_space/model/storage_card.dart';

class NeedsPage extends StatefulWidget {
  const NeedsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NeedsPageState();
  }
}

class _NeedsPageState extends State<NeedsPage> {
  List<StorageCard> _registeredItems = [];

  @override
  initState() {
    super.initState();
    _loadItems();
  }
  
  void _loadItems() async {
    final url = Uri.https(
        'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
        'item-list.json');
    final response = await http.get(url);
    if (json.decode(response.body) == null) {
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<StorageCard> loadedItems = [];

    for (final item in listData.entries) {
      final cathegoryList = List.of(Cathegory.values);

      final measureUnitsList = List.of(MeasureUnit.values);

      Cathegory cathegory = Cathegory.amunition;
      MeasureUnit measureUnit = MeasureUnit.pcs;

      for (final cat in cathegoryList) {
        if (cat.name.toString() == item.value['cathegory']) {
          cathegory = cat;
          break;
        }
      }
      for (final unit in measureUnitsList) {
        if (unit.name.toString() == item.value['measureUnit']) {
          measureUnit = unit;
          break;
        }
      }

      loadedItems.add(
        StorageCard(
            id: item.key,
            barcode: int.parse(item.value['barcode']),
            image: item.value['image'],
            quantity: item.value['quantity'],
            title: item.value['title'],
            cathegory: cathegory,
            measureVolume: item.value['measureVolume'],
            measureUnit: measureUnit),
      );
    }

    setState(() {
      _registeredItems = loadedItems;
    });
  }

  void _onRemoveItem(StorageCard itemCard) async {
    final itemIndex = _registeredItems.indexOf(itemCard);
    setState(() {
      _registeredItems.removeAt(itemIndex);
    });
    final url = Uri.https(
      'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
      'item-list/${itemCard.id}.json',
    );
    //FirebaseStorage.instance.ref('Item-images').child(itemCard.image).delete();
    final response = await http.delete(url);
    FirebaseStorage.instance.refFromURL(itemCard.image).delete();
    if (response.statusCode >= 400) {
      setState(() {
        _registeredItems.insert(itemIndex, itemCard);
      });
    }
  }

  void _addItemToList(StorageCard item) {
    setState(() {
      _registeredItems.add(item);
    });
  }

  void _openAddItemWindow() async {
    final newItem = await Navigator.of(context).push<StorageCard>(
      MaterialPageRoute(
        builder: (ctx) => const ItemAdding(),
      ),
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _addItemToList(newItem);
    });
  }

  void _openFindItemWindow() async{

    String scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    final newItem = await Navigator.of(context).push<StorageCard>(
      MaterialPageRoute(
        builder: (ctx) =>  FindByCode(listOfItems:_registeredItems, scannedBarcode: int.parse(scannedBarcode),),
      ),
    );
    if (newItem == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    //Widget mainContent = const Text('No items found. Try to add some!');

    //if (_registeredItems.isNotEmpty) {
    Widget mainContent = ItemsList(
      itemsList: _registeredItems,
      removeItem: _onRemoveItem,
    );
    //}

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(tabs: [
                Tab(
                  text: 'Storage',
                ),
                Tab(
                  text: 'Needs',
                )
              ])
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(child: mainContent),
                Row(
                  children: [
                    const Spacer(),
                    SubmenuButton(
                      style: SubmenuButton.styleFrom(
                          iconColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: const CircleBorder()),
                      menuChildren: [
                        TextButton(
                          onPressed: _openFindItemWindow,
                          child: const Text('Scan code'),
                        ),
                        TextButton(
                          onPressed: _openAddItemWindow,
                          child: const Text('Add new Item'),
                        ),
                      ],
                      child: const Icon(
                        Icons.add,
                        size: 55,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const Text('Needs')
          ],
        ),
      ),
    );
  }
}
