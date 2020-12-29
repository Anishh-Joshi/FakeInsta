import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/widgets/header.dart';
import 'package:flutter_app/widgets/post.dart';
import 'package:flutter_app/widgets/post_tile.dart';
import 'package:flutter_app/widgets/progress.dart';
import '../services,.dart';
import 'edit_profile.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  final String profileId;


  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  String postOrientation = "grid";
  int postCount = 0;
  int followingCount = 0;
  int followersCount = 0;
  int limit=0;

  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    getIds();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await Services.followersRef
        .doc(widget.profileId)
        .collection('userId')
        .doc(currentUserId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot =
        await Services.followersRef.doc(widget.profileId).collection('userId').get();
    setState(() {
      followersCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await Services.followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

   getIds()async{
    QuerySnapshot snapshot = await Services.timelineRef
        .doc(currentUserId)
        .collection('posts')
        .get();
    limit= snapshot.docs.length;

  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Center(
          child: Text(
            "No post",
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 40.0,
                fontWeight: FontWeight.bold),
          ),),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTile = [];
      posts.forEach((element) {
        gridTile.add(GridTile(child: PostTile(element)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  togglePostGrid() {
    setState(() {
      postOrientation = "grid";
    });
  }

  togglePostList() {
    setState(() {
      postOrientation = "list";
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await Services.postRef
        .doc(widget.profileId)
        .collection('userPost')
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: "Edit Profile", function: editProfile);
    } else if (isFollowing) {
      return buildButton(text: "Unfollow", function: handleUnfollow);
    } else if (!isFollowing) {
      return buildButton(text: "Follow", function: handleFollow);
    }
  }

  handleUnfollow() {
    setState(() {
      isFollowing = false;
    });

    Services.followersRef
        .doc(widget.profileId)
        .collection('userId')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    Services.followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
          .get().then((value) {
            if (value.exists) {
              value.reference.delete();
            }
          });

      for (int i = 0; i <= limit; i++) {
        print(limit);
        Services.timelineRef
            .doc(currentUserId).collection('posts').doc(i.toString()).delete();
      }




    Services.activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
          ..get().then((value) {
            if (value.exists) {
              value.reference.delete();
            }
          });

    setState(() {
      followersCount--;
    });
  }

  handleFollow() {
    setState(() {
      isFollowing = true;
    });
    Services.followersRef
        .doc(widget.profileId)
        .collection('userId')
        .doc(currentUserId)
        .set({});

    Services.followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    Services.activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timeStamp": Services.timestamp,
      "mediaUrl": " ",
      "postId": " ",
      "commentData": " "
    });

    setState(() {
      followersCount++;
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: Services.usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        UserModel user = UserModel.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("posts", postCount),
                            buildCountColumn("followers", followersCount),
                            buildCountColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            icon: Icon(
              Icons.grid_on,
              color: postOrientation == "list"
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
            ),
            onPressed: togglePostGrid),
        IconButton(
            icon: Icon(Icons.list,
                color: postOrientation == "list"
                    ? Theme.of(context).primaryColor
                    : Colors.grey),
            onPressed: togglePostList)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: currentUser.username),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
