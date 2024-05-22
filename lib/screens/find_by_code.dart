import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synny_space/items_list/stored_item.dart';
import 'package:synny_space/model/storage_card.dart';

class FindByCode extends StatefulWidget {
  FindByCode(
      {super.key, required this.listOfItems, required this.scannedBarcode});
  List<StorageCard> listOfItems;
  final int scannedBarcode;
  @override
  State<FindByCode> createState() => _FindByCodeState();
}

class _FindByCodeState extends State<FindByCode> {
  int? itemIndex;
  bool cardFounded = false;
  late StorageCard listItemToEdit;
  Color buttonBackColor = Colors.deepPurpleAccent;
  Color buttonForegColor = Colors.white;
  final _formKey = GlobalKey<FormState>();

  _findCard(int code) {
    for (StorageCard item in widget.listOfItems) {
      if (item.barcode == code) {
        itemIndex = widget.listOfItems.indexOf(item);
        listItemToEdit = widget.listOfItems[itemIndex!];
        cardFounded = true;
        //print('INDEX^^^:::::::::::::::::::::$itemIndex');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _findCard(widget.scannedBarcode);
  }

  Widget cardNotFounded() {
    return const Text('Card Not Founded');
  }

  Widget cardToEdit() {
    return Column(children: [
      StoredItem(widget.listOfItems[itemIndex!]),
      ElevatedButton.icon(
        onPressed: editCard,
        icon: const Icon(Icons.edit),
        label: const Text('Edit this item!'),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 40),
            backgroundColor: buttonBackColor,
            foregroundColor: buttonForegColor),
      ),
      ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(CupertinoIcons.barcode_viewfinder),
        label: const Text('Find by code!'),
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

  void editCard() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          child: Form(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Title field
                    Expanded(
                      child: TextFormField(
                        initialValue: listItemToEdit.title,
                        decoration: const InputDecoration(
                          label: Text('Title'),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().length >= 50) {
                            return 'Incorrect title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          listItemToEdit.title = value!;
                          print(listItemToEdit.title);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: listItemToEdit.cathegory,
                        items: (Cathegory.values)
                            .map(
                              (cathegory) => DropdownMenuItem(
                                value: cathegory,
                                child: Text(cathegory.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            listItemToEdit.cathegory = value!;
                            print(listItemToEdit.cathegory);
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Find item by code'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: cardFounded ? cardToEdit() : cardNotFounded(),
        ));
  }
}
