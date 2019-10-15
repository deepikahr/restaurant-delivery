import 'package:delivery_app/pages/home/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/profile-service.dart';
import 'package:async_loader/async_loader.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:async/async.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  File file;
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> profileData;
  bool isLoading = false;
  Image selectedImage;
  String base64Image;
  bool isPicUploading = false, isImageUploading = false;

  Future<Map<String, dynamic>> getProfileInfo() async {
    return await ProfileService.getUserInfo();
  }

  void _saveProfileInfo() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState.save();
      print("save button $profileData");
      var body = {
        "name": profileData['name'],
        "contactNumber": profileData['contactNumber'],
        "country": profileData['country'],
        "locationName": profileData['locationName'],
        "zip": profileData['zip'],
        "state": profileData['state'],
        "address": profileData['address'],
      };
      ProfileService.setUserInfo(profileData['_id'], body).then((onValue) {
        print(onValue);
        Toast.show("Your profile Successfully UPDATED", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  File _imageFile;

  void selectGallary() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    // base64Image = base64Encode(file.readAsBytesSync());
    setState(() async {
      _imageFile = file;
      setState(() {
        isPicUploading = true;
      });
      if (_imageFile != null) {
        var stream =
            new http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
        Map<String, dynamic> body = {"baseKey": base64Image};
        Map<String, dynamic> imageData;
        await ProfileService.uploadProfileImage(
          _imageFile,
          stream,
          profileData['_id'],
        );
        setState(() {
          isPicUploading = false;
        });
        Toast.show("Your profile Picture Successfully UPDATED", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    });
  }

  void selectCamera() async {
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    // base64Image = base64Encode(file.readAsBytesSync());
    setState(() async {
      _imageFile = file;
      setState(() {
        isPicUploading = true;
      });
      if (_imageFile != null) {
        var stream =
            new http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
        Map<String, dynamic> body = {"baseKey": base64Image};
        Map<String, dynamic> imageData;
        await ProfileService.uploadProfileImage(
          _imageFile,
          stream,
          profileData['_id'],
        );

        setState(() {
          isPicUploading = false;
        });
        Toast.show("Your profile Picture Successfully UPDATED", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    });
  }

  void removeProfilePic() async {
    setState(() {
      isImageUploading = true;
    });
    await ProfileService.deleteUserProfilePic().then((onValue) {
      // print(onValue['statusCode']);
      // print(onValue['message']);
      // if (onValue['statusCode'] == 200) {
      Toast.show(onValue['message'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      profileData['logo'] = null;
      _imageFile = null;
      setState(() {
        isImageUploading = false;
      });
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncLoader _asyncLoader = AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getProfileInfo(),
        renderLoad: () => Center(
                child: CircularProgressIndicator(
              backgroundColor: primary,
            )),
        renderError: ([error]) =>
            Text('Please check your internet connection!'),
        renderSuccess: ({data}) {
          profileData = data;
          return ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: InkWell(
                          onTap: () {
                            containerForSheet<String>(
                              context: context,
                              child: CupertinoActionSheet(
                                title: const Text('Change profile picture'),
                                actions: <Widget>[
                                  CupertinoActionSheetAction(
                                    child: const Text('Choose from photos'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      selectGallary();
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: const Text('Take photo'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      selectCamera();
                                    },
                                  ),
                                  profileData['logo'] != null
                                      ? CupertinoActionSheetAction(
                                          child: const Text('Remove photo'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            removeProfilePic();
                                          },
                                        )
                                      : Container(),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  child: const Text('Cancel'),
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 120.0,
                            width: 120.0,
                            decoration: new BoxDecoration(
                              border: new Border.all(
                                  color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                            child: _imageFile == null
                                ? profileData['logo'] != null
                                    ? new CircleAvatar(
                                        backgroundImage: new NetworkImage(
                                            "${profileData['logo']}"),
                                      )
                                    : new CircleAvatar(
                                        backgroundImage: new AssetImage(
                                            'assets/imgs/na.jpg'))
                                : isPicUploading
                                    ? CircularProgressIndicator()
                                    : new CircleAvatar(
                                        backgroundImage:
                                            new FileImage(_imageFile),
                                        radius: 80.0,
                                      ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['name'] = value;
                          },
                          initialValue: data['name'],
                          decoration: new InputDecoration(
                            labelText: 'Full Name',
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['contactNumber'] = value;
                          },
                          initialValue: data['contactNumber'].toString(),
                          decoration: new InputDecoration(
                            labelText: 'Mobile No.',
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['locationName'] = value;
                          },
                          initialValue: data['locationName'],
                          decoration: new InputDecoration(
                            labelText: 'Suburb',
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['state'] = value;
                          },
                          initialValue: data['state'],
                          decoration: new InputDecoration(
                            labelText: 'State',
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['country'] = value;
                          },
                          initialValue: data['country'],
                          decoration: new InputDecoration(
                            labelText: 'Country',
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: TextFormField(
                          onSaved: (value) {
                            data['zip'] = value;
                          },
                          initialValue:
                              data['zip'] != null ? data['zip'].toString() : '',
                          decoration: new InputDecoration(
                            labelText: 'Post Code',
                            hintStyle: textOS(),
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                          ),
                          child: new Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: new TextFormField(
                              onSaved: (value) {
                                data['address'] = value;
                              },
                              initialValue: data['address'],
                              decoration: new InputDecoration(
                                  labelText: 'Address',
                                  hintStyle: textOS(),
                                  fillColor: Colors.black,
                                  border: InputBorder.none),
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          );
        });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text("Profile"),
      ),
      body: _asyncLoader,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: new Row(
        children: <Widget>[
          Expanded(
            child: new Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              height: 40.0,
              child: FlatButton(
                child: Text(
                  'Cancel',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          new Padding(padding: EdgeInsets.all(5.0)),
          Expanded(
            child: new Container(
              height: 40.0,
              color: primary,
              child: isLoading
                  ? Image.asset(
                      'assets/icons/spinner.gif',
                      width: 19.0,
                      height: 19.0,
                    )
                  : FlatButton(
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        _saveProfileInfo();
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }
}
