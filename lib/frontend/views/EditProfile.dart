import 'dart:io';
import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/image_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
import 'package:eureka_final_version/frontend/components/MyTextButton.dart';
import 'package:eureka_final_version/frontend/components/MyTextField.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/ProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final EurekaUser userData;
  const EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Helper
  final imageHelper = ImageHelper();
  final authHelper = AuthHelper();
  final userHelper = UserHelper();
  // Editing
  bool _isLoading = false; // Loading state
  // Edit Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioEditController = TextEditingController();
  final TextEditingController universityEditController =
      TextEditingController();
  final TextEditingController professionEditController =
      TextEditingController();
  final TextEditingController addressEditController = TextEditingController();

  // Focus Nodes
  final FocusNode _focusNodeNameSurname = FocusNode();
  final FocusNode _focusNodeBio = FocusNode();
  final FocusNode _focusNodeUniversity = FocusNode();
  final FocusNode _focusNodeProfession = FocusNode();
  final FocusNode _focusNodeAddress = FocusNode();

  XFile? _profileImage; // Profile image state
  XFile? _bannerImage; // Banner image state
  bool isProfilePicture = false;

  // Function to pick profile image
  Future<void> _pickProfileImage() async {
    isProfilePicture = true;
    final XFile? pickedImage =
        await imageHelper.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final croppedFile = await imageHelper.crop(
          file: pickedImage, isProfilePicture: isProfilePicture);
      if (croppedFile != null) {
        setState(() {
          _profileImage = XFile(croppedFile.path);
        });
      }
    }
  }

  // Function to pick banner image
  Future<void> _pickBannerImage() async {
    isProfilePicture = false;
    final XFile? pickedImage =
        await imageHelper.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final croppedFile = await imageHelper.crop(
          file: pickedImage, isProfilePicture: isProfilePicture);
      if (croppedFile != null) {
        setState(() {
          _bannerImage = XFile(croppedFile.path);
        });
      }
    }
  }

  Future<EurekaUser?> _uploadImageCall() async {
    try {
      if (_profileImage == null && _bannerImage == null) {
        return null;
      } else if (_profileImage == null && _bannerImage != null) {
        final Map<String, String> updatedUser =
            await userHelper.changeBannerImage(_bannerImage);
        final bannerImageUrl = updatedUser['bannerImage'];
        EurekaUser uploadedUser =
            widget.userData.copyWith(bannerImage: bannerImageUrl);

        return uploadedUser;
      } else if (_profileImage != null && _bannerImage == null) {
        final Map<String, String> updatedUser =
            await userHelper.changeProfileImage(_profileImage);
        final profileImageUrl = updatedUser['profileImage'];
        EurekaUser uploadedUser =
            widget.userData.copyWith(profileImage: profileImageUrl);
        return uploadedUser;
      } else {
        final Map<String, String> updatedUser =
            await userHelper.uploadImages(_profileImage, _bannerImage);
        // Get images from the response
        final profileImageUrl = updatedUser['profileImage'];
        final bannerImageUrl = updatedUser['bannerImage'];
        // Update the value of Eureka User

        EurekaUser uploadedUser = widget.userData.copyWith(
            bannerImage: bannerImageUrl, profileImage: profileImageUrl);

        return uploadedUser;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> _getEmail() async {
    final image = await userHelper.getEmail();
    return image;
  }

  Future<String> _getAddress() async {
    final response = userHelper.getAddress();
    return response;
  }

  @override
  void dispose() {
    // Clean up the controllers and focus nodes when the widget is disposed
    emailController.dispose();
    bioEditController.dispose();
    universityEditController.dispose();
    professionEditController.dispose();
    addressEditController.dispose();
    _focusNodeNameSurname.dispose();
    _focusNodeBio.dispose();
    _focusNodeUniversity.dispose();
    _focusNodeProfession.dispose();
    _focusNodeAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: primaryColor,
              automaticallyImplyLeading: false,
              floating: true,
              pinned: false,
              toolbarHeight: 56.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(CupertinoIcons.back,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context); // Go back
                          },
                        ),
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : MyTextButton(
                                text: "Save",
                                textColor: white,
                                isBold: true,
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true; // Show loader
                                  });
                                  // Call the image upload function and get the updated user
                                  final updatedUser = await _uploadImageCall();
                                  if (!mounted) return;
                                  setState(() {
                                    _isLoading = false; // Hide loader
                                  });

                                  // Return the updated user when pushing the context
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePage(userData: updatedUser!),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Row for profile image and banner image
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Profile Image Picker
                        GestureDetector(
                          onTap:
                              _pickProfileImage, // Function to pick profile image
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Image container
                                  Container(
                                    width: 110,
                                    height: 110, // Profile image size
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: greyIOS,
                                        width: 1, // Small circle border
                                      ),
                                      image: DecorationImage(
                                        image: _profileImage != null
                                            ? FileImage(File(_profileImage!
                                                .path)) // Picked image
                                            : (widget.userData.profileImage) !=
                                                        null &&
                                                    widget.userData.profileImage
                                                        .toString()
                                                        .isNotEmpty
                                                ? NetworkImage(widget
                                                    .userData.profileImage!)
                                                : const AssetImage(
                                                        'assets/images/profile_picture_placeholder.jpg')
                                                    as ImageProvider, // Default image or placeholder
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Dark overlay
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withOpacity(0.5), // Dark overlay
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  // Cupertino icon overlay
                                  const Icon(
                                    CupertinoIcons
                                        .photo_on_rectangle, // Use the desired Cupertino icon
                                    size: 30, // Size of the overlay icon
                                    color: white, // Change icon color if needed
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height: 10), // Space between image and text
                              const Text(
                                "Change your profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Banner Image Picker
                        GestureDetector(
                          onTap:
                              _pickBannerImage, // Function to pick banner image
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Image container
                                  Container(
                                    width: 110,
                                    height: 110, // Banner image size
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: greyIOS,
                                        width: 1, // Small circle border
                                      ),
                                      image: DecorationImage(
                                        image: _bannerImage != null
                                            ? FileImage(File(_bannerImage!
                                                .path)) // Picked image
                                            : widget.userData.bannerImage !=
                                                        null &&
                                                    widget.userData.bannerImage
                                                        .toString()
                                                        .isNotEmpty
                                                ? NetworkImage(widget
                                                    .userData.bannerImage!)
                                                : const AssetImage(
                                                        'assets/images/techPlaceholder.jpg')
                                                    as ImageProvider, // Default image or placeholder
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Dark overlay
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withOpacity(0.4), // Dark overlay
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  // Cupertino icon overlay
                                  const Icon(
                                    CupertinoIcons
                                        .photo_on_rectangle, // Use the desired Cupertino icon
                                    size: 30, // Size of the overlay icon
                                    color: white, // Change icon color if needed
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height: 10), // Space between image and text
                              const Text(
                                "Change your banner",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text("About You",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        )),
                    // Input fields for editing profile
                    const SizedBox(height: 25),
                    MyTextField(
                      controller: emailController,
                      hintText: _getEmail().toString(),
                      obscureText: false,
                      fieldName: "Email",
                    ),
                    const SizedBox(height: 25),
                    MyTextField(
                      controller: bioEditController,
                      hintText: widget.userData.bio ?? "Edit Bio",
                      obscureText: false,
                      fieldName: "Bio",
                    ),
                    const SizedBox(height: 30),
                    MyTextField(
                      controller: universityEditController,
                      hintText: widget.userData.university,
                      obscureText: false,
                      fieldName: "University",
                    ),
                    const SizedBox(height: 30),
                    MyTextField(
                      controller: professionEditController,
                      hintText: widget.userData.profession,
                      obscureText: false,
                      fieldName: "Profession",
                    ),
                    const SizedBox(height: 30),
                    MyTextField(
                      controller: addressEditController,
                      hintText: _getAddress().toString(),
                      obscureText: false,
                      fieldName: "Address",
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
