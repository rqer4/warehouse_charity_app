// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CardNotFounded extends StatelessWidget {
//   CardNotFounded({super.key, this.findCard, this.createNewItem});
//   Function(int? code)? findCard;
//   Function(String barcode)? createNewItem;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//               'Item not found. \nYou can try again, or create new item by pressing button below.',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.robotoSlab(
//                   fontSize: 24, fontStyle: FontStyle.italic)),
//           const SizedBox(
//             height: 70,
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               findCard!(null);
//             },
//             icon: const Icon(CupertinoIcons.barcode_viewfinder),
//             label: const Text('Find by code!'),
//             style: ElevatedButton.styleFrom(
//               minimumSize: const Size(200, 40),
//               // backgroundColor: buttonBackColor,
//               // foregroundColor: buttonForegColor),
//             ),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               createNewItem(scannedBarcode!);
//             },
//             icon: const Icon(CupertinoIcons.add),
//             label: const Text('Create new item!'),
//             style: ElevatedButton.styleFrom(
//               minimumSize: const Size(200, 40),
//               // backgroundColor: buttonBackColor,
//               // foregroundColor: buttonForegColor),
//             ),
//           ),
//           TextButton.icon(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             label: const Text('Back to list.'),
//             icon: const Icon(Icons.keyboard_backspace_rounded),
//           )
//         ]);
//   }
// }
