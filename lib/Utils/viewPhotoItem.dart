// ignore_for_file: file_names, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:meditation/Utils/photoItem.dart';
import 'Widgets.dart';
import 'appColors.dart';

class ViewPhotoItemScreen extends StatelessWidget {
  final String? image;
  final String? name;
  final Image? selectedImage;
  bool? priorityImage = false;

  ViewPhotoItemScreen(
      {Key? key, this.image, this.name, this.selectedImage, this.priorityImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child:
              appbarCustom(isShadow: false, labelText: "", bgColor: lightBlue)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                child: Image.network(
                  image!, scale: 3.5,
                  // width: _width * 0.9,
                  // height: _height * 0.7,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: appPrimaryColor,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              // Center(
              //   child: Container(
              //     // width: _width * 0.7,
              //     height: _height * 0.7,
              //     child: Container(
              //       decoration: BoxDecoration(
              //         // borderRadius: BorderRadius.circular(12),
              //         image: DecorationImage(
              //           // fit: BoxFit.fill,
              //           image: NetworkImage(image!),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // Text
              // Container(
              //   margin: const EdgeInsets.all(20.0),
              //   child: Center(
              //     child: Text(
              //       name!,
              //       style: TextStyle(fontSize: 40),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
