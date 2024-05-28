import 'package:flutter/material.dart';
//import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:synny_space/items_list/stored_item.dart';
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/model/storage_card.dart';

class FinalNeedsList extends StatefulWidget {
  const FinalNeedsList(
      {super.key,
      required this.chosenNeedItems,
      required this.chosenItemStarts,
      required this.chosenItemGoals,
      required this.onAddQuantity,
      required this.needsCardLocal});

  final NeedsCard needsCardLocal;
  final List<StorageCard> chosenNeedItems;
  final List<double> chosenItemStarts;
  final List<double> chosenItemGoals;
  final void Function(NeedsCard, int) onAddQuantity;

  @override
  State<FinalNeedsList> createState() => _FinalNeedsListState();
}

class _FinalNeedsListState extends State<FinalNeedsList> {
  onAddQuantity(int index, TextEditingController addController) {
    setState(() {
      widget.chosenItemStarts[index] += int.parse(addController.text);
      widget.needsCardLocal.childStartPoints![index] = widget.chosenItemStarts[index];
    });
  }

  Widget finalList(int index) {
    double progres =
        widget.chosenItemStarts[index] / widget.chosenItemGoals[index];
    final addController = TextEditingController();
    @override
    void dispose() {
      addController.dispose();
      super.dispose();
    }

    return Column(
      children: [
        StoredItem(
                   
          widget.chosenNeedItems[index],
          isShrinked: true,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.chosenItemStarts[index].toString()),
                          Text(widget.chosenItemGoals[index].toString()),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 6,
                            child: LinearProgressIndicator(
                              color: const Color.fromARGB(255, 255, 166, 0),
                              borderRadius: BorderRadius.circular(8),
                              value: progres,
                              semanticsLabel: 'progres',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Прогрес: ${(progres * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: TextField(
                    enabled: widget.chosenItemStarts[index] <
                        widget.chosenItemGoals[index],
                    keyboardType: TextInputType.number,
                    controller: addController,
                  ),
                ),
              ),
              IconButton.outlined(
                onPressed: () {
                  onAddQuantity(index, addController);
                },
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
              IconButton.filled(
                onPressed: () {widget.onAddQuantity(widget.needsCardLocal, index);},
                icon: const Icon(Icons.save),
                color: Colors.white,
                style: IconButton.styleFrom(backgroundColor: Colors.blue),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate( widget.chosenNeedItems.length, (index) {
        
        return finalList(index);
      }),
    );
  }
}
