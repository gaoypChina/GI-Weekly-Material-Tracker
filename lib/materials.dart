import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gi_weekly_material_tracker/placeholder.dart';
import 'package:gi_weekly_material_tracker/util.dart';
import 'package:image_fade/image_fade.dart';
import 'package:transparent_image/transparent_image.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class MaterialListGrid extends StatefulWidget {
  @override
  _MaterialListGridState createState() => _MaterialListGridState();
}

class _MaterialListGridState extends State<MaterialListGrid> {
  @override
  Widget build(BuildContext context) {
    CollectionReference materialRef = db.collection('materials');
    return StreamBuilder(
        stream: materialRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Error occurred getting snapshot");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Util.centerLoadingCircle("");
          }

          return GridView.count(
            crossAxisCount: 3,
            children: snapshot.data.docs.map((document) {
              return GestureDetector(
                onTap: () => Util.showSnackbarQuick(context, "TODO: Show ${document.data()['name']} (${document.id}) info"),
                child: Util.getGridData(document),
              );
            }).toList(),
          );
        });
  }
}
