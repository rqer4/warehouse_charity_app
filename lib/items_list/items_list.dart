import 'package:flutter/material.dart';
import 'package:synny_space/items_list/stored_item.dart';
import 'package:synny_space/model/storage_card.dart';
import 'package:flutter_spinbox/material.dart';

import 'package:synny_space/custom_pacages/globals.dart' as globals;

class ItemsList extends StatefulWidget {
  const ItemsList(
      {super.key,
      required this.itemsList,
      required this.removeItem,
      this.isForNeeds});

  final bool? isForNeeds;
  final List<StorageCard> itemsList;
  final void Function(StorageCard itemCard) removeItem;

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  double startPoint = 0;
  double endPoint = 1;

  @override
  Widget build(context) {
    final List<GlobalObjectKey<FormState>> formKeyList = List.generate(
        widget.itemsList.length, (index) => GlobalObjectKey<FormState>(index));

    void onSaveGoal(int index) {
      formKeyList[index].currentState!.validate();
    }

    return widget.isForNeeds == null
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.itemsList.length,
            itemBuilder: (ctx, index) => Dismissible(
              key: ValueKey(widget.itemsList[index]),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                widget.removeItem(widget.itemsList[index]);
              },
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
                  itemCount: widget.itemsList.length,
                  itemBuilder: (ctx, index) => Dismissible(
                    key: ValueKey(widget.itemsList[index]),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      widget.removeItem(widget.itemsList[index]);
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
                                    child: SpinBox(
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
                                      onSubmitted: (value) {
                                        startPoint = value;
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
                                      onSubmitted: (value) {
                                        endPoint = value;
                                      },
                                      validator: (value) {
                                        if (double.parse(value!) <=
                                            startPoint) {
                                          return 'Invalid value.';
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
                    onPressed: () {},
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
