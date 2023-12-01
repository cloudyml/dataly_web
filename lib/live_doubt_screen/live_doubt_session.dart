import 'dart:html';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveDoubtScreen extends StatefulWidget {
  const LiveDoubtScreen({Key? key});

  @override
  State<LiveDoubtScreen> createState() => _LiveDoubtScreenState();
}

class _LiveDoubtScreenState extends State<LiveDoubtScreen> {
  List taDetails = [];

  String classUrl = '';
  bool? isShow;

  TextEditingController linkController = TextEditingController();

  @override
  void initState() {
    getTAData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Center(
            child: userProvider.userModel!.role == 'mentor'
                ? Column(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Update Link',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: width < 500 ? null : width / 2,
                  child: Material(
                    child: TextFormField(
                      controller: linkController,
                      decoration: InputDecoration(
                        fillColor: Color(0xffF2E9FE),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepPurpleAccent),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        hintText: 'Enter link address',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height / 50),
                InkWell(
                  onTap: () {
                    updateLink();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Update',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height / 30),
                Container(
                  width: width < 500 ? null : width / 2,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF67C5E5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 5),
                        blurRadius: 5,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'TA Name',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Time',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                taDetails.isEmpty
                    ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF67C5E5))),
                )
                    :SizedBox(
                    height: height / 2.5,
                    child: ListView.builder(
                      itemCount: taDetails.length,
                      shrinkWrap: false,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: width < 500 ? null : width / 2,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    taDetails[index]['name'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF444444)),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    taDetails[index]['time'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF444444)),
                                  ),
                                ),
                                IconButton(
                                    splashRadius: 20,
                                    onPressed: () =>
                                        showUpdatePopUp(
                                            taDetails[index]
                                            ['name'],
                                            taDetails[index]
                                            ['time'],
                                            index),
                                    icon: Icon(Icons.edit)),
                                IconButton(
                                    splashRadius: 20,
                                    onPressed: () =>
                                        removeTaDetail(index),
                                    icon: Icon(Icons.delete))
                              ],
                            ),
                          ),
                          SizedBox(
                            width: width / 2,
                            child: const Divider(
                              thickness: 1,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () {
                    showAddPopUp();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Add TA Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      'Show TA Timing Data to Students',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: width/5,),


                    isShow == null ?
                    SizedBox() :
                    Switch(
                      value: isShow!,
                      activeColor: Colors.deepPurpleAccent,
                      onChanged: (value) {
                        setState(() {
                          showOrHideData(value);
                        });
                      },
                    )
                  ],
                )
              ],
            )
                : Padding(
                  padding:  EdgeInsets.symmetric(horizontal: width / 20),
                  child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 20, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          size: height / 35,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Live Chat Support Timing',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height / 40,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  isShow == null ?
                  SizedBox() :
                  !isShow! ?
                  Center(
                    child: Image.network('https://cdni.iconscout.com/illustration/premium/thumb/doubt-solving-in-online-business-class-4260910-3543508.png', height: height / 2, width: width /2,),
                  ) :
                  Column(
                    children: [
                      Container(
                        width: width < 500 ? null : width / 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFF67C5E5),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 5),
                              blurRadius: 5,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ],
                        ),
                        child: Row(
                          children:  [
                            Expanded(
                              child: Text(
                                'Teaching Assistant',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: height / 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                           SizedBox(
                            height: height /30,
    child:VerticalDivider(
      color: Colors.white,
      thickness: 2, //thickness of divier line
    )
),
                            Expanded(
                              child: Text(
                                'Time',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: height /50,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      taDetails.isEmpty
                          ? Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF67C5E5))),
                      )
                          : Container(
                         constraints: BoxConstraints(
                          maxHeight: height /4,
                          minHeight:  height /6
                         ),
                          child: ListView.builder(
                            itemCount: taDetails.length,
                            shrinkWrap: false,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: height / 100,),
                                Container(
                                  width: width < 500 ? null : width / 2,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          taDetails[index]['name'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: height / 60,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF444444)),
                                        ),
                                      ),
                                        SizedBox(
                            height: height /30,
    child:VerticalDivider(
      color: Colors.black,
      thickness: 1.5, //thickness of divier line
    )
),
                                     
                                      Expanded(
                                        child: Text(
                                          taDetails[index]['time'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: height /60,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF444444)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height / 100,)
                              ],
                            ),
                          ),
                        ),

                    ],
                  ),
                    SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_call,
                        size: height / 25,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Join Live Doubt Session',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: height / 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 10),
                              blurRadius: 10,
                              color: Colors.grey.shade300,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Join everyday for live doubt support',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: height/ 45,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              taDetails.isNotEmpty
                                  ? '🕗 ${taDetails[0]['doubt_session_time']} 🕗'
                                  : '🕗 8:00 PM - 9:00 PM 🕗',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: height/40,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                            SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                try {
                                  classUrl.isNotEmpty
                                      ? launch(classUrl)
                                      : null;
                                } catch (e) {}
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'Click here to join',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: height/50,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ],
            ),
                ),
          ),
        ),
      ),
    );
  }

  getTAData() async {
    try {
      await FirebaseFirestore.instance
          .collection('LiveDoubt_dataly')
          .get()
          .then((value) {
        setState(() {
          taDetails = value.docs.first.get('taDetails');
          classUrl = value.docs.first.get('activeLink');
          isShow = value.docs.first.get('show');
          print('TA Details ${taDetails}');
        });
      });
    } catch (e) {
      print('Error i getting ta data $e');
    }
  }

  addTaDetail(TextEditingController taNameController,
      TextEditingController timeController) async {
    final ref = FirebaseFirestore.instance.collection('LiveDoubt_dataly');

    try {
      taDetails.add({
        'name': taNameController.text.trim(),
        'time': timeController.text.trim()
      });

      await ref
          .doc('9Xl5YqipCuZ0AVBC5an6')
          .update({'taDetails': taDetails}).whenComplete(() {
        Fluttertoast.showToast(msg: 'TA Details Added');
      });
    } catch (e) {
      print('Error in adding ta details $e');
    }
  }

  updateLink() async {
    if (linkController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please Enter Link');
    } else {
      try {
        final ref = FirebaseFirestore.instance.collection('LiveDoubt_dataly');
        await ref.doc('9Xl5YqipCuZ0AVBC5an6').update(
            {'activeLink': linkController.text.trim()}).whenComplete(() {
          Fluttertoast.showToast(msg: 'Link Updated');
        });
      } catch (e) {
        print('Error in updating link $e');
      }
    }
  }

  removeTaDetail(int index) async {
    try {
      taDetails.removeAt(index);
      final ref = FirebaseFirestore.instance.collection('LiveDoubt_dataly');

      await ref
          .doc('9Xl5YqipCuZ0AVBC5an6')
          .update({'taDetails': taDetails}).whenComplete(() {
        Fluttertoast.showToast(msg: 'TA Details Removed');
      });
      setState(() {});
    } catch (e) {
      print('Error in removing ta details');
    }
  }

  editTaDetail(int index, String name, String time) async {
    try {
      taDetails[index]['name'] = name;
      taDetails[index]['time'] = time;

      final ref = FirebaseFirestore.instance.collection('LiveDoubt_dataly');

      await ref
          .doc('9Xl5YqipCuZ0AVBC5an6')
          .update({'taDetails': taDetails}).whenComplete(() {
        Fluttertoast.showToast(msg: 'TA Details Edited');
      });
      setState(() {});
    } catch (e) {
      print('Error in Editing ta details');
    }
  }

  showOrHideData(bool value)async{
    try {

      isShow = value;
      final ref = FirebaseFirestore.instance.collection('LiveDoubt_dataly');

      await ref
          .doc('9Xl5YqipCuZ0AVBC5an6')
          .update({'show': value}).whenComplete(() {

        value ?
        Fluttertoast.showToast(msg: 'TA Details Show') :
        Fluttertoast.showToast(msg: 'TA Details Hide');
      });
      setState(() {});
    } catch (e) {
      print('Error in Editing ta details');
    }

  }

  showUpdatePopUp(String name, String time, int index) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    TextEditingController updateNameController = TextEditingController();
    TextEditingController updateTimeController = TextEditingController();

    updateNameController.text = name;
    updateTimeController.text = time;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: width / 50, vertical: height / 50),
            width: width / 2,
            decoration: BoxDecoration(
              color: Color(0xffF2E9FE),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  child: Text(
                    'Update TA Details',
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: height / 40,
                ),
                Material(
                  child: TextFormField(
                    controller: updateNameController,
                    decoration: InputDecoration(
                      fillColor: Color(0xffF2E9FE),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.deepPurpleAccent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintText: 'Enter TA Name',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                Material(
                  child: TextFormField(
                    controller: updateTimeController,
                    decoration: InputDecoration(
                      fillColor: Color(0xffF2E9FE),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.deepPurpleAccent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintText: 'Enter Time',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                ElevatedButton(
                  onPressed: () async {
                    editTaDetail(index, updateNameController.text,
                        updateTimeController.text);
                    Navigator.pop(context);
                  },
                  child: Text("Update TA Details"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  showAddPopUp() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    TextEditingController taNameController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: width / 50, vertical: height / 50),
            width: width / 2,
            decoration: BoxDecoration(
              color: Color(0xffF2E9FE),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  child: Text(
                    'Add TA Details',
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: height / 40,
                ),
                Material(
                  child: TextFormField(
                    controller: taNameController,
                    decoration: InputDecoration(
                      fillColor: Color(0xffF2E9FE),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.deepPurpleAccent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintText: 'Enter TA Name',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                Material(
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      fillColor: Color(0xffF2E9FE),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.deepPurpleAccent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintText: 'Enter Time',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (taNameController.text.isEmpty ||
                        timeController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Please Fill All Fields');
                    } else {
                      setState(() {
                        addTaDetail(taNameController, timeController);
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Add TA Details"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}