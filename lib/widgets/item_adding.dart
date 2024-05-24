import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:synny_space/model/storage_card.dart';
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
  var enteredQuantity = 1;
  var enteredMeasureValue = 100.0;
  var enteredTitle = '';
  final Cathegory _pickedCathegory = Cathegory.food;
  final MeasureUnit _pickedMeasureUnit = MeasureUnit.kg;

  final _formKey = GlobalKey<FormState>();

  String selectedImageName = '';
  String imageUrl = '';
  late XFile? file;
  String scannedBarcode = 'No code yet';

  Future<void> _scanBarcode() async {
    String scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    setState(() {
      this.scannedBarcode = scannedBarcode;
    });
  }

  void showImageDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
            child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
          child: Wrap(
            children: [
              ListTile(
                title: const Text('Camera'),
                onTap: () {
                  addImage(true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                  title: const Text('Gallery'),
                  onTap: () {
                    addImage(false);
                    Navigator.pop(context);
                  })
            ],
          ),
        ));
      },
    );
  }

  void addImage(bool imageFrom) async {
    ImagePicker imagePicker = ImagePicker();
    file = await imagePicker.pickImage(
      source: imageFrom ? ImageSource.camera : ImageSource.gallery,
    );
    if (file != null) {
      setState(() {
        selectedImageName = file!.name;
      });
    }
  }

  uploadImage() async {
    try {
      firebase_storage.UploadTask? uploadTask;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('Item-images')
          .child(file!.name);
      uploadTask = ref.putFile(File(file!.path));
      await uploadTask.whenComplete(() => null);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
      //return true;
    } catch (e) {
      print(e);
      return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAeFBMVEX///8AAADk5OTo6OhgYGDy8vJOTk6NjY2YmJg0NDS2trbb29v4+PhcXFyjo6Orq6vMzMzt7e2CgoIhISELCwtlZWV1dXVCQkKenp4mJibAwMDX19c8PDwwMDCEhIRJSUlra2t5eXmysrIcHBxVVVUVFRWRkZG8vLzKqIDWAAAExElEQVR4nO2a63KyOhRARbxVsYrXatV6ae37v+En2SBJSAB7nOMws9aPjk1okoVk7yS01QIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABoGpNjx8Uh1K4JpWymFUWqZDyzm0tr35eDbnXf8bC/uncYaxXdsXNQneV79Lhg4GGtXdROy4Z50UxKvtytftyqjpV9nxdGh9rgu75RBYOHDZfetrQvMTNctLOSbVrSczba3SR1bWddzszqcFTH0N1hGUdvW9pTkxkG47Qgnpd2KP4f5T337Q61O+I3HPsb9LD1NbXULrobBu9ScP/m3YYnVfdd2vG5rEO/4eRhw9bnta+4ficNXPopQ31K54byKOWT12kY7aUydlVm3colm1PW4VmvFcN7Xc70ccGcJDoEb84qzTAJLWFQbjhKK7clvclj/uW5CWIYuiv/zKDKUIWPoN9qfakPe6/he2roSSUJ6oEJfnzBSAyrQtWjVBpOZdxTEeidvYa91HBR3tetKV/9iwxjUdtIFhv9+gzzMDFy1Cak4c2f215k2G6N8wnYbw19hr/3izz5IpR71PGP5WWGecS5LUC8hqv7Ve58Eck83pUswF5mmKeJ2/PnNVQRSb4m59r0IJP0s2QsrzPMntNkBvkMJdNd1U9XvkgD1tBRdeeFhpIK1XrbZyhxMvpJfrryRS+dx2W80FAy9TX55DPsSRQ5eeaaLAc25WN5paFakarVqcdQrp2kEbU42WQqV6y+Xml4TuOM13CYRiJ5nt8L9WozM6/YyIrhKBIeVvFQz7A12K1lkewxXGVPp1qYLQv1naT4WDEWMdzvdm8Ju8e3vU5qGrayW+o2jFSuONw+qWj6U8gXKhqfKsZi757+05biTl3DDLfh531E8qmQL8a+GKtjG5ZH3ro8x1Dt3OfJNye7xIKLMrxWjMU2/MO+18FzDNdJqaw41Yzc2xeMjQA0muRoe0XL8KvGuV0NnmIYB7nA2fVXpqFxhlI4iRpOU54UTZ9iONTGmmVGE8NwWWr4v+/x6xge9UbUHsLeXxiG41LD12T8HJdhpC6cxWFCLOeF1hwyDD8aZyj7hkWG+s3KF4ZhNOiMb3w3x/AQFLHyhRlLhW5zDNcOw515SbMN2w5B+zyq2YbuF1mmTrMNVXrbjXK0FU6GMjyYTTXGML4kRfoqWbV5MY7uleHK1X4DDGUNpu90JHsY+UKtVudmkpS0qC1hnrqmicK2lp/38kvYNoZQ01C18KYvIqM3+1tNV6vrbdrRratPObvSY64YTkOTdjv8wwq1nb1ksPjR33bVNNwlJWb6m9lj98TbwDzj974/XPteFPhx5WhBu131DNP3N8ZF0+Jf2i+3M/Rr/G9Ijw8bdrxtFd7jVxmq2WTNsEidPprJ4dvZnXFnnvkev/A2/Y7+rxFqhWktoaf2LVXK9nmDav/XLDsVO9ubX/0zv8Nw7G5pY5y6nzfB3N7oRadFsDbOQ6+XYGWHgmgVXApHZduVsbzbdybW3fMa9h6fh7csFrqwRhqFjoOE2A7nXddL69h1BBGV9JXgHNONmk4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADQIP4BoMgxw01zYggAAAAASUVORK5CYII=';
    }
  }

  Widget noValueAlert() {
    final bool isBarcode = int.tryParse(scannedBarcode) == null;
    return AlertDialog(
      actions: [
        ElevatedButton(
            onPressed: Navigator.of(context).pop, child: const Text('Okay'))
      ],
      content: (selectedImageName.isEmpty && isBarcode)
          ? const Text('Please, add image and barcode')
          : (isBarcode)
              ? const Text('Please, add barcode')
              : const Text('Please, add image'),
      title: (selectedImageName.isEmpty && isBarcode)
          ? const Text('No image and barcode')
          : (isBarcode)
              ? const Text('No barcode')
              : const Text('No image'),
    );
  }

  void onSaveItem() async {
    if (_formKey.currentState!.validate()) {
      if (selectedImageName.isEmpty || (int.tryParse(scannedBarcode) == null)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return noValueAlert();
          },
        );
        return;
      }

      _formKey.currentState!.save();
      String imgUrl = await uploadImage();

      if (!context.mounted) {
        return;
      }
      final url = Uri.https(
          'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
          'item-list.json');
      final response = await http.post(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode(
          {
            'image': imgUrl,
            'quantity': enteredQuantity,
            'title': enteredTitle,
            'barcode': scannedBarcode,
            'cathegory': _pickedCathegory.name,
            'measureVolume': enteredMeasureValue,
            'measureUnit': _pickedMeasureUnit.name,
          },
        ),
      );
      //!!!!!!!!!!!!!!!!!   CHANGE LATER    !!!!!!!!!!!!!!!!!!!
      //!!!!!!!!!!!!!!!!!   CHANGE LATER    !!!!!!!!!!!!!!!!!!!
      Navigator.of(context).pop(StorageCard(
          id: json
              .decode(response.body)
              .toString()
              .replaceRange(
                0,
                7,
                '',
              )
              .replaceRange(20, 21,
                  ''), //!!!!!!!!!!!!!!!!!   CHANGE LATER    !!!!!!!!!!!!!!!!!!!
          barcode: int.parse(scannedBarcode),
          image: imgUrl,
          quantity: enteredQuantity,
          title: enteredTitle,
          cathegory: _pickedCathegory,
          measureVolume: enteredMeasureValue,
          measureUnit: _pickedMeasureUnit));
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
          child: CardForm(barcode: widget.barcode,)
          // Form(
          //   key: _formKey,
          //   child: Column(
          //     children: [
          //       Row(
          //         children: [
          //           Expanded(
          //             child: TextFormField(
          //               textCapitalization: TextCapitalization.sentences,
          //               //maxLength: 40,
          //               decoration: const InputDecoration(
          //                 label: Text('Назва товару: '),
          //               ),
          //               validator: (value) {
          //                 if (value == null ||
          //                     value.isEmpty ||
          //                     value.trim().length >= 50) {
          //                   return 'Incorrect title';
          //                 }
          //                 return null;
          //               },
          //               onSaved: (value) {
          //                 enteredTitle = value!;
          //               },
          //             ),
          //           ),
          //           const SizedBox(
          //             width: 25,
          //           ),
          //           Expanded(
          //             child: DropdownButtonFormField(
          //               value: _pickedCathegory,
          //               items: (Cathegory.values)
          //                   .map(
          //                     (cathegory) => DropdownMenuItem(
          //                       value: cathegory,
          //                       child: Text(cathegory.name.toUpperCase()),
          //                     ),
          //                   )
          //                   .toList(),
          //               onChanged: (value) {
          //                 setState(() {
          //                   _pickedCathegory = value!;
          //                 });
          //               },
          //             ),
          //           )
          //         ],
          //       ),
          //       Row(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Expanded(
          //             child: TextFormField(
          //               initialValue: enteredQuantity.toString(),
          //               keyboardType: TextInputType.number,
          //               maxLength: 5,
          //               decoration: const InputDecoration(
          //                 label: Text('Кількість:'),
          //               ),
          //               validator: (value) {
          //                 if (value == null ||
          //                     value.isEmpty ||
          //                     value.trim().length >= 50) {
          //                   return 'Incorrect quantity';
          //                 }
          //                 return null;
          //               },
          //               onSaved: (value) {
          //                 enteredQuantity = int.parse(value!);
          //               },
          //             ),
          //           ),
          //           const Spacer(),
          //           Expanded(
          //             child: TextFormField(
          //               initialValue: enteredMeasureValue.toString(),
          //               keyboardType: TextInputType.number,
          //               maxLength: 5,
          //               decoration: const InputDecoration(
          //                 label: Text('Об\'єм:'),
          //               ),
          //               validator: (value) {
          //                 if (value == null ||
          //                     value.isEmpty ||
          //                     value.trim().length >= 50) {
          //                   return 'Incorrect Volume';
          //                 }
          //                 return null;
          //               },
          //               onSaved: (value) {
          //                 enteredMeasureValue = double.parse(value!);
          //               },
          //             ),
          //           ),
          //           const SizedBox(
          //             width: 10,
          //           ),
          //           Expanded(
          //             child: DropdownButtonFormField(
          //               padding: const EdgeInsets.only(top: 8),
          //               value: _pickedMeasureUnit,
          //               items: MeasureUnit.values
          //                   .map(
          //                     (measureUnit) => DropdownMenuItem(
          //                       value: measureUnit,
          //                       child: Text(measureUnit.name),
          //                     ),
          //                   )
          //                   .toList(),
          //               onChanged: (value) {
          //                 setState(() {
          //                   _pickedMeasureUnit = value!;
          //                 });
          //               },
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(
          //         height: 20,
          //       ),
          //       Row(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Container(
          //             //padding: const EdgeInsets.all(20),
          //             child: selectedImageName.isEmpty
          //                 ? OutlinedButton.icon(
          //                     onPressed: showImageDialog,
          //                     icon: const Icon(Icons.add_a_photo_outlined),
          //                     label: const Text(
          //                       'Add item image',
          //                     ),
          //                     style: OutlinedButton.styleFrom(
          //                       padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
          //                       fixedSize: const Size(160, 85),
          //                       shape: const RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.all(
          //                           Radius.elliptical(10, 10),
          //                         ),
          //                       ),
          //                       foregroundColor:
          //                           const Color.fromARGB(255, 127, 38, 210),
          //                       //backgroundColor: const Color.fromARGB(255, 192, 192, 192) ,
          //                     ),
          //                   )
          //                 : Column(
          //                     children: [
          //                       SizedBox(
          //                         height: 200,
          //                         width: 160,
          //                         child: Image.file(
          //                           File(file!.path),
          //                         ),
          //                       ),
          //                       const SizedBox(
          //                               height: 5,
          //                             ),
          //                       OutlinedButton.icon(
          //                         onPressed: showImageDialog,
          //                         label: const Text('Change'),
          //                         icon: const Icon(Icons.add_a_photo_outlined),
          //                       ),
          //                     ],
          //                   ),
          //           ),
          //           const Spacer(),
          //           Container(
          //             child: (int.tryParse(scannedBarcode) == null)
          //                 ? OutlinedButton.icon(
          //                     onPressed: _scanBarcode,
          //                     icon: const Icon(CupertinoIcons.barcode),
          //                     label: const Text('Add barcode'),
          //                     style: OutlinedButton.styleFrom(
          //                       padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          //                       fixedSize: const Size(160, 85),
          //                       shape: const RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.all(
          //                           Radius.elliptical(10, 10),
          //                         ),
          //                       ),
          //                       foregroundColor:
          //                           const Color.fromARGB(255, 127, 38, 210),
          //                       //backgroundColor: Color.fromARGB(14, 83, 83, 83) ,
          //                     ),
          //                   )
          //                 : Column(
          //                     children: [
          //                       SizedBox(
          //                         height: 200,
          //                         width: 160,
          //                         child: Column(
          //                           mainAxisAlignment: MainAxisAlignment.center,
          //                           children: [
          //                             const Icon(
          //                               CupertinoIcons.check_mark_circled,
          //                               color: Color.fromARGB(255, 14, 150, 19),
          //                             ),
          //                             const Text(
          //                               'Code Added!\nYou can change it by pressing button below',
          //                               textAlign: TextAlign.center,
          //                               style: TextStyle(
          //                                   color:
          //                                       Color.fromARGB(255, 14, 150, 19)),
          //                             ),
          //                             const SizedBox(
          //                               height: 5,
          //                             ),
          //                             Text(
          //                               'Code is: \n$scannedBarcode',
          //                               textAlign: TextAlign.center,
          //                               style: const TextStyle(
          //                                   fontWeight: FontWeight.bold),
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                       const SizedBox(
          //                               height: 5,
          //                             ),
          //                       OutlinedButton.icon(
          //                           onPressed: _scanBarcode,
          //                           label: const Text('Change'),
          //                           icon: const Icon(CupertinoIcons.barcode)),
          //                     ],
          //                   ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(
          //         height: 15,
          //       ),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         children: [
          //           TextButton(
          //             onPressed: () {
          //               Navigator.pop(context);
          //             },
          //             child: const Text('Cancel'),
          //           ),
          //           FilledButton(
          //             onPressed: onSaveItem,
          //             style: FilledButton.styleFrom(
          //                 backgroundColor:
          //                     const Color.fromARGB(255, 16, 104, 176)),
          //             child: const Text('Save'),
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // ),
          ),
    );
  }
}
