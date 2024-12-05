import 'package:eureka_final_version/frontend/api/file_helper.dart';
import 'package:eureka_final_version/frontend/api/toggle/toggle_helper.dart';
import 'package:flutter/material.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/models/genie.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class GeniePublicCard extends StatefulWidget {
  final Genie genie;
  final EurekaUser user;

  // Helper
  final GenieHelper genieHelper;
  final UserHelper userHelper = UserHelper();
  final ToggleHelper toggleHelper = ToggleHelper();
  final FileHelper fileHelper = FileHelper();

  GeniePublicCard({
    required this.genie,
    required this.user,
    required this.genieHelper,
    super.key,
  });

  @override
  _GeniePublicCardState createState() => _GeniePublicCardState();
}

class _GeniePublicCardState extends State<GeniePublicCard> {
  late Future<String?> _profileImageFuture;
  late Future<List<String>> _genieImagesFuture;
  late Future<List<String>> _genieFilesFuture;
  late Future<bool> isLiked;
  late Future<bool> isSaved;

  int _likesCount = 0;
  int _savedCount = 0;

  @override
  void initState() {
    super.initState();
    _profileImageFuture =
        widget.userHelper.getPublicProfileImage(widget.user.uid);
    _genieImagesFuture = widget.genieHelper.getImageFromGenie(widget.genie);
    _genieFilesFuture = widget.genieHelper.getFilesFromGenie(widget.genie);
    _initializeLikesCount();
    _initializeSavedCount();
    isLiked = widget.toggleHelper.isLiked(widget.genie);
    isSaved = widget.toggleHelper.isSaved(widget.genie);
  }

  Future<void> _initializeLikesCount() async {
    _likesCount = await widget.genieHelper.getLikesCount(widget.genie);
    setState(() {});
  }

  Future<void> _initializeSavedCount() async {
    _savedCount = await widget.genieHelper.getSavedCount(widget.genie);
    setState(() {});
  }

  Future<void> _toggleSave() async {
    // Save the current state
    final currentIsSaved = await isSaved;
    final newIsSaved = !currentIsSaved;

    final currentSavedCount = _savedCount;

    // Update the local state to reflect the change immediately
    setState(() {
      isSaved = Future.value(newIsSaved);
      _savedCount = currentSavedCount + (newIsSaved ? 1 : -1);
    });

    try {
      // Send the change to the backend
      final response = await widget.toggleHelper.toogleSave(
        widget.genie.id!,
        newIsSaved ? 'save' : 'unsave',
      );

      if (!response) {
        // If the request fails, revert the state
        setState(() {
          isSaved = Future.value(currentIsSaved);
          _savedCount = currentSavedCount;
        });
        throw Exception("Error saving/un-saving the item.");
      }
    } catch (e) {
      debugPrint("Error: $e");

      // Revert the state in case of an exception
      setState(() {
        isSaved = Future.value(currentIsSaved);
        _savedCount = currentSavedCount;
      });
    }
  }

  Future<void> _toggleLike() async {
    final currentIsLiked = await isLiked;
    final newIsLiked = !currentIsLiked;

    final currentLikesCount = _likesCount;

    setState(() {
      isLiked = Future.value(newIsLiked);
      _likesCount = currentLikesCount +
          (newIsLiked ? 1 : -1); // Aggiorna il contatore localmente
    });

    try {
      final response = await widget.toggleHelper.toogleLike(
        widget.genie.id!,
        newIsLiked ? '+1' : '-1',
      );

      if (!response) {
        setState(() {
          isLiked = Future.value(currentIsLiked);
          _likesCount = currentLikesCount;
        });
        throw Exception("Errore nell'aggiornamento del contatore");
      }
    } catch (e) {
      debugPrint("backend error: $e");

      setState(() {
        isLiked = Future.value(currentIsLiked);
        _likesCount = currentLikesCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
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
                  const SizedBox(height: 16),
                  Text(
                    widget.genie.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.genie.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  _getImages(),
                  _getFiles(),
                  const SizedBox(height: 8),
                  _buildActionBar(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Likes
        GestureDetector(
          onTap: _toggleLike,
          child: Row(
            children: [
              FutureBuilder<bool>(
                future: isLiked,
                builder: (context, snapshot) {
                  final bool liked = snapshot.data ?? false;
                  return Icon(
                    CupertinoIcons.heart,
                    color: liked ? Colors.red : Colors.white,
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                widget.fileHelper.formatLikes(_likesCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
        // Comments
        _buildIconWithCount(CupertinoIcons.chat_bubble, widget.genie.comments),
        // Bookmarks with Count
        GestureDetector(
          onTap: _toggleSave,
          child: Row(
            children: [
              FutureBuilder<bool>(
                future: isSaved,
                builder: (context, snapshot) {
                  final bool saved = snapshot.data ?? false;
                  return Icon(
                    CupertinoIcons.bookmark,
                    color: saved ? Colors.yellow : Colors.white,
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                widget.fileHelper.formatLikes(_savedCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        FutureBuilder<String?>(
          future: _profileImageFuture,
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 25,
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 25,
              );
            } else {
              return CircleAvatar(
                backgroundImage: NetworkImage(snapshot.data!),
                radius: 25,
              );
            }
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.genie.nameSurnameCreator,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
              Text(
                widget.genie.professionUser!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Text(
            widget.genieHelper.formatDate(widget.genie.createdAt.toString()),
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomMenuItem({required IconData icon, required String text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getFiles() {
    return FutureBuilder<List<String>>(
      future: _genieFilesFuture,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading PDFs: ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final List<String> pdfFiles = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: pdfFiles.map((pdfUrl) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      // Handle PDF click and show the overlay
                      _showPdfOverlay(context, pdfUrl);
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // PDF icon
                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          // Display the file name under the PDF icon
                          Text(
                            "PDF", // Display only the file name
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10, // Adjust font size for better fit
                            ),
                            textAlign: TextAlign.center, // Center the text
                            maxLines: 2, // Limit to 2 lines to avoid overflow
                            overflow: TextOverflow
                                .ellipsis, // Add "..." for long text
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Show the PDF file in a dialog
  void _showPdfOverlay(BuildContext context, String pdfUrl) async {
    final localPath = await widget.fileHelper.downloadPdf(pdfUrl);
    showDialog(
      context: context,
      barrierDismissible: true, // Close on tap outside
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () =>
              Navigator.of(context).pop(), // Close dialog on background tap
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Transparent background
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              GestureDetector(
                onTap: () {}, // Prevent close when tapping inside the dialog
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height *
                      0.6, // Smaller height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PDFView(
                      filePath: localPath,
                      autoSpacing: true,
                      pageFling: true,
                      pageSnap: true,
                      onError: (e) {
                        debugPrint('Error: $e');
                      },
                      onPageError: (page, e) {
                        debugPrint('Page $page error: $e');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getImages() {
    return FutureBuilder<List<String>>(
      future: _genieImagesFuture,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading images: ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final List<String> images = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: images.map((imageUrl) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      _showImageDialog(context, imageUrl);
                    },
                    child: Image.network(
                      imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        height: 100,
                        width: 100,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconWithCount(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 6),
        Text(
          count > 1000 ? '${count / 1000}k' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }
}
