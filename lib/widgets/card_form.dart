import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:synny_space/model/storage_card.dart';

class CardForm extends StatefulWidget {
  CardForm(
      {super.key,
      required this.formKey,
      required this.enteredTitle,
      required this.pickedCathegory,
      required this.enteredQuantity,
      required this.enteredMeasureValue,
      required this.pickedMeasureUnit,
      required this.imageUrl,
      required this.selectedImageName,
      required this.scannedBarcode,
      required this.showImageDialog,
      required this.scanBarcode,
      required this.onSaveItem,
      required this.addImage,
      required this.uploadImage });
  var enteredQuantity = 1;
  var enteredMeasureValue = 100.0;
  var enteredTitle = '';
  Cathegory pickedCathegory = Cathegory.food;
  MeasureUnit pickedMeasureUnit = MeasureUnit.kg;
  void Function() showImageDialog;
  Future<void> Function() scanBarcode;
  void Function() onSaveItem;
  void Function(bool imageFrom) addImage;
  dynamic uploadImage;

  final formKey;

  String selectedImageName = '';
  String imageUrl;
  late XFile? file;
  String scannedBarcode = 'No code yet';
  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  //maxLength: 40,
                  decoration: const InputDecoration(
                    label: Text('Назва товару: '),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length >= 50) {
                      return 'Incorrect title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    widget.enteredTitle = value!;
                  },
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              Expanded(
                child: DropdownButtonFormField(
                  value: widget.pickedCathegory,
                  items: (Cathegory.values)
                      .map(
                        (cathegory) => DropdownMenuItem(
                          value: cathegory,
                          child: Text(cathegory.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.pickedCathegory = value!;
                    });
                  },
                ),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.enteredQuantity.toString(),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    label: Text('Кількість:'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length >= 50) {
                      return 'Incorrect quantity';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    widget.enteredQuantity = int.parse(value!);
                  },
                ),
              ),
              const Spacer(),
              Expanded(
                child: TextFormField(
                  initialValue: widget.enteredMeasureValue.toString(),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    label: Text('Об\'єм:'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length >= 50) {
                      return 'Incorrect Volume';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    widget.enteredMeasureValue = double.parse(value!);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: DropdownButtonFormField(
                  padding: const EdgeInsets.only(top: 8),
                  value: widget.pickedMeasureUnit,
                  items: MeasureUnit.values
                      .map(
                        (measureUnit) => DropdownMenuItem(
                          value: measureUnit,
                          child: Text(measureUnit.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.pickedMeasureUnit = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                //padding: const EdgeInsets.all(20),
                child: widget.selectedImageName.isEmpty
                    ? OutlinedButton.icon(
                        onPressed: widget.showImageDialog,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text(
                          'Add item image',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                          fixedSize: const Size(160, 85),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(10, 10),
                            ),
                          ),
                          foregroundColor:
                              const Color.fromARGB(255, 127, 38, 210),
                          //backgroundColor: const Color.fromARGB(255, 192, 192, 192) ,
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: 160,
                            child: Image.file(
                              File(widget.file!.path),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          OutlinedButton.icon(
                            onPressed: widget.showImageDialog,
                            label: const Text('Change'),
                            icon: const Icon(Icons.add_a_photo_outlined),
                          ),
                        ],
                      ),
              ),
              const Spacer(),
              Container(
                child: (int.tryParse(widget.scannedBarcode) == null)
                    ? OutlinedButton.icon(
                        onPressed: widget.scanBarcode,
                        icon: const Icon(CupertinoIcons.barcode),
                        label: const Text('Add barcode'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          fixedSize: const Size(160, 85),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(10, 10),
                            ),
                          ),
                          foregroundColor:
                              const Color.fromARGB(255, 127, 38, 210),
                          //backgroundColor: Color.fromARGB(14, 83, 83, 83) ,
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: 160,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.check_mark_circled,
                                  color: Color.fromARGB(255, 14, 150, 19),
                                ),
                                const Text(
                                  'Code Added!\nYou can change it by pressing button below',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 14, 150, 19)),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Code is: \n${widget.scannedBarcode}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          OutlinedButton.icon(
                              onPressed: widget.scanBarcode,
                              label: const Text('Change'),
                              icon: const Icon(CupertinoIcons.barcode)),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: widget.onSaveItem,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 16, 104, 176)),
                child: const Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
