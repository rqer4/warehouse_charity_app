import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:synny_space/items_list/items_list.dart';
import 'package:synny_space/model/storage_card.dart';
import 'package:synny_space/widgets/item_adding.dart';

class FindByCode extends StatefulWidget {
  FindByCode(
      {super.key,
      required this.listOfItems,
      required this.scannedBarcode,
      required this.inNeeds,
      this.changeInitialList,
      this.addNewItemToList,
      this.sendItemToNeeds,
      this.removeItem,
      this.isFindForNeed});
  bool? isFindForNeed;
  List<StorageCard> listOfItems;
  final int scannedBarcode;
  final bool inNeeds;
  final void Function(StorageCard itemCard)? removeItem;
  void Function(StorageCard editedItem, int indeOfItem)? changeInitialList;
  void Function(StorageCard item)? addNewItemToList;
  Function(StorageCard card)? sendItemToNeeds;
  @override
  State<FindByCode> createState() => _FindByCodeState();
}

class _FindByCodeState extends State<FindByCode> {
  int? itemIndex;
  int? editItemIndex;
  bool cardsFounded = false;
  List<StorageCard> listItemsToEdit = [];
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
        itemIndex = widget.listOfItems.indexOf(item);
        listItemsToEdit.add(widget.listOfItems[itemIndex!]);
        cardsFounded = true;
      }
    }
    if (cardsFounded) {
      return setState(() {
        cardsFounded = true;
      });
    }
    return setState(() {
      cardsFounded = false;
    });
  }

  void _onRemoveItem(StorageCard itemCard) async {
    final itemIndex = listItemsToEdit.indexOf(itemCard);
    setState(() {
      listItemsToEdit.removeAt(itemIndex);
    });
    widget.isFindForNeed == null ? widget.removeItem!(itemCard) : null;
  }

  _scanBarcode() async {
    scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Скасувати', true, ScanMode.BARCODE);
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
              'Товар не знайдено. \nВи можете спробувати ще раз, або додати новий, натиснувши кнопку внизу.',
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
            label: const Text('Знайти за кодом!'),
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
            label: const Text('Створити товар!'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 40),
                backgroundColor: buttonBackColor,
                foregroundColor: buttonForegColor),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            label: const Text('Назад до товарів.'),
            icon: const Icon(Icons.keyboard_backspace_rounded),
          )
        ]);
  }

  editCardData(StorageCard card, newCard) {
    return widget.changeInitialList != null
        ? setState(() {
            cardEdited = true;
            itemIndex = widget.listOfItems.indexOf(card);
            widget.changeInitialList!(newCard, itemIndex!);
          })
        : null;
  }

  void addCardToNeeds(StorageCard? card) {
    card == null
        ? {
            widget
                .sendItemToNeeds!(listItemsToEdit[listItemsToEdit.length - 1]),
            Navigator.pop(context)
          }
        : widget.sendItemToNeeds!(card);
  }

  Widget foundedCard() {
    return Column(children: [
      ItemsList(
        itemsList: listItemsToEdit,
        removeItem: _onRemoveItem,
        changeItemInItitialList: editCardData,
        isForFinalNeeds: true,
      ),
      widget.inNeeds
          ? ElevatedButton.icon(
              onPressed: () {
                listItemsToEdit.isNotEmpty
                    ? addCardToNeeds(null)
                    : showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Товар відсутній'),
                            content: const Text(
                                'Схоже ви вдалили знайдений товар. Відскануйте код існуючого товару для продовження.'),
                            actions: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(CupertinoIcons.checkmark_alt_circle),
                                label: const Text('Добре'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white),
                              )
                            ],
                          );
                        },
                      );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Додати цей товар!'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 40),
                  backgroundColor: buttonBackColor,
                  foregroundColor: buttonForegColor),
            )
          : const Text(
              'Свайпніть вліво, щоб редагувати\nСвайпнiть вправо щоб видалити'),
      ElevatedButton.icon(
        onPressed: () {
          _findCard(null);
        },
        icon: const Icon(CupertinoIcons.barcode_viewfinder),
        label: const Text('Знайти за кодом!'),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 40),
            backgroundColor: buttonBackColor,
            foregroundColor: buttonForegColor),
      ),
      TextButton.icon(
        onPressed: () {
          cardEdited
              ? {
                  //widget.changeInitialList!(listItemToEdit, itemIndex!),
                  Navigator.pop(context)
                }
              : Navigator.pop(context);
        },
        label: Text(widget.inNeeds ? 'Назад до потреб' : 'Назад до товарів.'),
        icon: const Icon(Icons.keyboard_backspace_rounded),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Знайти за кодом'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: cardsFounded ? foundedCard() : Center(child: cardNotFounded()),
        ));
  }
}
