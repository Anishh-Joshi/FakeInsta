import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home.dart';
import 'package:flutter_app/widgets/header.dart';
import 'package:flutter_app/widgets/post.dart';
import 'package:flutter_app/widgets/progress.dart';

import '../services,.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({Key key, this.userId, this.postId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Services.postRef.doc(userId).collection('userPost').doc(postId).get(),
      builder:(context,snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          Post post = Post.fromDocument(snapshot.data);
          return Center(
            child: Scaffold(
              appBar: header(context,titleText: post.description),
              body: ListView(
                children: [
                  Container(
                    child: post,
                  )
                ],
              ),

            ),

          );
      },
    );
  }
}
