import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
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
      required this.needsCardLocal,
      required this.updateTotalProgres});

  final NeedsCard needsCardLocal;
  final List<StorageCard> chosenNeedItems;
  final List<double> chosenItemStarts;
  final List<double> chosenItemGoals;
  final void Function(NeedsCard, int) onAddQuantity;
  final void Function(NeedsCard) updateTotalProgres;

  @override
  State<FinalNeedsList> createState() => _FinalNeedsListState();
}

class _FinalNeedsListState extends State<FinalNeedsList> {
  onAddQuantity(int index, double value) {
    if (value <= 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter number'),
            content: const Text(
                'Looks like you did\'n entered value, plese, enter number you want to add.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Okay'))
            ],
          );
        },
      );
      return;
    }

    setState(() {
      widget.chosenItemStarts[index] += value;
      widget.needsCardLocal.childStartPoints![index] =
          widget.chosenItemStarts[index];
      widget.updateTotalProgres(widget.needsCardLocal);
      widget.onAddQuantity(widget.needsCardLocal, index);
    });
    
      
  }

  Widget finalList(int index) {
    double progres =
        widget.chosenItemStarts[index] / widget.chosenItemGoals[index];

    double addedValue = 1;
    return Column(
      children: [
        StoredItem(
          widget.chosenNeedItems[index],
          isShrinked: true,
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    //height: 45,

                    width: 100,
                    child: SpinBox(
                      spacing: 0,
                      textAlign: TextAlign.center,
                      max: 1000000,
                      iconSize: 15,
                      decoration: const InputDecoration(
                          label: Text(
                        'Add:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      min: 1,
                      value: 1,
                      enabled: progres < 1,
                      validator: (value) {
                        if (value!.isNotEmpty && double.parse(value) <= 0) {
                          return 'Invalid value';
                        }
                        addedValue = double.parse(value);
                        return null;
                      },
                    ),
                    //     TextField(

                    //       decoration: InputDecoration(
                    //           border: OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(5))),
                    //       enabled: widget.chosenItemStarts[index] <
                    //           widget.chosenItemGoals[index],
                    //       keyboardType: TextInputType.number,
                    //       controller: addController,
                    //     ),
                    //   ),
                  ),
                  IconButton.filled(
                    onPressed: progres < 1
                        ? () {
                            onAddQuantity(index, addedValue);
                          }
                        : () {},
                    icon: const Icon(Icons.save),
                    color: Colors.white,
                    style: IconButton.styleFrom(backgroundColor: Colors.blue),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(widget.chosenNeedItems.length, (index) {
        return finalList(index);
      }),
    );
  }
}
