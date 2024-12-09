import 'dart:ui';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/components/CommentCard.dart';
import 'package:eureka_final_version/frontend/components/my_action_button.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenieFullScreenView extends StatefulWidget {
  final Genie genie;
  final EurekaUser user;
  final GenieHelper genieHelper;

  // Actions callbacks
  final VoidCallback onLikePressed;
  final VoidCallback onSavePressed;

  // State values
  final Future<bool> isLiked;
  final Future<bool> isSaved;
  final int likesCount;
  final int savedCount;

  // Futures for loading data
  final Future<String?> profileImageFuture;
  final Future<List<String>> genieImagesFuture;
  final Future<List<String>> genieFilesFuture;

  const GenieFullScreenView({
    required this.genie,
    required this.user,
    required this.genieHelper,
    required this.onLikePressed,
    required this.onSavePressed,
    required this.isLiked,
    required this.isSaved,
    required this.likesCount,
    required this.savedCount,
    required this.profileImageFuture,
    required this.genieImagesFuture,
    required this.genieFilesFuture,
    super.key,
  });

  @override
  State<GenieFullScreenView> createState() => _GenieFullScreenViewState();
}

class _GenieFullScreenViewState extends State<GenieFullScreenView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Contenuto Scrollabile
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Card Principale
                    Hero(
                      tag: 'genie-card-${widget.genie.id}',
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildUserInfo(),
                                  const SizedBox(height: 16),
                                  _buildContent(),
                                  const SizedBox(height: 16),
                                  _buildMediaSection(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Card Commenti
                    Container(
                      margin: const EdgeInsets.fromLTRB(13, 5, 13, 80),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.chat_bubble_2_fill,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Comments',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${widget.genie.comments} comments',
                                    style: TextStyle(
                                      color: Colors.blue.shade300,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const CommentCard(
                              authorName: "Francesco Tinessa",
                              authorTitle: "Software Engineer",
                              comment: "Good job, I love your idea!",
                              timeAgo: "2h",
                              profileImageUrl: null,
                            ),
                            const SizedBox(height: 12),
                            const CommentCard(
                              authorName: "Marco Rossi",
                              authorTitle: "UX Designer",
                              comment:
                                  "This is exactly what I was looking for. Great work on the implementation!",
                              timeAgo: "5h",
                              profileImageUrl: null,
                            ),
                            const SizedBox(height: 10),
                            const CommentCard(
                              authorName: "Laura Bianchi",
                              authorTitle: "Product Manager",
                              comment:
                                  "Interesting approach. Let's discuss this further in our next meeting.",
                              timeAgo: "1d",
                              profileImageUrl: null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ActionButton(
                          icon: CupertinoIcons.heart,
                          isActive: widget.isLiked,
                          onPressed: widget.onLikePressed,
                        ),
                        ActionButton(
                          icon: CupertinoIcons.bookmark,
                          isActive: widget.isSaved,
                          isBookmark: widget.isSaved,
                          onPressed: widget.onSavePressed,
                        ),
                        _buildCollaborateButton(),
                        ActionButton(
                          icon: CupertinoIcons.chat_bubble,
                          isActive: Future.value(false),
                          onPressed: _showCommentDialog,
                        ),
                        ActionButton(
                          icon: CupertinoIcons.share,
                          isActive: Future.value(false),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborateButton() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 0,
          ),
        ),
        onPressed: () {},
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.person_2_fill,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(width: 6),
            Text(
              'Collaborate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add a comment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your comment here...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Qui aggiungeremo la logica per salvare il commento
                      if (_commentController.text.isNotEmpty) {
                        // Implementa la logica per salvare il commento
                        Navigator.pop(context);
                        _commentController.clear();
                      }
                    },
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Image.asset(
            'assets/images/slogan-nobackground.png',
            height: 60,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              widget.genieHelper.formatDate(widget.genie.createdAt.toString()),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Profile Image with border
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 0.5,
            ),
          ),
          child: FutureBuilder<String?>(
            future: widget.profileImageFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(snapshot.data!),
                );
              }
              return const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Name
        Text(
          widget.genie.nameSurnameCreator,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        // Profession
        Text(
          widget.genie.professionUser ?? '',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.location_fill,
              color: Colors.red[900],
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              widget.genie.location!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Roboto',
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.genie.title,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.genie.description,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImagesSection(),
        _buildFilesSection(),
      ],
    );
  }

  Widget _buildImagesSection() {
    return FutureBuilder<List<String>>(
      future: widget.genieImagesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: snapshot.data!.map((imageUrl) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildFilesSection() {
    return FutureBuilder<List<String>>(
      future: widget.genieFilesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: snapshot.data!.map((fileUrl) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.file_present, color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
