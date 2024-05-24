import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:synny_space/items_list/stored_item.dart';
import 'package:synny_space/model/storage_card.dart';
import 'package:synny_space/widgets/card_form.dart';
import 'package:synny_space/widgets/item_adding.dart';

class FindByCode extends StatefulWidget {
  FindByCode(
      {super.key,
      required this.listOfItems,
      required this.scannedBarcode,
      required this.inNeeds,
      this.changeInitialList,
      this.addNewItemToList,
      this.sendItemToNeeds});
  List<StorageCard> listOfItems;
  final int scannedBarcode;
  final bool inNeeds;
  void Function(StorageCard editedItem, int indeOfItem)? changeInitialList;
  void Function(StorageCard item)? addNewItemToList;
  Function(StorageCard card)? sendItemToNeeds;
  @override
  State<FindByCode> createState() => _FindByCodeState();
}

class _FindByCodeState extends State<FindByCode> {
  int? itemIndex;
  bool cardFounded = false;
  late StorageCard listItemToEdit;
  Color buttonBackColor = Colors.deepPurpleAccent;
  Color buttonForegColor = Colors.white;
  XFile? file;
  bool cardEdited = false;
  String? scannedBarcode;

  _findCard(int? barcode) async {
    barcode ??= await _scanBarcode();
    scannedBarcode = barcode.toString();
    for (StorageCard item in widget.listOfItems) {
      if (item.barcode == barcode) {
        return setState(() {
          itemIndex = widget.listOfItems.indexOf(item);
          listItemToEdit = widget.listOfItems[itemIndex!];

          cardFounded = true;
        });

        //print('INDEX^^^:::::::::::::::::::::$itemIndex');
      }
    }

    return setState(() {
      cardFounded = false;
    });
  }

  _scanBarcode() async {
    scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    return (int.parse(scannedBarcode!));
  }

  @override
  void initState() {
    super.initState();
    _findCard(widget.scannedBarcode);
    //_findCard(code);
  }

  createItemFunction(int barcode) async {
    final newItem = await Navigator.of(context).push<StorageCard>(
      MaterialPageRoute(
        builder: (ctx) => ItemAdding(
          barcode: barcode.toString(),
        ),
      ),
    );
    if (newItem == null) {
      return;
    }
    if (widget.sendItemToNeeds != null) {
      addCardToNeeds(newItem);
    }
    setState(() {
      widget.addNewItemToList!(newItem);
    });
  }

  void _createNewItem(String barcode) async {
    await createItemFunction(int.parse(barcode));
    Navigator.pop(context);
  }

  Widget cardNotFounded() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              'Item not found. \nYou can try again, or create new item by pressing button below.',
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoSlab(
                  fontSize: 24, fontStyle: FontStyle.italic)),
          const SizedBox(
            height: 70,
          ),
          ElevatedButton.icon(
            onPressed: () {
              _findCard(null);
            },
            icon: const Icon(CupertinoIcons.barcode_viewfinder),
            label: const Text('Find by code!'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 40),
                backgroundColor: buttonBackColor,
                foregroundColor: buttonForegColor),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _createNewItem(scannedBarcode!);
            },
            icon: const Icon(CupertinoIcons.add),
            label: const Text('Create new item!'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 40),
                backgroundColor: buttonBackColor,
                foregroundColor: buttonForegColor),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            label: const Text('Back to list.'),
            icon: const Icon(Icons.keyboard_backspace_rounded),
          )
        ]);
  }

  editCardData(StorageCard card) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Item succesfully changed'),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.green,
    ));

    return setState(() {
      cardEdited = true;
      listItemToEdit = card;
      widget.listOfItems[itemIndex!] = listItemToEdit;
    });
  }

  void addCardToNeeds(StorageCard? card) {
    card == null
        ? widget.sendItemToNeeds!(listItemToEdit)
        : {widget.sendItemToNeeds!(card), Navigator.pop(context)}; //changed lastly, be aware 
  }

  void editCard() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 48, 10, 10),
              child: CardForm(
                givenItem: listItemToEdit,
                editItem: editCardData,
              ));
        });
  }

  void _succesfullyChanged() {
    ScaffoldMessenger.of(context).clearSnackBars();
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Item succesfully changed'), action: SnackBarAction(label: 'Undo', onPressed: ),));
  }

  Widget foundedCard() {
    return Column(children: [
      StoredItem(listItemToEdit),
      widget.inNeeds
          ? ElevatedButton.icon(
              onPressed: () {
                addCardToNeeds(null);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Add this item!'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 40),
                  backgroundColor: buttonBackColor,
                  foregroundColor: buttonForegColor),
            )
          : ElevatedButton.icon(
              onPressed: editCard,
              icon: const Icon(Icons.edit),
              label: const Text('Edit this item!'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 40),
                  backgroundColor: buttonBackColor,
                  foregroundColor: buttonForegColor),
            ),
      ElevatedButton.icon(
        onPressed: () {
          _findCard(null);
        },
        icon: const Icon(CupertinoIcons.barcode_viewfinder),
        label: const Text('Find by code!'),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 40),
            backgroundColor: buttonBackColor,
            foregroundColor: buttonForegColor),
      ),
      TextButton.icon(
        onPressed: () {
          cardEdited
              ? {
                  widget.changeInitialList!(listItemToEdit, itemIndex!),
                  Navigator.pop(context)
                }
              : Navigator.pop(context);
        },
        label: Text(widget.inNeeds ? 'Back to Needs' : 'Back to list.'),
        icon: const Icon(Icons.keyboard_backspace_rounded),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Find item by code'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: cardFounded ? foundedCard() : Center(child: cardNotFounded()),
        ));
  }
}
