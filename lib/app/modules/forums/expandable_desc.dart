import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_market/app/modules/meet_page/view_meet_details_card.dart';

class ExpandableTextForum extends StatefulWidget {
  const ExpandableTextForum(
      this.text,this.cardData,this.pageWidth,this.userRole, {Key key, this.trimLines = 4,})  : assert(text != null),
        super(key: key);

  final String text;
  final int trimLines;
  final DocumentSnapshot cardData;
  final double pageWidth;
  final String userRole;
  @override
  ExpandableTextForumState createState() => ExpandableTextForumState();
}

class ExpandableTextForumState extends State<ExpandableTextForum> {
  void _onTapLink() {
    showMeetingDetailsPopUp(context,widget.cardData,widget.pageWidth,widget.userRole.toString());
  }

  showMeetingDetailsPopUp(BuildContext context,DocumentSnapshot data,double width,String userRole) async{
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return _descDetail();
        }
    );
  }

  _descDetail(){
    return Center(
      child: Card(
        shadowColor: Colors.orange,
        margin: EdgeInsets.all(10),
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Scrollbar(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(12),
                width: widget.pageWidth < 401 ? widget.pageWidth : 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Description'),
                        Expanded(child: Container()),
                        IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            onPressed: (){
                              Navigator.pop(context);
                            })
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(widget.cardData['description'])
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final colorClickableText = Colors.blue;
    final widgetColor = Colors.black;
    TextSpan link = TextSpan(
        text: " ...Read more",
        style: TextStyle(
          color: colorClickableText,
        ),
        recognizer: TapGestureRecognizer()..onTap = _onTapLink
    );
    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        // Create a TextSpan with data
        final text = TextSpan(
          text: widget.text,
        );
        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: TextDirection.rtl,//better to pass this from master widget if ltr and rtl both supported
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        // Get the endIndex of data
        int endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset);
        var textSpan;
        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            text: widget.text.substring(0, endIndex),
            style: TextStyle(
              color: widgetColor,
            ),
            children: <TextSpan>[link],
          );
        } else {
          textSpan = TextSpan(
            text: widget.text,
          );
        }
        return RichText(
          softWrap: true,
          overflow: TextOverflow.clip,
          text: textSpan,
        );
      },
    );
    return result;
  }
}