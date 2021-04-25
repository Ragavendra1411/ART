import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_market/app/models/user.dart';
import 'package:share_market/app/modules/documents/documents.dart';
import 'package:share_market/app/modules/forums/forums_page.dart';
import 'package:share_market/app/modules/meet_page/meet_page.dart';
import 'package:share_market/app/modules/users_page/users_page.dart';
import 'package:share_market/app/modules/videos/videos.dart';
import 'package:share_market/app/services/firebase_authentication_service.dart';
import 'package:share_market/app_commons/constants.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({@required this.user});

  @override
  _HomePageState createState() => _HomePageState(user: user);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final User user;
  _HomePageState({@required this.user});

  TabController controller;

  bool _isLoading = true;
  var userDatas;

  @override
  void initState() {
    // TODO: implement initState
    print("Coming to home");
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
          length: userDatas["role"] == "admin" ? 5 : 4, vsync: this);
    });
    return userDatas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[50],
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_crop.png',
          width: 50,
          height: 50,
        ),
        flexibleSpace: Container(
            margin: EdgeInsets.only(left: 10, top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/images/avatar.png')),
                SizedBox(
                  width: 5,
                ),
                userDatas != null
                    ? Text('Hi ${userDatas['userName']}')
                    : Container(),
              ],
            )),
        actions: [
          InkWell(
            onTap: () {
              context.read<FirebaseAuthService>().signOut();
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  Text('Logout'),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(Icons.logout),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.orange[50],
      body: _isLoading ? _loadingCircle() : _buildContent(context),
    );
  }

  _buildContent(BuildContext context) {
    return Column(
      children: [
        Container(
//          width: MediaQuery.of(context).size.width / 4,
          child: userDatas["role"] == "admin"
              ? TabBar(
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                  labelPadding: EdgeInsets.symmetric(horizontal: 1),
                  isScrollable: true,
                  labelStyle: TextStyle(fontSize: 16.0),
                  labelColor: Colors.black,
                  indicatorColor: SM_ORANGE,
                  controller: controller,
                  tabs: <Widget>[
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Meeting",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold"),
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
                              style: TextStyle(fontFamily: "OpenSans-SemiBold"),
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
                              style: TextStyle(fontFamily: "OpenSans-SemiBold"),
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
                              style: TextStyle(fontFamily: "OpenSans-SemiBold"),
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
                            style: TextStyle(fontFamily: "OpenSans-SemiBold"),
                          ),
                        ),
                      ),
                    )
                    ])
              : TabBar(
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                  labelPadding: EdgeInsets.symmetric(horizontal: 1),
                  isScrollable: true,
                  labelStyle: TextStyle(fontSize: 16.0),
                  labelColor: Colors.black,
                  indicatorColor: SM_ORANGE,
                  controller: controller,
                  tabs: <Widget>[
                      new Tab(
                        child: Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Container(
                            child: Text(
                              "Meeting",
                              style: TextStyle(fontFamily: "OpenSans-SemiBold"),
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
                              style: TextStyle(fontFamily: "OpenSans-SemiBold"),
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
                              style: TextStyle(fontFamily: "OpenSans-SemiBold"),
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
                            style: TextStyle(fontFamily: "OpenSans-SemiBold"),
                          ),
                        ),
                      ),
                    ),
                    ]),
        ),
        userDatas["role"] == "admin"
            ? Flexible(
                child: TabBarView(
                controller: controller,
                children: [
                  MeetPage(dataSend: userDatas),
                  VideosPage(dataSend: userDatas),
                  DocumentsPage(dataSend: userDatas),
                  UsersPage(dataSend: userDatas),
                  ForumsMainPage(dataSend: userDatas),
                ],
              ))
            : Flexible(
                child: TabBarView(
                controller: controller,
                children: [
                  MeetPage(dataSend: userDatas),
                  VideosPage(dataSend: userDatas),
                  DocumentsPage(dataSend: userDatas),
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
                labelColor: Colors.black,
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
}
