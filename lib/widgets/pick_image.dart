import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  // final void Function() showBottomSheet;
  // final void Function(bool source) addImage;

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  String selectedImageName = '';
  late XFile? file;

  void _showDialog() {
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
                  _addImage(true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                  title: const Text('Галерея'),
                  onTap: () {
                    _addImage(false);
                    Navigator.pop(context);
                  })
            ],
          ),
        ));
      },
    );
  }

  void _addImage(bool imageFrom) async {
    ImagePicker imagePicker = ImagePicker();
    file = await imagePicker.pickImage(
        source: imageFrom ? ImageSource.camera : ImageSource.gallery);
    if (file != null) {
      setState(() {
        selectedImageName = file!.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        //padding: const EdgeInsets.all(20),
        child: selectedImageName.isEmpty
            ? OutlinedButton.icon(
                onPressed: _showDialog,
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
                  foregroundColor: const Color.fromARGB(255, 127, 38, 210),
                  //backgroundColor: const Color.fromARGB(255, 192, 192, 192) ,
                ),
              )
            : Column(
                children: [
                  SizedBox(
                    height: 200,
                    width: 160,
                    child: Image.file(
                      File(file!.path),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showDialog,
                    label: const Text('Змінити'),
                    icon: const Icon(Icons.add_a_photo_outlined),
                  ),
                ],
              ));
  }
}
