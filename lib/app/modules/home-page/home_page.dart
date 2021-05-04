import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_market/app/models/user.dart';
import 'package:share_market/app/modules/documents/document_folders.dart';
import 'package:share_market/app/modules/forums/forums_page.dart';
import 'package:share_market/app/modules/meet_page/meet_page.dart';
import 'package:share_market/app/modules/users_page/users_page.dart';
import 'package:share_market/app/modules/video_folders/video_folder.dart';
import 'package:share_market/app_commons/app_bar_common.dart';
import 'package:share_market/app_commons/constants.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  final User user;

  HomePage({@required this.user});

  @override
  _HomePageState createState() => _HomePageState(user: user);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final User user;
  var height;
  var width;

  _HomePageState({@required this.user});

  TabController controller;

  bool _isLoading = true;
  var userDatas;
  int i = 0;
  List imagess = [
    'assets/images/demo.jpg',
    'assets/images/demo2.jpeg',
    'assets/images/demo3.jpeg',
    'assets/images/demo.jpg'
  ];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    // print(user.email);
    if (userDatas == null) {
      _getUserDetails(context).then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future _getUserDetails(BuildContext context) async {
    await Firestore.instance
        .collection("users")
        .document(user.uid)
        .get()
        .then((value) {
      // print(value.data);

      userDatas = value.data;
      controller = new TabController(
          length: userDatas["role"] == "Admin" ? 5 : 4, vsync: this);
      controller.addListener(_handleTabSelection);
    });
    return userDatas;
  }

  _handleTabSelection() {
    setState(() {
      i = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Stack(children: [
      Scaffold(
        backgroundColor: Colors.transparent,
        body: _isLoading
            ? _loadingCircle()
            : Stack(
                children: [
                  Container(
                      height: height,
                      width: width,
                      child: Image.asset(
                        imagess[0],
                        fit: BoxFit.cover,
                      )),
                  _buildContent(context),
                  // _centerLogForm(context),
                ],
              ),
      ),
    ]);
  }

  _buildContent(BuildContext context) {
    return Column(
      children: [
        AppBarCommon(userDatas: userDatas),
        Container(
//          width: MediaQuery.of(context).size.width / 4,
          child: userDatas["role"] == "Admin"
              ? TabBar(
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                  labelPadding: EdgeInsets.symmetric(horizontal: 1),
                  isScrollable: true,
                  labelStyle: TextStyle(fontSize: 16.0),
                  labelColor: SM_BLACK,
                  indicatorColor: SM_ORANGE,
                  controller: controller,
                  tabs: <Widget>[
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Meeting",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Videos",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Documents",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Forums",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Users",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ])
              : TabBar(
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                  labelPadding: EdgeInsets.symmetric(horizontal: 1),
                  isScrollable: true,
                  labelStyle: TextStyle(fontSize: 16.0),
                  labelColor: SM_BLACK,
                  indicatorColor: SM_ORANGE,
                  controller: controller,
                  tabs: <Widget>[
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Meeting",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                            // child: textBold('Meeting'),
                          ),
                        ),
                      ),
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Videos",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Documents",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Forums",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold",color: Colors.black,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ]),
        ),
        userDatas["role"] == "Admin"
            ? Flexible(
                child: TabBarView(
                controller: controller,
                children: [
                  MeetPage(dataSend: userDatas),
                  VideoFoldersPage(dataSend: userDatas),
                  DocumentFoldersPage(dataSend: userDatas),
                  ForumsMainPage(dataSend: userDatas),
                  UsersPage(dataSend: userDatas),
                ],
              ))
            : Flexible(
                child: TabBarView(
                controller: controller,
                children: [
                  MeetPage(dataSend: userDatas),
                  VideoFoldersPage(dataSend: userDatas),
                  DocumentFoldersPage(dataSend: userDatas),
                  ForumsMainPage(dataSend: userDatas),
                ],
              ))
      ],
    );
  }

  Center _loadingCircle() {
    return Center(
      child: Container(
        child: Opacity(
          opacity: 0.5,
          child: Image.asset('assets/images/rotategif.gif'),
        ),
      ),
    );
  }

  _tabWidget(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: MediaQuery.of(context).size.width / 4,
            child: TabBar(
                indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                labelPadding: EdgeInsets.symmetric(horizontal: 1),
                isScrollable: false,
                labelStyle: TextStyle(fontSize: 16.0),
                labelColor: SM_BLACK,
                indicatorColor: SM_ORANGE,
                controller: controller,
                tabs: <Widget>[
                  new Tab(
                    child: Container(
                      child: Text(
                        "Meeting",
                        style: TextStyle(fontFamily: "OpenSans-SemiBold"),
                      ),
                    ),
                  ),
                  new Tab(
                    child: Container(
                      child: Text(
                        "Videos",
                        style: TextStyle(fontFamily: "OpenSans-SemiBold"),
                      ),
                    ),
                  ),
                  new Tab(
                    child: Container(
                      child: Text(
                        "Images",
                        style: TextStyle(fontFamily: "OpenSans-SemiBold"),
                      ),
                    ),
                  ),
                ]),
          ),
          Flexible(
              child: TabBarView(
            controller: controller,
            children: [Container(), Container(), Container()],
          ))
        ]));
  }


  Widget textBold(String name) {
    String data = name;
    TextStyle style = Theme.of(context).textTheme.subtitle1.apply(color: Colors.black54,fontWeightDelta: 12);
    return ClipRect(
      child: new Stack(
        children: [
          // new Positioned(
          //   top: 2.0,
          //   left: 2.0,
          //   child: new Text(
          //     data,
          //     style: style.copyWith(color: Colors.black.withOpacity(0.5)),
          //   ),
          // ),
          new BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: new Text(data, style: style),
          ),
        ],
      ),
    );
  }
}
