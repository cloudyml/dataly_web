import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudyml_app2/models/firebase_file.dart';
import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  final FirebaseFile file;

  const ImagePage({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isImage = ['.jpeg', '.jpg', '.jfif', '.png'].any(file.name.contains);
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(file.name),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.file_download),
      //       onPressed: () async {
      //         await FirebaseApi.downloadFile(file.ref);

      //         final snackBar = SnackBar(
      //           content: Text('Downloaded ${file.name}'),
      //         );
      //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //       },
      //     ),
      //     const SizedBox(width: 12),
      //   ],
      // ),
      body: isImage
          ? InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: CachedNetworkImage(
                imageUrl: file.url,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
                height: height,
                width: width,
                // fit: BoxFit.cover,
              ),
            )
              : Center(
                  child: Text(
                    'Cannot be displayed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
    );
  }
}
