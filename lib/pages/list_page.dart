import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:synny_space/items_list/items_list.dart';
import 'package:synny_space/screens/find_by_code/find_by_code.dart';
import 'package:synny_space/widgets/item_adding.dart';
import 'package:synny_space/model/storage_card.dart';

class ListPage extends StatefulWidget {
  ListPage({super.key, required this.registeredItems, });

  List<StorageCard> registeredItems;

  @override
  State<StatefulWidget> createState() {
    return _ListPageState();
  }
}

class _ListPageState extends State<ListPage> {
  

  void _onRemoveItem(StorageCard itemCard) async {
    final itemIndex = widget.registeredItems.indexOf(itemCard);
    setState(() {
      widget.registeredItems.removeAt(itemIndex);
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
        widget.registeredItems.insert(itemIndex, itemCard);
      });
    }
  }

  void _addItemToList(StorageCard item) {
    setState(() {
      widget.registeredItems.add(item);
    });
  }

  void _openAddItemWindow() async {
    final newItem = await Navigator.of(context).push<StorageCard>(
      MaterialPageRoute(
        builder: (ctx) => ItemAdding(),
      ),
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _addItemToList(newItem);
    });
  }

  void itemEditedByCode(StorageCard editedItem, int itemIndex) {
    widget.registeredItems.removeAt(itemIndex);
    setState(() {
      widget.registeredItems.insert(itemIndex, editedItem);
    });
  }

  void _openFindItemWindow() async {
    String scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    await Navigator.of(context).push<StorageCard>(
      MaterialPageRoute(
        builder: (ctx) => FindByCode(
          inNeeds: false,
          listOfItems: widget.registeredItems,
          scannedBarcode: int.parse(scannedBarcode),
          changeInitialList: itemEditedByCode,
          addNewItemToList: _addItemToList,
        ),
      ),
    );

    return;
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
              height: 60,
              width: 60,
              child: Icon(
                Icons.find_in_page_outlined,
                size: 50,
              )),
          Text(
            'No items found. \nTry to add some!',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoSlab(fontSize: 24, letterSpacing: 3),
          )
        ],
      ),
    );

    if (widget.registeredItems.isNotEmpty) {
      mainContent = ItemsList(
        itemsList: widget.registeredItems,
        removeItem: _onRemoveItem,
      );
    }

    return Scaffold(
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        
        children: [
          SpeedDialChild(
            child: const Icon(CupertinoIcons.barcode_viewfinder),
            onTap: _openFindItemWindow,
            label: 'Find by code',
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            onTap: _openAddItemWindow,
            label: 'Add new item',
          )
        ],
        child: const Icon(Icons.add),
      ),
      body: mainContent,
    );
  }
}
