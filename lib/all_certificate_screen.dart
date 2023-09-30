import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'
    as PermissionHandler;
import 'package:share_extend/share_extend.dart';

class AllCertificateScreen extends StatefulWidget {
  const AllCertificateScreen({Key? key}) : super(key: key);

  @override
  State<AllCertificateScreen> createState() => _AllCertificateScreenState();
}

class _AllCertificateScreenState extends State<AllCertificateScreen> {
  bool loaded = false;

  Future<File> getFileFromUrl(String url, {name}) async {
    setState(() {
      loaded = true;
    });
    var fileName = 'testonline';
    if (name != null) {
      fileName = name;
    }
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      print(dir.path);
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  Future<void> _downloadImage(image) async {
    try {
      print(image.replaceAll('"', ""));
      await WebImageDownloader.downloadImageFromWeb(image);
    } catch (e) {
      print("Error downloading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("Users_dataly")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (BuildContext context, snapshot) {
              print('wewewewe3w');
              var certificates = [];
              try {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                print("weifjweifw");
                if (snapshot.hasError) {
                  print('wefwefwfowif');
                  return Text('Error: ${snapshot.error}');
                }
                certificates = snapshot.data!['certificates'] as List;
              } catch (e) {
                print(e.toString());
              }

              return certificates.length == 0
                  ? Center(
                      child: Text('No Certificate Found!'),
                    )
                  : ListView.builder(
                      itemCount: certificates.length,
                      itemBuilder: (BuildContext context, int index) {
                        final certificate = certificates[index];

                        if (certificate is String &&
                            certificate.contains('http')) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 600,
                                  width: 1000,
                                  child: Image.network(certificate),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        print("Downloading image...");
                                        _downloadImage(certificate);
                                      },
                                      child: Icon(Icons.download_sharp),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        } else {
                          return Container(); // Skip non-http certificates
                        }
                      },
                    );
            },
          ),
        ),
      ),
    );
  }
}
