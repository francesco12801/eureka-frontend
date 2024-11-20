import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/my_text_button.dart';
import 'package:eureka_final_version/frontend/models/genie.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:eureka_final_version/frontend/views/accept_terms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class PostCardCreation extends StatefulWidget {
  final EurekaUser userData;

  const PostCardCreation({super.key, required this.userData});

  @override
  State<PostCardCreation> createState() => _PostCardCreationState();
}

class _PostCardCreationState extends State<PostCardCreation> {
  // Variables to manage position etc...
  bool isPublic = true;
  bool isLocationEnabled = false;
  File? _image;
  Position? _currentPosition;
  String? _city;
  final picker = ImagePicker();

  // Helper
  final authHelper = AuthHelper();
  final userHelper = UserHelper();
  final genieHelper = GenieHelper();

  // Storage

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  Future<void> createLocalGenie() async {
    final title = _titleController.text;
    final description = _contentController.text;
    final target = isPublic ? 'public' : 'private';
    final nameSurnameCreator = widget.userData.nameSurname;
    final professionUser = widget.userData.profession;

    debugPrint('nameSurnameCreator: $nameSurnameCreator');
    debugPrint('professionUser: $professionUser');

    final Genie dataGenie = Genie(
      title: title,
      description: description,
      target: target,
      nameSurnameCreator: nameSurnameCreator,
      professionUser: professionUser,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AcceptTermsPage(geniedata: dataGenie, userData: widget.userData)),
    );
  }

  // Get Actual position
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check geolocalization permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get Actual position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      isLocationEnabled = true;
    });

    // Get the city name from the coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude);
    if (placemarks.isNotEmpty) {
      setState(() {
        _city = placemarks[0].locality; // Store the city name
      });
    }
  }

  // Pop-up to confim position
  Future<void> _showLocationConfirmationDialog() async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Position',
            style: TextStyle(color: black),
          ),
          content: const Text(
            'Do you want to share your position?',
            style: TextStyle(color: black),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text(
                'Cancel',
                style: TextStyle(color: red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                'Share',
                style: TextStyle(color: greenIOS),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _getCurrentLocation();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildContent(),
                    const SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  // Go back to the first page
                  Navigator.pop(context);
                },
                icon: const Icon(
                  CupertinoIcons.clear,
                  color: white,
                )),
            const Spacer(),
            MyTextButton(text: "Share", onPressed: createLocalGenie),
          ],
        ),
        Stack(
          alignment: Alignment.topRight,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255), width: 1),
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.userData.profileImage!),
                radius: 35,
              ),
            ),
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                  border: Border.all(color: white, width: 1),
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameAndRole(),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Enter title...',
            hintStyle: TextStyle(
                color: Color.fromARGB(255, 188, 187, 187),
                fontFamily: 'Roboto'),
            border: InputBorder.none,
          ),
          style: const TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            fontSize: 24,
          ),
          onChanged: (text) {
            // setState(() {
            //   post.title = text;
            // });
          },
        ),
        TextField(
          controller: _contentController,
          focusNode: _focusNode,
          minLines: 1,
          maxLines: null,
          style: const TextStyle(color: white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Write your description...',
            hintStyle: TextStyle(
                color: Color.fromARGB(255, 188, 187, 187),
                fontFamily: 'Roboto'),
            border: InputBorder.none,
          ),
          onChanged: (text) {
            // setState(() {
            //   post.content = text;
            // });
          },
        ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Image.file(_image!),
          ),
      ],
    );
  }

  Widget _buildNameAndRole() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              widget.userData.nameSurname,
              style: const TextStyle(
                color: white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 18,
              ),
            ),
            Text(
              widget.userData.profession,
              style: const TextStyle(
                  color: Color.fromARGB(255, 188, 187, 187),
                  fontSize: 14,
                  fontFamily: 'Roboto'),
            ),
            if (isLocationEnabled && _currentPosition != null)
              Text(
                '📍 $_city',
                style: const TextStyle(
                    color: Color.fromARGB(255, 188, 187, 187),
                    fontSize: 14,
                    fontFamily: 'Roboto'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            await _showAttachmentOptions(context);
          },
          child: const Icon(
            CupertinoIcons.paperclip,
            color: white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () async {
            await _showLocationConfirmationDialog();
          },
          child: Icon(
            CupertinoIcons.location,
            color: isLocationEnabled ? Colors.blue : white,
            size: 24,
          ),
        ),
        const Spacer(),
        const Text(
          'Public',
          style: TextStyle(color: white),
        ),
        const SizedBox(width: 8),
        Switch(
          value: isPublic,
          onChanged: (value) {
            setState(() {
              isPublic = value;
            });
          },
          activeColor: greenIOS,
          inactiveThumbColor: greyIOS,
          inactiveTrackColor: lightGreyIOS,
        ),
      ],
    );
  }

  Future<void> _showAttachmentOptions(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child:
                const Text('Pick from gallery', style: TextStyle(color: black)),
            onPressed: () async {
              Navigator.of(context).pop();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _image = File(pickedFile.path);
                });
              }
            },
          ),
          CupertinoActionSheetAction(
            child:
                const Text('Pick from files', style: TextStyle(color: black)),
            onPressed: () async {
              Navigator.of(context).pop();
              // final result = await FilePicker.platform.pickFiles(
              //   type: FileType.custom,
              //   allowedExtensions: ['jpg', 'pdf', 'doc'],
              // );
              // if (result != null && result.files.single.path != null) {
              //   setState(() {
              //     _image = File(result.files.single.path!);
              //   });
              // }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel', style: TextStyle(color: black)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
