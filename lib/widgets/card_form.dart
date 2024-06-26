import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:synny_space/model/storage_card.dart';

class CardForm extends StatefulWidget {
  CardForm({super.key, this.givenItem, this.editItem, this.barcode});

  StorageCard? givenItem;
  //void Function(bool imageFrom) addImage;
  void Function(StorageCard card, StorageCard newCard, bool isCanceled)?
      editItem;
  String? barcode;
  //bool? isCanceled;
  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();

  late XFile? file;
  String selectedImageName = '';
  String imageUrl = '';
  bool imageChanged = false;

  double newQuantity = 1.0;
  var newMeasureValue = 100.0;
  var newTitle = '';

  String? newBarcode;
  bool barcodeChanged = false;
  bool cathegoryChanged = false;
  bool measureUnitChanged = false;
  bool itemProvided = false;
  String categorisStringInitial = 'авто';
  String measureStringInitial = 'кг';
  Map<Cathegory, String> categorisString = {
    Cathegory.auto: 'авто',
    Cathegory.amunition: 'амуніція',
    Cathegory.drinks: 'напої',
    Cathegory.food: 'продукти',
    Cathegory.hygiene: 'гігієна',
    Cathegory.medicine: 'медицина',
    Cathegory.canc: 'канцелярія',
    Cathegory.electronics: 'електроніка',
  };
  Map<MeasureUnit, String> measuresString = {
    MeasureUnit.grams: 'грам',
    MeasureUnit.kg: 'кг',
    MeasureUnit.liters: 'літр',
    MeasureUnit.metr: 'метр',
    MeasureUnit.mg: 'мг',
    MeasureUnit.ml: 'мл',
    MeasureUnit.pairs: 'пар',
    MeasureUnit.pcs: 'штук',
    MeasureUnit.size: 'розмір',
    MeasureUnit.tonn: 'тон',
  };
  Cathegory _newCathegory = Cathegory.food;
  MeasureUnit _newMeasureUnit = MeasureUnit.kg;

  void addImage(bool imageFrom) async {
    ImagePicker imagePicker = ImagePicker();
    file = await imagePicker.pickImage(
      source: imageFrom ? ImageSource.camera : ImageSource.gallery,
    );
    if (file != null) {
      setState(() {
        selectedImageName = file!.name;
        imageChanged = true;
      });
    }
  }

  Future<void> _scanBarcode() async {
    String scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Скасувати', true, ScanMode.BARCODE);
    setState(() {
      newBarcode = scannedBarcode;
      barcodeChanged = true;
    });
  }

