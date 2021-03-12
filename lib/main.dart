import 'package:flutter/material.dart';
import 'dart:async';
import 'package:starflut/starflut.dart';

//test from VS Code
void main() => runApp(  MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return   MaterialApp(
      title: 'Flutter Demo',
      theme:   ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:   MyHomePage(title: 'Python Console'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() =>   _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _outputString = "python 3.6";

  bool _isButtonDisabled = true;
  TextEditingController myController;
  StarSrvGroupClass srvGroup;


  @override
  void initState() {
    myController = TextEditingController();

    _initStarCore();

    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void _initStarCore() async{
    StarCoreFactory starcore = await Starflut.getFactory();
    StarServiceClass Service = await starcore.initSimple("test", "123", 0, 0, []);
    await starcore.regMsgCallBackP(
            (int serviceGroupID, int uMsg, Object wParam, Object lParam) async{
          if( uMsg == Starflut.MSG_DISPMSG || uMsg == Starflut.MSG_DISPLUAMSG ){
            ShowOutput(wParam);
          }
          print("$serviceGroupID  $uMsg   $wParam   $lParam");
          return null;
        });
    srvGroup = await Service["_ServiceGroup"];
    bool isAndroid = await Starflut.isAndroid();
    if( isAndroid == true ){
      String libraryDir = await Starflut.getNativeLibraryDir();
      String docPath = await Starflut.getDocumentPath();
      if( libraryDir.indexOf("arm64") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-arm64.zip", docPath, true);
      }else if( libraryDir.indexOf("x86_64") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-x86_64.zip", docPath, true);
      }else if( libraryDir.indexOf("arm") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-armeabi.zip", docPath, true);
      }else{  //x86
        Starflut.unzipFromAssets("lib-dynload-x86.zip", docPath, true);
      }
      await Starflut.copyFileFromAssets("python3.6.zip", "flutter_assets/starfiles",null);  //desRelatePath must be null
    }
    if( await srvGroup.initRaw("python36", Service) == true ){
      _outputString = "init starcore and python 3.6 successfully";
      _isButtonDisabled = false;
    }else{
      _outputString = "init starcore and python 3.6 failed";
    }

    setState(() {
    });
  }

  void ShowOutput(String Info) async{
    if( Info == null || Info.length == 0)
      return;
    _outputString = _outputString + "\n" + Info;
    setState((){

    });
  }

  void runScriptCode() async{
    if( myController.text.length == 0 )
      return;
    await srvGroup.runScript("python", myController.text, null);

    setState((){

    });
  }

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar:   AppBar(
        backgroundColor: Colors.redAccent,
        title:   Text(this.widget.title),
      ),
      body:  Container(
        height: MediaQuery.of(context).size.height,
        child:  SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child : TextField(
                    controller: myController,
                    textDirection: TextDirection.ltr,
                    focusNode: FocusNode(),
                    autocorrect: false,
                    maxLines: null,
                    style: TextStyle(color:Colors.black),
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Write your code here"),

                  ),
                ),
              ),
               Container(
                height: 1.0,
                color: Colors.black,
              ),
               Row(
                mainAxisAlignment:MainAxisAlignment.end,
                children: <Widget>[
                   ElevatedButton(
                      onPressed: (){myController.text="";setState((){});},
                      child:   Text("Clar")
                  ),
                   ElevatedButton(
                      onPressed: _isButtonDisabled ? null:runScriptCode,
                      child:   Text("Run")
                  ),
                ],
              ),

               Container(
                height: 1.0,
                color: Colors.black,
              ),
               Container(
                height: 200.0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child :   SingleChildScrollView(
                  child :   Container(
                    alignment: Alignment.topLeft,
                    child :   Text(
                      '$_outputString',
                      style:   TextStyle(color:Colors.blue),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}