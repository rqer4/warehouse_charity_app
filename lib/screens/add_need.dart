import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synny_space/custom_pacages/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/model/storage_card.dart';
import 'package:synny_space/needs_list/needs_item.dart';
import 'package:synny_space/screens/find_by_code/find_by_code.dart';

// ignore: must_be_immutable
class AddNeed extends StatefulWidget {
  AddNeed(
      {super.key, required this.listOfItems, required this.addNewItemToList});

  List<StorageCard> listOfItems;
  void Function(StorageCard item) addNewItemToList;
  @override
  State<AddNeed> createState() => _AddNeedState();
}

class _AddNeedState extends State<AddNeed> {
  Color buttonBackColor = Colors.deepPurpleAccent;
  Color buttonForegColor = Colors.white;
  String needTitle = '';
  late StorageCard listItemToAdd;
  List<StorageCard> listOfNeedsItems = [];
  List<String> listOfSelectedItemIds = [];
  final _formKey = GlobalKey<FormState>();

  bool cardFounded = false;
  bool backPressed = false;

  int? itemIndex;
  DateTime? deadline;
  String? scannedBarcode;

  bool isButtonExtended = false;

  String? enteredPrice;

  void onCreateNeed(
      List<double>? listOfStartPoints, List<double>? listOfGoals) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('HEREWEAREEEEEEEEEEEEEEE');
      for (final item in listOfNeedsItems) {
        listOfSelectedItemIds.add(item.id);
      }
      final url = Uri.https(
          'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
          'needs-list.json');
      final response = await http.post(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode(
          {
            'title': needTitle,
            'childrens': {
              'id': listOfSelectedItemIds,
              'start': listOfStartPoints,
              'goals': listOfGoals
            },
            'price': int.parse(enteredPrice!),
            'deadline': deadline != null ? deadline!.millisecondsSinceEpoch : 0,
          },
        ),
      );
      Navigator.of(context).pop(NeedsCard(
          parentId: json
              .decode(response.body)
              .toString()
              .replaceRange(
                0,
                7,
                '',
              )
              .replaceRange(20, 21, ''),
          title: needTitle,
          childIds: listOfSelectedItemIds,
          childStartPoints: listOfStartPoints,
          childGoals: listOfGoals,
          deadlineInSeconds: deadline != null ? deadline!.millisecondsSinceEpoch : 0,
          price: int.parse(enteredPrice!)));
    }
  }

  void _openFindItemWindow() async {
    String scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    await Navigator.of(context).push<StorageCard>(
      MaterialPageRoute(
        builder: (ctx) => FindByCode(
          inNeeds: true,
          listOfItems: widget.listOfItems,
          scannedBarcode: int.parse(scannedBarcode),
          sendItemToNeeds: addToListOfNeedsItems,
          //changeInitialList: itemEditedByCode,
          addNewItemToList: widget.addNewItemToList,
        ),
      ),
    );

    //return;
  }

  void addToListOfNeedsItems(StorageCard card) {
    setState(() {
      listOfNeedsItems.add(card);
    });
  }

  void _onRemoveItem(StorageCard itemCard) async {
    final itemIndex = listOfNeedsItems.indexOf(itemCard);
    setState(() {
      listOfNeedsItems.removeAt(itemIndex);
    });
  }

  void _showDatePicker() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context, initialDate: now, firstDate: now, lastDate: lastDate);
    setState(() {
      deadline = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget needNotCreated() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                initialValue: needTitle,
                                decoration: const InputDecoration(
                                    label: Text('Назва*')),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length > 20) {
                                    return 'Invalid title';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  needTitle = value!;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              keyboardType: TextInputType.number,
                              initialValue: '0',
                              decoration: const InputDecoration(
                                label: Text('Загальна вартість'),
                                prefix: Text('₴ '),
                              ),
                              validator: (value) {
                                if (double.parse(value!) < 0) {
                                  return 'Can\'t be < 0';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                enteredPrice = (value!);
                              },
                            )),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    deadline == null
                                        ? 'Deadline date\'s\n   not selected'
                                        : 'Дедлайн:\n${formater.format(deadline!)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: _showDatePicker,
                                      icon: const Icon(
                                          Icons.calendar_month_outlined))
                                ],
                              ),
                            ),
                          ],
                        ),
                        listOfNeedsItems.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: NeedsItem(
                                  needItem: NeedsCard(
                                    parentId: DateTime.now().toString(),
                                    title: 'Selected Items:',
                                    childrens: listOfNeedsItems,
                                  ),
                                  onRemoveChild: _onRemoveItem,
                                  onCreateNeed: onCreateNeed,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          'No added items yet. \n',
                                          style: GoogleFonts.robotoSlab(
                                              fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'Scan the code and add some by pressing button below',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      onCreateNeed(null, null);
                                    },
                                    label: const Text('Save items.'),
                                    icon: const Icon(Icons.save_outlined),
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            globals.buttonForegColor,
                                        backgroundColor:
                                            globals.submitButtonBackColor),
                                  ),
                                ],
                              ),
                        const SizedBox(
                          height: 25,
                        ),
                      ]),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                label: const Text('Back to needs list.'),
                icon: const Icon(Icons.keyboard_backspace_rounded),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Create need'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: SizedBox(
          height: 65,
          width: 65,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: globals.buttonForegColor,
              foregroundColor: globals.buttonBackColor,
              onPressed: _openFindItemWindow,
              shape: const CircleBorder(),
              child: const Icon(
                CupertinoIcons.barcode_viewfinder,
              ),
            ),
          ),
        ),
        body: needNotCreated());
  }
}