  Widget noValueAlert() {
    return AlertDialog(
        actions: [
          ElevatedButton(
              onPressed: Navigator.of(context).pop, child: const Text('Добре'))
        ],
        content: const Text('Будь ласка, додайте зображення'),
        title: const Text('Відсутнє зображення '));
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
                title: const Text('Камера'),
                onTap: () {
                  addImage(true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                  title: const Text('Галерея'),
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
      return null;
      //return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAeFBMVEX///8AAADk5OTo6OhgYGDy8vJOTk6NjY2YmJg0NDS2trbb29v4+PhcXFyjo6Orq6vMzMzt7e2CgoIhISELCwtlZWV1dXVCQkKenp4mJibAwMDX19c8PDwwMDCEhIRJSUlra2t5eXmysrIcHBxVVVUVFRWRkZG8vLzKqIDWAAAExElEQVR4nO2a63KyOhRARbxVsYrXatV6ae37v+En2SBJSAB7nOMws9aPjk1okoVk7yS01QIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABoGpNjx8Uh1K4JpWymFUWqZDyzm0tr35eDbnXf8bC/uncYaxXdsXNQneV79Lhg4GGtXdROy4Z50UxKvtytftyqjpV9nxdGh9rgu75RBYOHDZfetrQvMTNctLOSbVrSczba3SR1bWddzszqcFTH0N1hGUdvW9pTkxkG47Qgnpd2KP4f5T337Q61O+I3HPsb9LD1NbXULrobBu9ScP/m3YYnVfdd2vG5rEO/4eRhw9bnta+4ficNXPopQ31K54byKOWT12kY7aUydlVm3colm1PW4VmvFcN7Xc70ccGcJDoEb84qzTAJLWFQbjhKK7clvclj/uW5CWIYuiv/zKDKUIWPoN9qfakPe6/he2roSSUJ6oEJfnzBSAyrQtWjVBpOZdxTEeidvYa91HBR3tetKV/9iwxjUdtIFhv9+gzzMDFy1Cak4c2f215k2G6N8wnYbw19hr/3izz5IpR71PGP5WWGecS5LUC8hqv7Ve58Eck83pUswF5mmKeJ2/PnNVQRSb4m59r0IJP0s2QsrzPMntNkBvkMJdNd1U9XvkgD1tBRdeeFhpIK1XrbZyhxMvpJfrryRS+dx2W80FAy9TX55DPsSRQ5eeaaLAc25WN5paFakarVqcdQrp2kEbU42WQqV6y+Xml4TuOM13CYRiJ5nt8L9WozM6/YyIrhKBIeVvFQz7A12K1lkewxXGVPp1qYLQv1naT4WDEWMdzvdm8Ju8e3vU5qGrayW+o2jFSuONw+qWj6U8gXKhqfKsZi757+05biTl3DDLfh531E8qmQL8a+GKtjG5ZH3ro8x1Dt3OfJNye7xIKLMrxWjMU2/MO+18FzDNdJqaw41Yzc2xeMjQA0muRoe0XL8KvGuV0NnmIYB7nA2fVXpqFxhlI4iRpOU54UTZ9iONTGmmVGE8NwWWr4v+/x6xge9UbUHsLeXxiG41LD12T8HJdhpC6cxWFCLOeF1hwyDD8aZyj7hkWG+s3KF4ZhNOiMb3w3x/AQFLHyhRlLhW5zDNcOw515SbMN2w5B+zyq2YbuF1mmTrMNVXrbjXK0FU6GMjyYTTXGML4kRfoqWbV5MY7uleHK1X4DDGUNpu90JHsY+UKtVudmkpS0qC1hnrqmicK2lp/38kvYNoZQ01C18KYvIqM3+1tNV6vrbdrRratPObvSY64YTkOTdjv8wwq1nb1ksPjR33bVNNwlJWb6m9lj98TbwDzj974/XPteFPhx5WhBu131DNP3N8ZF0+Jf2i+3M/Rr/G9Ijw8bdrxtFd7jVxmq2WTNsEidPprJ4dvZnXFnnvkev/A2/Y7+rxFqhWktoaf2LVXK9nmDav/XLDsVO9ubX/0zv8Nw7G5pY5y6nzfB3N7oRadFsDbOQ6+XYGWHgmgVXApHZduVsbzbdybW3fMa9h6fh7csFrqwRhqFjoOE2A7nXddL69h1BBGV9JXgHNONmk4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADQIP4BoMgxw01zYggAAAAASUVORK5CYII=';
    }
  }

  changeImage() async {
    try {
      firebase_storage.UploadTask? changeTask;

      firebase_storage.FirebaseStorage.instance
          .refFromURL(widget.givenItem!.image)
          .delete();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('Item-images')
          .child(file!.name);
      changeTask = ref.putFile(File(file!.path));
      await changeTask.whenComplete(() => null);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
      //return true;
    } catch (e) {
      return null;
      // return 'https://firebasestorage.googleapis.com/v0/b/sunny-base.appspot.com/o/Item-images%2F7170133d-f506-4ce0-b656-0db67be8e0dc1844032090079325120.jpg?alt=media&token=22adb994-97cb-45d4-869e-1fe04462d655';
    }
  }

  void onSaveItem() async {
    if (_formKey.currentState!.validate()) {
      if (!itemProvided) {
        if (selectedImageName.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return noValueAlert();
            },
          );
          return;
        }
      }
      _formKey.currentState!.save();
      String imgUrl = itemProvided
          ? imageChanged
              ? await changeImage()
              : widget.givenItem!.image
          : imageChanged
              ? await uploadImage()
              : 'Немає зображення';

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
      if (!itemProvided) {
        final url = Uri.https(
            'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
            'item-list.json');
        final response = await http.post(
          url,
          headers: {'Content-type': 'application/json'},
          body: json.encode(
            {
              'image': imgUrl,
              'quantity': newQuantity,
              'title': newTitle,
              'barcode': newBarcode,
              'cathegory': categorisString[_newCathegory],
              'measureVolume': newMeasureValue,
              'measureUnit': measuresString[_newMeasureUnit],
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
            barcode:
                newBarcode != null ? int.parse(newBarcode!) : 'Код не задано',
            image: imgUrl,
            quantity: newQuantity,
            title: newTitle,
            cathegory: categorisString[_newCathegory]!,
            measureVolume: newMeasureValue,
            measureUnit: measuresString[_newMeasureUnit]!));
      } else {
        final url = Uri.https(
            'sunny-base-default-rtdb.europe-west1.firebasedatabase.app',
            'item-list/${widget.givenItem!.id}.json');
        await http.patch(
          url,
          headers: {'Content-type': 'application/json'},
          body: json.encode(
            {
              'image': imgUrl,
              'quantity': newQuantity,
              'title': newTitle,
              'barcode': newBarcode,
              'cathegory': categorisString[_newCathegory],
              'measureVolume': newMeasureValue,
              'measureUnit': measuresString[_newMeasureUnit],
            },
          ),
        );
        //!!!!!!!!!!!!!!!!!   CHANGE LATER    !!!!!!!!!!!!!!!!!!!
        //!!!!!!!!!!!!!!!!!   CHANGE LATER    !!!!!!!!!!!!!!!!!!!
        final itemToPass = StorageCard(
            id: widget.givenItem!
                .id, //!!!!!!!!!!!!!!!!!   CHANGE LATER    !!!!!!!!!!!!!!!!!!!
            barcode: int.parse(newBarcode!),
            image: imgUrl,
            quantity: newQuantity,
            title: newTitle,
            cathegory: categorisString[_newCathegory]!,
            measureVolume: newMeasureValue,
            measureUnit: measuresString[_newMeasureUnit]!);

        widget.editItem!(widget.givenItem!, itemToPass, false);
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    itemProvided = (widget.givenItem != null);
    selectedImageName = imageChanged
        ? selectedImageName
        : itemProvided
            ? widget.givenItem!.image
            : '';
    imageUrl = imageChanged
        ? ''
        : itemProvided
            ? widget.givenItem!.image
            : '';
    if (widget.barcode != null && !barcodeChanged) {
      newBarcode = widget.barcode;
    } else {
      newBarcode = barcodeChanged
          ? newBarcode
          : itemProvided
              ? widget.givenItem!.barcode.toString()
              : 'Немає коду';
    }
    _newCathegory = cathegoryChanged
        ? _newCathegory
        : itemProvided
            ? categorisString.entries
                .firstWhere(
                    (entry) => entry.value == widget.givenItem!.cathegory)
                .key
            : _newCathegory;
    _newMeasureUnit = measureUnitChanged
        ? _newMeasureUnit
        : itemProvided
            ? measuresString.entries
                .firstWhere(
                    (entry) => entry.value == widget.givenItem!.measureUnit)
                .key
            : _newMeasureUnit;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  //maxLength: 40,
                  initialValue:
                      itemProvided ? widget.givenItem!.title : newTitle,
                  decoration: const InputDecoration(
                    label: Text('Назва товару: '),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length >= 50) {
                      return 'Некоректна назва';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    newTitle = value!;
                  },
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              Expanded(
                child: DropdownButtonFormField(
                  value: _newCathegory,
                  items: (Cathegory.values)
                      .map(
                        (cathegory) => DropdownMenuItem(
                          value: cathegory,
                          child:
                              Text(categorisString[cathegory]!.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newCathegory = value!;
                      cathegoryChanged = true;
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
                  initialValue: itemProvided
                      ? widget.givenItem!.quantity.toString()
                      : newQuantity.toString(),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    label: Text('Кількість:'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length >= 50) {
                      return 'Некоректна кількість';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    newQuantity = double.parse(value!);
                  },
                ),
              ),
              const Spacer(),
              Expanded(
                child: TextFormField(
                  initialValue: itemProvided
                      ? widget.givenItem!.measureVolume.toString()
                      : newMeasureValue.toString(),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    label: Text('Об\'єм:'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length >= 50) {
                      return 'Некоректний об\'єм';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    newMeasureValue = double.parse(value!);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: DropdownButtonFormField(
                  padding: const EdgeInsets.only(top: 8),
                  value: _newMeasureUnit,
                  items: MeasureUnit.values
                      .map(
                        (measureUnit) => DropdownMenuItem(
                          value: measureUnit,
                          child: Text(measuresString[measureUnit]!),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newMeasureUnit = value!;
                      measureUnitChanged = true;
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
                child: selectedImageName.isEmpty
                    ? OutlinedButton.icon(
                        onPressed: showImageDialog,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text(
                          'Додати зображення',
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
                            child: itemProvided
                                ? imageChanged
                                    ? Image.file(File(file!.path))
                                    : Image.network(imageUrl)
                                : Image.file(
                                    File(file!.path),
                                  ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          OutlinedButton.icon(
                            onPressed: showImageDialog,
                            label: const Text('Змінити'),
                            icon: const Icon(Icons.add_a_photo_outlined),
                          ),
                        ],
                      ),
              ),
              const Spacer(),
              Container(
                child: (int.tryParse(newBarcode!) == null)
                    ? OutlinedButton.icon(
                        onPressed: _scanBarcode,
                        icon: const Icon(CupertinoIcons.barcode),
                        label: const Text('Додати штрих-код'),
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
                                Text(
                                  itemProvided
                                      ? 'Код змінено!\nВи можете змінити його знову натиснувши кнопку.'
                                      : 'Код додано!\nВи можете змінити його натиснувши кнопку',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 14, 150, 19)),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  barcodeChanged
                                      ? 'Новий код: \n$newBarcode'
                                      : 'Код: \n$newBarcode',
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
                              onPressed: _scanBarcode,
                              label: const Text('Змінити'),
                              icon: const Icon(
                                  CupertinoIcons.barcode_viewfinder)),
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
                  if (widget.givenItem != null) {
                    final itemToPass = StorageCard(
                        id: widget.givenItem!
                            .id, //!!!!!!!!!!!!!!!!!   CHANGE LATER    !!!!!!!!!!!!!!!!!!!
                        barcode: widget.givenItem!.barcode,
                        image: widget.givenItem!.image,
                        quantity: widget.givenItem!.quantity,
                        title: widget.givenItem!.title,
                        cathegory: widget.givenItem!.cathegory,
                        measureVolume: widget.givenItem!.measureVolume,
                        measureUnit: widget.givenItem!.measureUnit);

                    widget.editItem!(widget.givenItem!, itemToPass, true);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Скасувати'),
              ),
              FilledButton(
                onPressed: onSaveItem,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 16, 104, 176)),
                child: const Text('Зберегти'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
