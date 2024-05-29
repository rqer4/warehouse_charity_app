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
            ListPage(
              registeredItems: _registeredItems,
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
