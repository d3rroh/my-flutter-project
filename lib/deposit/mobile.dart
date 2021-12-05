import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  //Get external storage directory
  final directory = await getExternalStorageDirectory();

  //Get directory path
  final path = directory!.path;

  //Create an empty file to write PDF data
  File file = File('$path/Output.pdf');

  //Write PDF data
  await file.writeAsBytes(bytes, flush: true);

  //Open the PDF document in mobile
  OpenFile.open('$path/Output.pdf');
}

Future<void> _createPDF() async {
  //Create a new PDF document
  PdfDocument document = PdfDocument();

  //Add a new page and draw text
  PdfPage page = document.pages.add();

  document.form.fields.add(PdfTextBoxField(
      page, 'Names', Rect.fromLTWH(0, 0, 100, 20),
      text: 'Derrick'));
  document.form.fields.add(PdfTextBoxField(
      page, 'Date', Rect.fromLTWH(0, 0, 100, 20),
      text: 'Derrick'));
  document.form.fields.add(PdfTextBoxField(
      page, 'Deposit', Rect.fromLTWH(0, 0, 100, 20),
      text: 'Derrick'));
  document.form.fields.add(PdfTextBoxField(
      page, 'Balance', Rect.fromLTWH(0, 0, 100, 20),
      text: 'Derrick'));

  //Save the document
  List<int> bytes = document.save();

  //Dispose the document
  document.dispose();
}
