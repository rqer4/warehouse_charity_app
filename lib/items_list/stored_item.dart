//import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:flutter/material.dart';
import 'package:synny_space/model/storage_card.dart';
import 'package:widget_zoom/widget_zoom.dart';

class StoredItem extends StatelessWidget {
  StoredItem(this.item, {super.key, this.isShrinked});

  bool? isShrinked;
  final StorageCard item;

  @override
  Widget build(BuildContext context) {
    bool isInStock = item.quantity > 0;
    Color mainColor1 = isInStock ? Colors.black : Colors.grey;
    Color mainColor2 = Colors.grey;
    return Card(
      //color: isInStock? Color.fromARGB(255, 245, 240, 248): Color.fromARGB(255, 218, 218, 218),

      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isShrinked == null
            ? Column(
                //crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: mainColor1),
                      ),
                      isInStock
                          ? const Text('')
                          : const Text(
                              'Not in stock',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      Text(
                        item.cathegory.name.toUpperCase().toString(),
                        style: TextStyle(color: mainColor2),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      WidgetZoom(
                        heroAnimationTag: item.id,
                        zoomWidget: Image.network(
                          item.image.toString(),
                          width: 80,
                          height: 80,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.measureVolume.toString()} ${item.measureUnit.name.toString()}',
                            style: TextStyle(
                              color: mainColor1,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Text(
                            'Quantity: ${item.quantity.toString()}',
                            style: TextStyle(
                              color: mainColor1,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '[${item.barcode}]',
                            textAlign: TextAlign.left,
                            style: TextStyle(color: mainColor2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetZoom(
                      heroAnimationTag: '${item.id}${DateTime.now().millisecondsSinceEpoch}',
                      zoomWidget: Image.network(
                        item.image.toString(),
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.cathegory.name.toUpperCase().toString(),
                          style: TextStyle(color: mainColor2),
                        ),
                        Text(
                          item.title,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: mainColor1),
                        ),
                        Text(
                          '${item.measureVolume.toString()} ${item.measureUnit.name.toString()}',
                          style: TextStyle(
                            color: mainColor1,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          'На складі: ${item.quantity.toString()}',
                          style: TextStyle(
                            color: mainColor1,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
      ),
    );
  }
}
