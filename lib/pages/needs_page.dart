import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:synny_space/model/needs_card.dart';
import 'package:synny_space/model/storage_card.dart';
import 'package:synny_space/screens/add_need.dart';
import 'package:synny_space/custom_pacages/globals.dart' as globals;

class NeedsPage extends StatefulWidget {
  NeedsPage(
      {super.key, required this.listOfItems, required this.addNewItemToList});

  List<StorageCard> listOfItems;
  void Function(StorageCard item) addNewItemToList;
  @override
  State<NeedsPage> createState() => _NeedsPageState();
}

class _NeedsPageState extends State<NeedsPage> {
  void _openAddNeedWindow() async {
    final newItem = await Navigator.of(context).push<NeedsCard>(
      MaterialPageRoute(
        builder: (ctx) => AddNeed(
          listOfItems: widget.listOfItems,
          addNewItemToList: widget.addNewItemToList,
        ),
      ),
    );
    if (newItem == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.find_in_page_outlined,
              size: 50.0,
            ),
            Text(
              'There is no needs. \nYou can add some!',
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoSlab(fontSize: 24, letterSpacing: 3),
            )
          ],
        ),
      ),
    );

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: _openAddNeedWindow,
            shape: const CircleBorder(),
            backgroundColor: globals.buttonForegColor,
            foregroundColor: globals.buttonBackColor,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}
