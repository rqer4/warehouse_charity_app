import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/model/storage_card.dart';
import 'package:synny_space/screens/add_need.dart';
import 'package:http/http.dart' as http;
import 'package:synny_space/custom_pacages/globals.dart' as globals;
import 'package:synny_space/widgets/final_need.dart';

class NeedsPage extends StatefulWidget {
  NeedsPage(
      {super.key, required this.listOfItems, required this.addNewItemToList});

  List<StorageCard> listOfItems;
  void Function(StorageCard item) addNewItemToList;
  @override
  State<NeedsPage> createState() => _NeedsPageState();
}

class _NeedsPageState extends State<NeedsPage> {
  List<NeedsCard> registeredNeeds = [];
  void onChangeNeed(NeedsCard need, int index) async {
    final url = Uri.https(
        'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
        'needs-list/${need.parentId}/childrens.json');
    final response = await http.patch(
      url,
      headers: {'Content-type': 'application/json'},
      body: json.encode(
        {
          //'id': need.childIds,
          'start': need.childStartPoints!,
          //'goals': need.childGoals
        },
      ),
    );
    final urlForItemChange = Uri.https(
        'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
        'item-list/${need.childIds![index]}.json');
    final responseIten = await http.patch(
      urlForItemChange,
      headers: {'Content-type': 'application/json'},
      body: json.encode(
        {
          'quantity': (need.childStartPoints![index]),
        },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
        'needs-list.json');
    final response = await http.get(url);
    if (json.decode(response.body) == null) {
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<NeedsCard> loadedItems = [];

    for (final item in listData.entries) {
      loadedItems.add(NeedsCard(
          parentId: item.key,
          title: item.value['title'],
          childIds: item.value['childrens']['id'],
          childGoals: item.value['childrens']['goals'],
          childStartPoints: item.value['childrens']['start'],
          deadlineInSeconds: item.value['deadline'],
          price: item.value['price']));
    }

    setState(() {
      registeredNeeds = loadedItems;
    });
  }

  void _addNewNeedToInitialList(NeedsCard newCard) {
    registeredNeeds.add(newCard);

    setState(() {
      FinalNeed(
        isFromAddingNeed: true,
        onAddQuantity: onChangeNeed,
        createdNeedCard: newCard,
        registeredItems: widget.listOfItems,
        loadedNeeds: [],
      );
    });
  }

  void _openAddNeedWindow() async {
    final newItem = await Navigator.of(context).push<NeedsCard>(
      MaterialPageRoute(
        builder: (ctx) => AddNeed(
          listOfItems: widget.listOfItems,
          addNewItemToList: widget.addNewItemToList,
        ),
      ),
    );
    if (newItem == null) {
      return;
    }
    _addNewNeedToInitialList(newItem);
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = FinalNeed(
      loadedNeeds: registeredNeeds,
      registeredItems: widget.listOfItems,
      onAddQuantity: onChangeNeed,
    );
    // Padding(
    //   padding: const EdgeInsets.fromLTRB(10, 20, 10, 50),
    //   child: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         const Icon(
    //           Icons.find_in_page_outlined,
    //           size: 50.0,
    //         ),
    //         Text(
    //           'There is no needs. \nYou can add some!',
    //           textAlign: TextAlign.center,
    //           style: GoogleFonts.robotoSlab(fontSize: 24, letterSpacing: 3),
    //         )
    //       ],
    //     ),
    //   ),
    // );

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: _openAddNeedWindow,
            shape: const CircleBorder(),
            backgroundColor: globals.buttonForegColor,
            foregroundColor: globals.buttonBackColor,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}
