import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/pages/home.dart';
import 'package:flutter_app/widgets/progress.dart';
import '../services,.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  UserModel user;

  bool _bioValid = true;
  bool _displayName = true;


  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await Services.usersRef.doc(widget.currentUserId).get();
    user = UserModel.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  updateProfileData(){
    setState(() {
      displayNameController.text.trim().length<3||displayNameController.text.isEmpty? _displayName = false:
          _displayName=true;
      bioController.text.trim().length>20 ? _bioValid = false:_bioValid=true;
      if(_displayName && _bioValid ){
        Services.usersRef.doc(widget.currentUserId).update({
          "displayName":displayNameController.text,
          'bio':bioController.text
        });
        SnackBar snackBar  = SnackBar(content: Text("Profile Updated"));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }

    });

  }

  logout()async{
    await Services.googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.done,
                size: 40,
                color: Colors.green,
              ),
              onPressed: () => Navigator.pop(context))
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(user.photoUrl),

                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            buildDisplayField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: updateProfileData,
                        child: Text(
                          "Update",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: FlatButton.icon(
                            onPressed: logout,
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            label: Text(
                              "Logout",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            )),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Column buildDisplayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Display Name",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(hintText: "Update Display Name",errorText:_displayName?null:"Display name too short!"),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Bio",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(hintText: "Update Bio",errorText:_bioValid?null:"Bio too long!"),
        )
      ],
    );
  }
}
