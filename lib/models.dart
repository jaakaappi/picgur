import 'dart:convert';
import 'dart:ffi';
import 'dart:convert' show utf8;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:picgur/videoplayer.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class ImgurPost {
  final String id;
  final String title;
  final String fileUrl;
  final String galleryUrl;
  final Widget content;

  const ImgurPost(
      {required this.id,
      required this.title,
      required this.content,
      required this.fileUrl,
      required this.galleryUrl});

  static Future<ImgurPost> fromJson(Map<String, dynamic> json) async {
    //print(json);
    // var albumUrl = Uri.parse('${dotenv.env['IMGUR_API_URL']}/3/album/${json['id']}');
    // print(albumUrl);
    // var imageUrl = Uri.parse('${dotenv.env['IMGUR_API_URL']}/3/album/${json['id']}');
    // final response = await http.get(albumUrl,
    //     headers: {'Authorization': 'Client-ID ${dotenv.env['IMGUR_API_CLIENT_ID']}'});

    //print('response');
    //print(response);
    //print('contentType');
    //var responseJson = jsonDecode(response.body);
    // print(responseJson);
    var coverContentType = json['cover']['mime_type'].toString().split('/')[1];
    print(coverContentType);
    var coverUrl = json['cover']['url'];
    print(coverUrl);
    //print(contentType);
    //var url = 'https://i.imgur.com/${json['cover']}.$contentType';
    // print(url);

    return ImgurPost(
        id: json['id'],
        title: json['title'],
        //fileUrl: url,
        fileUrl: '',
        galleryUrl: json['url'],
        //content: Container());
        content: coverContentType == 'mp4'
            ? VideoPlayerScreen(url: coverUrl)
            : Image.network(
                coverUrl,
              ));
  }
}
