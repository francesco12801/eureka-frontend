import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/my_text_button.dart';
import 'package:eureka_final_version/frontend/models/genie.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:eureka_final_version/frontend/views/AcceptTerms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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

class _PostCardCreationState extends State<PostCardCreation>
    with TickerProviderStateMixin {
  // Variables to manage position etc...

  bool isPublic = true;
  bool isLocationEnabled = false;
  List<File>? _images = [];
  Position? _currentPosition;
  String? _city;
  List<File>? _files = [];
  final picker = ImagePicker();
  final List<String>? imageStringList = [];
  final List<String>? fileStringList = [];

  // Helper
  final authHelper = AuthHelper();
  final userHelper = UserHelper();
  final genieHelper = GenieHelper();

  // Storage

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // Animation controller for removing image
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  Future<String?> getProfileImage() async {
    return await userHelper.getProfileImage();
  }

  Future<void> createLocalGenie() async {
    final title = _titleController.text;
    final description = _contentController.text;

    final target = isPublic ? 'public' : 'private';
    final nameSurnameCreator = widget.userData.nameSurname;
    final professionUser = widget.userData.profession;
    final location = _city;

    for (final image in _images!) {
      imageStringList!.add(image.path);
    }

    for (final file in _files!) {
      fileStringList!.add(file.path);
    }

    final Genie dataGenie = Genie(
      title: title,
      description: description,
      location: location,
      target: target,
      images: imageStringList,
      files: fileStringList,
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

  void pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc'],
      );

      if (result != null) {
        setState(() {
          _files!.add(File(result.files.single.path!));
        });
      } else {}
    } catch (e) {
      AlertDialog(
        title: const Text('Error'),
        content: Text(e.toString()),
      );
    }
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
    return FutureBuilder<String?>(
      future: getProfileImage(), // Call your asynchronous function
      builder: (context, snapshot) {
        String? profileImage = snapshot.data; // Fetched image URL
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching the image
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || profileImage == null) {
          profileImage = 'https://www.gravatar.com/avatar/?d=mp';
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    CupertinoIcons.clear,
                    color: white,
                  ),
                ),
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
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(profileImage),
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
      },
    );
  }

  Future<void> _showAttachmentOptions(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Pick from gallery',
                style: TextStyle(color: Colors.black)),
            onPressed: () async {
              Navigator.of(context).pop();
              final picker = ImagePicker();
              final pickedFiles = await picker.pickMultiImage();
              setState(() {
                _images = pickedFiles
                    .map((pickedFile) => File(pickedFile.path))
                    .toList();
              });
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Pick from files',
                style: TextStyle(color: Colors.black)),
            onPressed: () async {
              Navigator.of(context).pop();
              pickFile(); // Supponendo che tu abbia un metodo per scegliere file
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _removeImage(int index) async {
    setState(() {
      _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutQuart),
      );
    });

    await _animationController.forward();

    setState(() {
      _images!.removeAt(index);
    });

    _animationController.reverse();
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            fontSize: 24,
          ),
        ),
        TextField(
          controller: _contentController,
          focusNode: _focusNode,
          minLines: 1,
          maxLines: null,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Write your description...',
            hintStyle: TextStyle(
                color: Color.fromARGB(255, 188, 187, 187),
                fontFamily: 'Roboto'),
            border: InputBorder.none,
          ),
        ),
        if (_images!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _images!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _opacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: child,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _images![index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        if (_files!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _files!.map((file) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (file.path.endsWith('.pdf'))
                        SizedBox(
                          height: 200,
                          child: PDFView(
                            filePath: file.path,
                            autoSpacing: false,
                            fitPolicy: FitPolicy.BOTH,
                            backgroundColor: cardColor,
                          ),
                        ),
                      if (file.path.endsWith('.txt'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: FutureBuilder<String>(
                            future: file.readAsString(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(color: Colors.white),
                                );
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                        ),
                      if (file.path.endsWith('.jpg') ||
                          file.path.endsWith('.jpeg') ||
                          file.path.endsWith('.png'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Image.file(
                            file,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
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

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
