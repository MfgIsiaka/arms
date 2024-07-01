import 'package:arms/services/common_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class VirtualToruScreen extends StatefulWidget {
  Map<String, dynamic> prop;
  VirtualToruScreen(this.prop, {super.key});

  @override
  State<VirtualToruScreen> createState() => _VirtualToruScreenState();
}

class _VirtualToruScreenState extends State<VirtualToruScreen> {
  Map<String, dynamic> _prop = {};
  int _currentindex = 0;
  bool _loading = true;
  final _pgController = PageController();

  void _loadImage() {
    print("Loading");
    precacheImage(
            NetworkImage(_prop['images_3D'][_currentindex]['file']), context)
        .then((_) {
      setState(() {
        _loading = false;
      });
    }).catchError((error) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadImage();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prop = widget.prop;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    print(_prop['images_3D']);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
              controller: _pgController,
              itemCount: _prop['images_3D'].length,
              onPageChanged: (np) {
                _currentindex = np;
              },
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, ind) {
                return Container(
                  color: ind == 0 ? Colors.amber : Colors.black12,
                  child: PanoramaViewer(
                    child: Image.network(
                      _prop['images_3D'][_currentindex]['file'],
                      loadingBuilder: (context, ss, chunk) {
                        return Center(
                          child: SpinKitCircle(
                            color: appColor,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
          Container(
            color: const Color.fromARGB(96, 0, 0, 0),
            child: SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  width: 2,
                  color: Color.fromARGB(57, 4, 55, 158),
                ))),
                padding: EdgeInsets.symmetric(vertical: 5),
                height: 50,
                width: screenSize.width,
                child: ListView.builder(
                    itemCount: _prop['images_3D'].length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, ind) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentindex = ind;
                          });
                        },
                        child: AbsorbPointer(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: _currentindex != ind
                                    ? Colors.blueGrey
                                    : whiteColor,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 10,
                                      spreadRadius: 4,
                                      color: blackColor)
                                ],
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                                child: Text(
                              _prop['images_3D'][ind]['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
