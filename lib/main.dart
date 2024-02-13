import 'package:contacts_service/contacts_service.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // For handling permissions
import 'package:excel/excel.dart'; // For Excel file generation
import 'dart:io';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactListApp(),
    );
  }
}

class ContactListApp extends StatefulWidget {
  @override
  _ContactListAppState createState() => _ContactListAppState();
}

class _ContactListAppState extends State<ContactListApp> {
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
  }

  void showProductLoading() {
    Future.delayed(const Duration(milliseconds: 0), () {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              onWillPop: ()async{
               // Get.offAll(()=>const RootScreen());
                return true;
              },
              child: Center(
                child: Material(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      // const SizedBox(height: 20,),

                    ],
                  ),
                ),
              ),
            );
          });
    });
  }
  void hideLoadingDialog() {
    Navigator.pop(context);
  }

  // Function to request contact list permission
  Future<void> requestContactPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      // Permission granted, retrieve contacts here
      List<Contact> contactList = [];
      try {
        showProductLoading();
        print("kdfalfj");
        contactList = (await ContactsService.getContacts()).toList();
      } catch (e) {
        // Handle contact retrieval error
        print('Error retrieving contacts: $e');
      }

      // Populate the 'contacts' list with the data (name and number)
var temp;
      for (var contact in contactList) {
        for (var phone in contact.phones!) {
          contacts.add({'name': contact.displayName, 'number': phone.value});
        }
        print("i am done");
      }
    } else {
      // Handle permission denied
    }
    hideLoadingDialog();
  }

  // Function to generate and download the Excel file
  void downloadExcelFile() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Add headers to the sheet
      sheet.appendRow(['Name', 'Number']);

      // Add contact data to the sheet
      showProductLoading();
      print(contacts);
      await loopFunction(sheet);

      // Save the Excel file
      final excelFile = await excel.encode();
      final directory = await DownloadsPathProvider.downloadsDirectory;

      // Define the file path where the Excel file will be saved
      final filePath = '${directory?.path}/contacts.xlsx';

      // Save the Excel file

      // Write the Excel file to the specified path
      await File(filePath).writeAsBytes(excelFile!);

      // Open the file picker for the user to download the file
      hideLoadingDialog();
      try {
        await OpenFile.open(filePath);
      } catch (e) {
        print("Iam failing");
      }
      print(filePath);
    }catch(e){
      hideLoadingDialog();
    }
  }

  Future loopFunction(var sheet)async{
    for (var contact in contacts) {
      sheet.appendRow([contact['name'], contact['number']]);
      print("contacts copying in process");
      print(contacts.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contact List App'),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: requestContactPermission,
                  child: Text('Request Contact Permission'),
                ),
                ElevatedButton(
                  onPressed: downloadExcelFile,
                  child: Text('Download Excel File'),
                ),
              ],
            ),
            ),
        );
   }
}
