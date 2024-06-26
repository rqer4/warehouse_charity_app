import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/pages/list_page.dart';
import 'package:synny_space/pages/needs_page.dart';
import 'package:synny_space/model/storage_card.dart';

class TabBarHolder extends StatefulWidget {
  const TabBarHolder({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TabBarHolderState();
  }
}

class _TabBarHolderState extends State<TabBarHolder> {
  List<StorageCard> _registeredItems = [];
  bool isItems = false;
  @override
  initState() {
    super.initState();
    _loadItems();
  }

  void changeInitialListAfterNeedEdit(NeedsCard card, int index) {
    int counter = 0;
    for (var item in _registeredItems) {
      if (item.id == card.childIds![index]) {
        item.quantity = card.childStartPoints![index];
        setState(() {
          _registeredItems[counter].quantity = item.quantity;
        });
      }
      counter++;
    }
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
      loadedItems.add(//careful
        StorageCard(
            id: item.key,
            barcode: int.tryParse(item.value['barcode']) != null
                ? int.parse(item.value['barcode'])
                : item.value['barcode'],
            image: item.value['image'],
            quantity: double.parse(item.value['quantity'].toString()),
            title: item.value['title'],
            cathegory: item.value['cathegory'],
            measureVolume: item.value['measureVolume'],
            measureUnit: item.value['measureUnit']),
      );
    }

    setState(() {
      _registeredItems = loadedItems;
    });
  }

  void _addItemToList(StorageCard item) {
    setState(() {
      _registeredItems.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(tabs: [
                Tab(
                  text: 'Склад',
                ),
                Tab(
                  text: 'Потреби',
                )
              ])
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListPage(
              registeredItems: _registeredItems,
              isItems: _registeredItems.isNotEmpty,
            ),
            NeedsPage(
              changeQuantityInList: changeInitialListAfterNeedEdit,
              listOfItems: _registeredItems,
              addNewItemToList: _addItemToList,
            )
          ],
        ),
      ),
    );
  }
}
