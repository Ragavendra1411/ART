import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_market/app/services/firebase_authentication_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AppBarCommon extends StatefulWidget {
  Map userDatas;

  AppBarCommon({@required this.userDatas});

  @override
  _AppBarCommonState createState() => _AppBarCommonState(userDatas: userDatas);
}

class _AppBarCommonState extends State<AppBarCommon> {
  Map userDatas;

  _AppBarCommonState({@required this.userDatas});

  bool condition = true;

  @override
  Widget build(BuildContext context) {
    condition = MediaQuery.of(context).size.width > 500;
    return Container(
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        // BoxShadow(
        //     color: Colors.black54,
        //     blurRadius: 15.0,
        //     offset: Offset(0.0, 0.75)
        // )
      ], color: Colors.transparent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message:
                        userDatas != null ? '${userDatas['userName']}' : 'User',
                    child: CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            AssetImage('assets/images/avatar.png')),
                  ),
                  condition
                      ? SizedBox(
                          width: 5,
                        )
                      : Container(),
                  condition
                      ? userDatas != null
                          ? Text(
                              'Hi ${userDatas['userName']}',
                              style: TextStyle(color: Colors.white),
                            )
                          : Container()
                      : Container(),
                ],
              )),
          Container(
            padding: condition
                ? EdgeInsets.only(right: 40)
                : EdgeInsets.only(right: 0),
            child: InkWell(
              onTap: (){
                _clickPage();
              },
              child: Image.asset(
                'assets/images/logo_crop.png',
                width: condition ? 85 : 65,
                height: condition ? 85 : 65,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              context.read<FirebaseAuthService>().signOut();
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  condition
                      ? Text('Logout', style: TextStyle(color: Colors.white))
                      : Container(),
                  condition
                      ? SizedBox(
                          width: 5,
                        )
                      : Container(),
                  Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _clickPage() async{
    var uri = 'https://www.sharemarketprofile.com/';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}
