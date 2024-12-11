import 'dart:ui';
import 'package:eureka_final_version/frontend/api/comment/comment_manager.dart';
import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/components/CommentCard.dart';
import 'package:eureka_final_version/frontend/components/DateConverter.dart';
import 'package:eureka_final_version/frontend/components/my_action_button.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/models/constant/comment.dart';
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
  final ValueNotifier<int> _characterCount = ValueNotifier<int>(0);
  final int maxCharacters = 500;
  List<CommentEureka> _comments = [];
  bool _isLoadingComments = false;

  final CommentService _commentService = CommentService();

  @override
  void initState() {
    super.initState();
    _loadComments();
    _commentController.addListener(() {
      _characterCount.value = _commentController.text.length;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _characterCount.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (_isLoadingComments) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final comments = await _commentService.getGenieComments(widget.genie.id!);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
    } finally {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  void _handleCommentSubmit() async {
    if (_commentController.text.isEmpty) return;

    try {
      debugPrint('genieId from comment creation: ${widget.genie.id}');
      final newComment = await _commentService.createComment(
        widget.genie.id!,
        _commentController.text,
      );
      debugPrint('New comment: $newComment');

      setState(() {
        _comments.insert(0, newComment);
      });

      _commentController.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to post comment. Please try again later.')),
      );
    }
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
                            const SizedBox(height: 16),
                            _isLoadingComments
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : _comments.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.chat_bubble_2,
                                              color:
                                                  Colors.blue.withOpacity(0.5),
                                              size: 48,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Be the first to comment! 🥳',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Share your thoughts on this amazing idea.',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: _showCommentDialog,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Add Comment',
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: _comments
                                            .map((comment) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10),
                                                  child: CommentCard(
                                                    authorName:
                                                        comment.authorName,
                                                    authorTitle: comment
                                                        .authorProfession!,
                                                    comment: comment.content,
                                                    timeAgo: DateConverter
                                                        .getTimeAgo(
                                                            comment.createdAt),
                                                    profileImageUrl: comment
                                                        .authorProfileImage,
                                                    onLike: () {},
                                                    onReply:
                                                        (String replyText) {},
                                                  ),
                                                ))
                                            .toList(),
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
                          isBookmark: widget.isSaved,
                          onPressed: widget.onSavePressed,
                        ),
                        _buildCollaborateButton(),
                        ActionButton(
                          icon: CupertinoIcons.chat_bubble,
                          onPressed: _showCommentDialog,
                        ),
                        ActionButton(
                          icon: CupertinoIcons.share,
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                    gradient: LinearGradient(
                      colors: [Colors.blue, Color(0xFF1E88E5)],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add a comment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Text(
                        'Share your thoughts with others',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          letterSpacing: 0.2,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Comment input area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Text(
                    widget.user.nameSurname[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // TextField and character counter
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _commentController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 5,
                        minLines: 3,
                        maxLength: maxCharacters,
                        decoration: InputDecoration(
                          hintText: 'Write your comment here...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'Roboto',
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: _characterCount,
                        builder: (context, count, child) {
                          final remainingChars = maxCharacters - count;
                          return Text(
                            '$remainingChars characters remaining',
                            style: TextStyle(
                              color: remainingChars < 50
                                  ? Colors.orange
                                  : Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Post button
                ValueListenableBuilder<int>(
                  valueListenable: _characterCount,
                  builder: (context, count, child) {
                    final bool isValid = count > 0 && count <= maxCharacters;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isValid
                              ? [Colors.blue, Colors.blue.shade700]
                              : [Colors.grey, Colors.grey.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isValid
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton(
                        onPressed: isValid ? _handleCommentSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.paperplane_fill,
                              size: 16,
                              color: isValid ? Colors.white : Colors.white54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Post',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isValid ? Colors.white : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
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
