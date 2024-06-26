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
    if (listOfNeedsItems.isNotEmpty) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
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
              'deadline':
                  deadline != null ? deadline!.millisecondsSinceEpoch : 0,
            },
          ),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Потребу успішно створено.'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.green,
        ));
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
          deadlineInSeconds:
              deadline != null ? deadline!.millisecondsSinceEpoch : 0,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Додайте предмети збору, відсканувавши код.'),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _openFindItemWindow() async {
    String scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Скасувати', true, ScanMode.BARCODE);

    await Navigator.of(context).push<StorageCard>(
      MaterialPageRoute(
        builder: (ctx) => FindByCode(
          inNeeds: true,
          isFindForNeed: true,
          listOfItems: widget.listOfItems,
          scannedBarcode: int.parse(scannedBarcode),
          sendItemToNeeds: addToListOfNeedsItems,
          //changeInitialList: itemEditedByCode,
          addNewItemToList: widget.addNewItemToList,
        ),
      ),
    );

    return;
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
                                    return 'Некоректна назва';
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    deadline == null
                                        ? 'Дата дедлайну\n   не обрана'
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
                                    title: 'Обрані товари:',
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
                                          'Товари не додано. \n',
                                          style: GoogleFonts.robotoSlab(
                                              fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'Відскануйте код, щоб додати, натиснувши кнопку внизу.',
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
                                    label: const Text('Додати потребу.'),
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
                label: const Text('Назад до потреб.'),
                icon: const Icon(Icons.keyboard_backspace_rounded),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Створити потребу'),
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
