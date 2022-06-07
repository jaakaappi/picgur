import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picgur/models.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
      );
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picgur',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Widget build(BuildContext widgetContext) {
    Future<List<ImgurPost>> _fetchAlbum() async {
      const section = 'hot';
      const sort = 'viral';
      const page = 1;

      final response = await http.get(
        Uri.parse(
            '${dotenv.env['IMGUR_API_URL']}/post/v1/posts?client_id=${dotenv.env['IMGUR_API_CLIENT_ID']}&filter[section]=eq:hot&include=cover,viral&page=1&sort=-time'),
      );
      if (kDebugMode) {
        print([response.statusCode, response.body]);
      }
      if (response.statusCode == 200) {
        print("vitunvittu");
        try {
          Future<List<ImgurPost>> imgurPosts =
              Future.wait((jsonDecode(response.body) as List).map((e) => ImgurPost.fromJson(e)));
          //print('imgurPosts');
          //print(imgurPosts);
          return imgurPosts;
        } catch (e, stackTrace) {
          print('error');
          print(e);
          print(stackTrace);
        }
      }
      throw Exception("asd");
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                const SliverAppBar(
                  title: Text("Picgur"),
                  floating: true,
                  snap: true,
                ),
              ];
            },
            floatHeaderSlivers: true,
            body: FutureBuilder<List<ImgurPost>>(
              future: _fetchAlbum(),
              // a previously-obtained Future<String> or null
              builder: (BuildContext context, AsyncSnapshot<List<ImgurPost>> snapshot) {
                if (kDebugMode) {
                  print('snapshot');
                  print(snapshot.connectionState);
                  print(snapshot.data.toString());
                }
                return Center(
                    child: snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData
                        ? SpinKitWave(
                            color:
                                MediaQuery.of(widgetContext).platformBrightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            size: 60,
                            duration: const Duration(milliseconds: 750))
                        : ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          snapshot.data![index].title,
                                          style: const TextStyle(fontSize: 20),
                                          textAlign: TextAlign.left,
                                        )),
                                    snapshot.data![index].content,
                                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                      const IconButton(
                                        icon: Icon(Icons.download),
                                        disabledColor: Colors.grey,
                                        onPressed: null,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () {
                                          Share.share(snapshot.data![index].galleryUrl,
                                              subject: snapshot.data![index].title);
                                        },
                                      )
                                    ])
                                  ]));
                            }));
              },
            )));
  }
}