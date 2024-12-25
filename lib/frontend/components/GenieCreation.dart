import 'dart:ui';

import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/MyTextButton.dart';
import 'package:eureka_final_version/frontend/components/CollaboratorListTile.dart';
import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:eureka_final_version/frontend/views/AcceptTerms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eureka_final_version/frontend/components/MyStyle.dart';
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
  final List<File> _files = [];
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

  // Collaborators
  List<EurekaUser> selectedCollaborators = [];
  final TextEditingController _searchController = TextEditingController();
  List<EurekaUser> _filteredCollaborators = [];
  final Duration _animationDuration = const Duration(milliseconds: 300);
  bool _showSelectedSection = false;

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

    final collaboratorIds =
        selectedCollaborators.map((user) => user.uid).toList();

    for (final image in _images!) {
      imageStringList!.add(image.path);
    }

    for (final file in _files) {
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
      owners: collaboratorIds,
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
        _city = placemarks[0].locality;
      });
    }
  }

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
                style: TextStyle(color: Color.fromARGB(255, 164, 11, 0)),
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

  // Widget components for _showCollaboratorsSelection
  Widget _buildHandleBar() {
    return TweenAnimationBuilder<double>(
      duration: _animationDuration,
      tween: Tween<double>(begin: 0.0, end: _showSelectedSection ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40 + (value * 20),
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2 + (value * 0.1)),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildHeaderOverlay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.xmark,
                color: Colors.white.withOpacity(0.8)),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Add Owners',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(color: greenIOS, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(StateSetter setModalState) {
    return AnimatedContainer(
      duration: _animationDuration,
      height: _showSelectedSection ? 0 : 80,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setModalState(() {
                  _filteredCollaborators = _filteredCollaborators
                      .where((user) => user.nameSurname
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search collaborators...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: Colors.white.withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCollaboratorItem(
      EurekaUser collaborator, StateSetter setModalState) {
    return TweenAnimationBuilder<double>(
      duration: _animationDuration,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'collaborator_${collaborator.uid}',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: greenIOS.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            collaborator.profileImage ??
                                'https://www.gravatar.com/avatar/?d=mp',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: _buildRemoveButton(collaborator, setModalState),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  collaborator.nameSurname.split(' ')[0],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRemoveButton(
      EurekaUser collaborator, StateSetter setModalState) {
    return GestureDetector(
      onTap: () {
        setModalState(() {
          selectedCollaborators.remove(collaborator);
          if (selectedCollaborators.isEmpty) {
            _showSelectedSection = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 164, 11, 0),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1A1A1A),
            width: 2,
          ),
        ),
        child: const Icon(
          CupertinoIcons.minus,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.person_3_fill,
            size: 48,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No collaborators found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorItem(
      EurekaUser collaborator, StateSetter setModalState) {
    final isSelected = selectedCollaborators.contains(collaborator);

    return AnimatedContainer(
      duration: _animationDuration,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2E4E3A) : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? greenIOS.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Hero(
          tag: 'collaborator_list_${collaborator.uid}',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? greenIOS : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                collaborator.profileImage ??
                    'https://www.gravatar.com/avatar/?d=mp',
              ),
            ),
          ),
        ),
        title: Text(
          collaborator.nameSurname,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          collaborator.profession,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        trailing: _buildSelectionIndicator(isSelected),
        onTap: () => _handleCollaboratorSelection(collaborator, setModalState),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return TweenAnimationBuilder<double>(
      duration: _animationDuration,
      tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
                const Color(0xFF3A3A3A), greenIOS.withOpacity(0.2), value),
            border: Border.all(
              color:
                  Color.lerp(Colors.white.withOpacity(0.1), greenIOS, value)!,
            ),
          ),
          child: Icon(
            isSelected ? CupertinoIcons.check_mark : CupertinoIcons.add,
            color: Color.lerp(Colors.white.withOpacity(0.8), greenIOS, value),
            size: 16,
          ),
        );
      },
    );
  }

  void _handleCollaboratorSelection(
      EurekaUser collaborator, StateSetter setModalState) {
    if (mounted) {
      setModalState(() {
        if (selectedCollaborators.contains(collaborator)) {
          selectedCollaborators.remove(collaborator);
          if (selectedCollaborators.isEmpty) {
            _showSelectedSection = false;
          }
        } else {
          selectedCollaborators.add(collaborator);
          _showSelectedSection = true;
        }
      });
      setState(() {}); // Aggiorna anche il widget principale
    }
  }

// Main method to show collaborators selection
  void _showCollaboratorsSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Handle e Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Handle
                            Container(
                              width: 36,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    CupertinoIcons.xmark,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Text(
                                  'Add Owners',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Done',
                                    style: TextStyle(
                                      color: greenIOS,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CupertinoSearchTextField(
                          controller: _searchController,
                          backgroundColor: const Color(0xFF2A2A2A),
                          style: const TextStyle(color: Colors.white),
                          placeholderStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                          ),
                          onChanged: (value) {
                            setModalState(() {});
                          },
                        ),
                      ),

                      // Selected Collaborators
                      if (selectedCollaborators.isNotEmpty)
                        Container(
                          height: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  selectedCollaborators.map((collaborator) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: SelectedCollaboratorChip(
                                    collaborator: collaborator,
                                    onRemove: () {
                                      setModalState(() {
                                        selectedCollaborators
                                            .remove(collaborator);
                                      });
                                      setState(() {});
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                      // Divider
                      if (selectedCollaborators.isNotEmpty)
                        Divider(color: Colors.white.withOpacity(0.1)),

                      // Collaborators List
                      Expanded(
                        child: FutureBuilder<List<EurekaUser>>(
                          future:
                              userHelper.getFriendsList(widget.userData.uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CupertinoActivityIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.person_3_fill,
                                      size: 48,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No collaborators found',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            List<EurekaUser> filteredList = snapshot.data!;
                            if (_searchController.text.isNotEmpty) {
                              filteredList = filteredList
                                  .where((user) => user.nameSurname
                                      .toLowerCase()
                                      .contains(
                                          _searchController.text.toLowerCase()))
                                  .toList();
                            }

                            return ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final user = filteredList[index];
                                final isSelected =
                                    selectedCollaborators.contains(user);

                                return CollaboratorListTile(
                                  user: user,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        selectedCollaborators.remove(user);
                                      } else {
                                        selectedCollaborators.add(user);
                                      }
                                    });
                                    setState(() {});
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 0.2,
                  )),
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
          return const Center(child: CircularProgressIndicator());
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
                if (selectedCollaborators.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: selectedCollaborators.map((collaborator) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                width: 1,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  collaborator.profileImage ??
                                      'https://www.gravatar.com/avatar/?d=mp'),
                              radius: 20,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCollaborators.remove(collaborator);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 164, 11, 0),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  CupertinoIcons.minus,
                                  color: white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                Positioned(
                  top: -1,
                  right: -1,
                  child: GestureDetector(
                    onTap: _showCollaboratorsSelection,
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
            child: const Text('Take a photo',
                style: TextStyle(color: Colors.black)),
            onPressed: () async {
              Navigator.of(context).pop();
              final picker = ImagePicker();
              final XFile? photo =
                  await picker.pickImage(source: ImageSource.camera);
              if (photo != null) {
                setState(() {
                  _images ??= [];
                  _images!.add(File(photo.path));
                });
              }
            },
          ),
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
              pickFile();
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
        if (_files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _files.map((file) {
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
    _searchController.dispose();
    super.dispose();
  }
}
