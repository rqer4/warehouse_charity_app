import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
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
      required this.changeInitialList,
      required this.addNewItemToList});
  List<StorageCard> listOfItems;
  final int scannedBarcode;
  void Function(StorageCard editedItem, int indeOfItem) changeInitialList;
  void Function(StorageCard item) addNewItemToList;
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
    setState(() {
      widget.addNewItemToList(newItem);
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
            onPressed: (){_findCard(null);},
            icon: const Icon(CupertinoIcons.barcode_viewfinder),
            label: const Text('Find by code!'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 40),
                backgroundColor: buttonBackColor,
                foregroundColor: buttonForegColor),
          ),
          ElevatedButton.icon(
            onPressed: (){_createNewItem(scannedBarcode!);},
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

  Widget cardToEdit() {
    return Column(children: [
      StoredItem(listItemToEdit),
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
        onPressed: (){_findCard(null);},
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
                  widget.changeInitialList(listItemToEdit, itemIndex!),
                  Navigator.pop(context)
                }
              : Navigator.pop(context);
        },
        label: const Text('Back to list.'),
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
          child: cardFounded ? cardToEdit() : Center(child: cardNotFounded()),
        ));
  }
}
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
        //   child: Form(
        //     child: Column(
        //       children: [
        //         Row(
        //           crossAxisAlignment: CrossAxisAlignment.end,
        //           children: [
        //             // Title field
        //             Expanded(
        //               child: TextFormField(
        //                 initialValue: listItemToEdit.title,
        //                 decoration: const InputDecoration(
        //                   label: Text('Title'),
        //                 ),
        //                 validator: (value) {
        //                   if (value == null ||
        //                       value.isEmpty ||
        //                       value.trim().length >= 50) {
        //                     return 'Incorrect title';
        //                   }
        //                   return null;
        //                 },
        //                 onSaved: (value) {
        //                   listItemToEdit.title = value!;
        //                   print(listItemToEdit.title);
        //                 },
        //               ),
        //             ),
        //             const SizedBox(
        //               width: 25,
        //             ),
        //             Expanded(
        //               child: DropdownButtonFormField(
        //                 value: listItemToEdit.cathegory,
        //                 items: (Cathegory.values)
        //                     .map(
        //                       (cathegory) => DropdownMenuItem(
        //                         value: cathegory,
        //                         child: Text(cathegory.name.toUpperCase()),
        //                       ),
        //                     )
        //                     .toList(),
        //                 onChanged: (value) {
        //                   setState(() {
        //                     listItemToEdit.cathegory = value!;
        //                     print(listItemToEdit.cathegory);
        //                   });
        //                 },
        //               ),
        //             ),
        //             Row(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Expanded(
        //                   child: TextFormField(
        //                     initialValue: listItemToEdit.quantity.toString(),
        //                     keyboardType: TextInputType.number,
        //                     maxLength: 5,
        //                     decoration: const InputDecoration(
        //                       label: Text('Кількість:'),
        //                     ),
        //                     validator: (value) {
        //                       if (value == null ||
        //                           value.isEmpty ||
        //                           value.trim().length >= 50) {
        //                         return 'Incorrect quantity';
        //                       }
        //                       return null;
        //                     },
        //                     onSaved: (value) {
        //                       listItemToEdit.quantity = int.parse(value!);
        //                     },
        //                   ),
        //                 ),
        //                 const Spacer(),
        //                 Expanded(
        //                   child: TextFormField(
        //                     initialValue:
        //                         listItemToEdit.measureVolume.toString(),
        //                     keyboardType: TextInputType.number,
        //                     maxLength: 5,
        //                     decoration: const InputDecoration(
        //                       label: Text('Об\'єм:'),
        //                     ),
        //                     validator: (value) {
        //                       if (value == null ||
        //                           value.isEmpty ||
        //                           value.trim().length >= 50) {
        //                         return 'Incorrect Volume';
        //                       }
        //                       return null;
        //                     },
        //                     onSaved: (value) {
        //                       listItemToEdit.measureVolume =
        //                           double.parse(value!);
        //                     },
        //                   ),
        //                 ),
        //                 const SizedBox(
        //                   width: 10,
        //                 ),
        //                 Expanded(
        //                   child: DropdownButtonFormField(
        //                     padding: const EdgeInsets.only(top: 8),
        //                     value: listItemToEdit.measureUnit,
        //                     items: MeasureUnit.values
        //                         .map(
        //                           (measureUnit) => DropdownMenuItem(
        //                             value: measureUnit,
        //                             child: Text(measureUnit.name),
        //                           ),
        //                         )
        //                         .toList(),
        //                     onChanged: (value) {
        //                       setState(() {
        //                         listItemToEdit.measureUnit = value!;
        //                       });
        //                     },
        //                   ),
        //                 ),
        //               ],
        //             ),
        //             const SizedBox(
        //               height: 20,
        //             ),
        //             Row(
        //               crossAxisAlignment: CrossAxisAlignment.center,
        //               children: [
        //                 Container(
        //                   //padding: const EdgeInsets.all(20),
        //                   child: Column(
        //                     children: [
        //                       SizedBox(
        //                         height: 200,
        //                         width: 160,
        //                         child: Image.file(
        //                           File(file!.path),
        //                         ),
        //                       ),
        //                       const SizedBox(
        //                         height: 5,
        //                       ),
        //                       OutlinedButton.icon(
        //                         onPressed: showImageDialog,
        //                         label: const Text('Change'),
        //                         icon: const Icon(Icons.add_a_photo_outlined),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 const Spacer(),
        //                 Column(
        //                   children: [
        //                     SizedBox(
        //                       height: 200,
        //                       width: 160,
        //                       child: Column(
        //                         mainAxisAlignment: MainAxisAlignment.center,
        //                         children: [
        //                           const Icon(
        //                             CupertinoIcons.check_mark_circled,
        //                             color: Color.fromARGB(255, 14, 150, 19),
        //                           ),
        //                           const Text(
        //                             'Code Added!\nYou can change it by pressing button below',
        //                             textAlign: TextAlign.center,
        //                             style: TextStyle(
        //                                 color:
        //                                     Color.fromARGB(255, 14, 150, 19)),
        //                           ),
        //                           const SizedBox(
        //                             height: 5,
        //                           ),
        //                           Text(
        //                             'Code is: \n${listItemToEdit.barcode}',
        //                             textAlign: TextAlign.center,
        //                             style: const TextStyle(
        //                                 fontWeight: FontWeight.bold),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
                            
        //                   ],
        //                 ),
        //               ],
        //             ),
        //             const SizedBox(
        //               height: 15,
        //             ),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.end,
        //               children: [
        //                 TextButton(
        //                   onPressed: () {
        //                     Navigator.pop(context);
        //                   },
        //                   child: const Text('Cancel'),
        //                 ),
        //                 FilledButton(
        //                   onPressed: onSaveItem,
        //                   style: FilledButton.styleFrom(
        //                       backgroundColor:
        //                           const Color.fromARGB(255, 16, 104, 176)),
        //                   child: const Text('Save'),
        //                 ),
        //               ],
        //             )
        //           ],
        //         )
        //       ],
        //     ),
        //   ),
        // );



