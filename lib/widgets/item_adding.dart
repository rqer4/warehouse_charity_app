import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synny_space/widgets/card_form.dart';

class ItemAdding extends StatefulWidget {
  ItemAdding({super.key, this.barcode });

  

  //final void Function(StorageCard newItem) onAddItem;
  static const barcodeIcon = IconData(0xf586,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  String? barcode;
  @override
  State<StatefulWidget> createState() {
    return _ItemAddingState();
  }
}

class _ItemAddingState extends State<ItemAdding> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          child: CardForm(barcode: widget.barcode,)
          ),
    );
  }
}
