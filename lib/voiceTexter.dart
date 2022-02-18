import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:clipboard/clipboard.dart';



class voiceTexter extends StatefulWidget {
  @override
  _voiceTexterState createState() => _voiceTexterState();
}

class _voiceTexterState extends State<voiceTexter> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  String _localeId = '';
  TextEditingController controller = TextEditingController();
  bool isKeepButtonActive = true;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.addListener(() {
      final isKeepButtonActive = controller.text.isNotEmpty;

      setState(() => this.isKeepButtonActive = isKeepButtonActive);
    });

    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take memo with your voice'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          backgroundColor: Colors.green,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextField( enabled: false,controller: controller)
         ),

            Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
              SizedBox(
               height: 50,
               width: 50,
               child: IconButton(
                icon: const Icon(Icons.save_alt),
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                  print(controller.text);
                  },
              ),
          ),

             SizedBox(
               height: 50,
               width: 50,
               child: IconButton(
                 icon: const Icon(Icons.content_copy),
                 onPressed: () async {
                   await FlutterClipboard.copy(controller.text);

                   final snackBar = SnackBar(
                     content: const Text('✓   Copied to Clipboard'),
                   );
                   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                 },
               ),
             ),


           ], ),

    ]
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        var systemLocale = await _speech.systemLocale();
        _localeId = systemLocale!.localeId;
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
              _text = val.recognizedWords;
              controller.text = val.recognizedWords;
            }),
            localeId: _localeId);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}


//入力値が何もない時保存ボタンを無効にする
//アプリをもう一度立ち上げた時でもメモのデータが消えないようにする
//disableを使ってメモの削除とコピーを選択できるようにする
//アプリのアイコンをデザインする


//     {
// Navigator.of(context).pop(controller.text);
// print(controller.text);
// }