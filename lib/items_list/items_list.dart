import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synny_space/items_list/stored_item.dart';
import 'package:synny_space/model/storage_card.dart';
import 'package:flutter_spinbox/material.dart';

import 'package:synny_space/custom_pacages/globals.dart' as globals;
import 'package:synny_space/widgets/card_form.dart';

class ItemsList extends StatefulWidget {
  const ItemsList(
      {super.key,
      required this.itemsList,
      this.removeItem,
      this.onSaveItemGoals,
      this.changeItemInItitialList,
      this.isForNeeds,
      this.isForFinalNeeds,
      this.onCreateNeed});

  final bool? isForFinalNeeds;
  final bool? isForNeeds;
  final List<StorageCard> itemsList;
  final void Function(List<String> itemIds, double startPoint, double goal)?
      onSaveItemGoals;
  final void Function(StorageCard itemCard)? removeItem;
  final void Function(StorageCard card, StorageCard newCard)?
      changeItemInItitialList;
  final Function(List<double> listOfStartPoints, List<double> listOfGoals)?
      onCreateNeed;

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  List<double> startPoint = [];
  List<double> endPoint = [];

  double enteredStart = 0;
  double enteredGoal = 0;

  int? itemIndex;
  StorageCard? listItemToEdit;

  // void setInitialGoalAndStart(int index) {
  //   startPoint.add(widget.itemsList[index].quantity);
  //   endPoint.add(widget.itemsList[index].quantity + 1);
  // }

  editCardData(StorageCard card, newCard) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Item succesfully changed'),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.green,
    ));

    return setState(() {
      //cardEdited = true;
      listItemToEdit = newCard;
      itemIndex = widget.itemsList.indexOf(card);
      widget.itemsList[itemIndex!] = listItemToEdit!;
      if (widget.changeItemInItitialList != null) {
        widget.changeItemInItitialList!(card, newCard);
      }
    });
  }

  void editCard(StorageCard card) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 48, 10, 10),
              child: CardForm(
                givenItem: card,
                editItem: editCardData,
              ));
        });
  }

  Widget swipeLeftBackground() {
    return Container(
      color: Colors.green,
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              'Edit',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget swipeRightBackground() {
    return Container(
      color: Colors.red,
      child: const Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              'Delete',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(context) {
    final List<GlobalObjectKey<FormState>> formKeyList = List.generate(
        widget.itemsList.length, (index) => GlobalObjectKey<FormState>(index));

    void onSaveGoal() {
      //formKeyList[index].currentState!.validate();
      //formKeyList[index].currentState!.save();
      int validCounter = 0;
      for (final formKey in formKeyList) {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          validCounter++;
        }
      }
      if (validCounter == formKeyList.length) {
        widget.onCreateNeed!(startPoint, endPoint);
        print(
          'start point $startPoint    $enteredStart|||||| GOAL $endPoint   $enteredGoal');

      }
      
      //for(item in )
      //widget.onSaveItemGoals()
    }

    return widget.isForNeeds == null
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.itemsList.length,
            itemBuilder: (ctx, index) => Dismissible(
              key: ValueKey(widget.itemsList[index]),
              secondaryBackground: swipeRightBackground(),
              background: swipeLeftBackground(),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content:
                            const Text('You sure you want to delete item?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              widget.removeItem!(widget.itemsList[index]);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(CupertinoIcons.trash),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white),
                          )
                        ],
                      );
                    },
                  );
                } else {
                  editCard(
                    widget.itemsList[index],
                  );
                }
                return null;
              },
              onDismissed: (direction) {},
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: StoredItem(widget.itemsList[index]),
              ),
            ),
          )
        : Column(
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 355),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  
                  shrinkWrap: true,
                  physics: widget.isForFinalNeeds != null
                      ? const ClampingScrollPhysics()
                      : const AlwaysScrollableScrollPhysics() ,
                  itemCount: widget.itemsList.length,
                  itemBuilder: (ctx, index) => Dismissible(
                    key: ValueKey(widget.itemsList[index]),
                    secondaryBackground: swipeLeftBackground(),
                    background: swipeLeftBackground(),
                    //direction: DismissDirection.startToEnd,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        bool res = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: const Text(
                                  'You sure you want to delete item?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    widget.removeItem!(widget.itemsList[index]);
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(CupertinoIcons.trash),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white),
                                )
                              ],
                            );
                          },
                        );
                        return res;
                      } else {
                        editCard(widget.itemsList[index]);
                        return true;
                      }
                    },
                    onDismissed: (direction) {
                      //widget.removeItem(widget.itemsList[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Form(
                        key: formKeyList[index],
                        child: Column(
                          children: [
                            StoredItem(
                              widget.itemsList[index],
                              isShrinked: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10, left: 5, right: 5, top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: SpinBox(
                                      
                                      spacing: 0,
                                      decoration: const InputDecoration(
                                          label: Text(
                                        'Start point:',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      min: 0,
                                      value: double.parse(widget
                                          .itemsList[index].quantity
                                          .toString()),
                                      validator: (value) {
                                        if (startPoint.length >= index + 1) {
                                          startPoint.removeAt(index);
                                          startPoint.insert(
                                              index, double.parse(value!));
                                        } else {
                                          startPoint.insert(
                                              index, double.parse(value!));
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: SpinBox(
                                      acceleration: 1,
                                      decoration: const InputDecoration(
                                          label: Text(
                                        'Goal:',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      min: 1,
                                      max: 1000000,
                                      value: double.parse(widget
                                              .itemsList[index].quantity
                                              .toString()) +
                                          1,
                                      onSubmitted: (value) {},
                                      validator: (value) {
                                        if (double.parse(value!) <=
                                            startPoint[index]) {
                                          return 'Invalid value.';
                                        }
                                        if (endPoint.length >= index + 1) {
                                          endPoint.removeAt(index);
                                          endPoint.insert(
                                              index, double.parse(value));
                                        } else {
                                          endPoint.insert(
                                              index, double.parse(value));
                                        }

                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: onSaveGoal,
                    label: const Text('Save items.'),
                    icon: const Icon(Icons.save_outlined),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: globals.buttonForegColor,
                        backgroundColor: globals.submitButtonBackColor),
                  ),
                ],
              )
            ],
          );
  }
}
