import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {
  final String authorName;
  final String authorTitle;
  final String comment;
  final String timeAgo;
  final String? profileImageUrl;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final Function() onLike;
  final Function(String) onReply;
  final Function()? onDelete;
  final bool isAuthor;

  const CommentCard({
    super.key,
    required this.authorName,
    required this.authorTitle,
    required this.comment,
    required this.timeAgo,
    this.profileImageUrl,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
    required this.onLike,
    required this.onReply,
    this.onDelete,
    this.isAuthor = false,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  bool _isHovered = false;
  bool _isReplying = false;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _handleLike() {
    widget.onLike();
    if (widget.isLiked) {
      _likeController.reverse();
    } else {
      _likeController.forward();
    }
  }

  void _handleReplyTap() {
    setState(() {
      _isReplying = !_isReplying;
    });
    if (_isReplying) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _replyFocusNode.requestFocus();
      });
    }
  }

  void _handleSubmitReply() {
    if (_replyController.text.trim().isEmpty) return;
    widget.onReply(_replyController.text);
    _replyController.clear();
    setState(() {
      _isReplying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(_isHovered ? 0.4 : 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 8),
                          _buildContent(),
                        ],
                      ),
                    ),
                    if (widget.isAuthor) _buildMoreButton(),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActions(),
              ],
            ),
          ),
          if (_isReplying) _buildReplySection(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Hero(
      tag: 'avatar-${widget.authorName}',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: widget.profileImageUrl != null
              ? NetworkImage(widget.profileImageUrl!)
              : null,
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: widget.profileImageUrl == null
              ? const Icon(CupertinoIcons.person_fill,
                  color: Colors.white70, size: 24)
              : null,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.authorName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),
              ),
              Text(
                widget.authorTitle,
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.timeAgo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      widget.comment,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 14,
        height: 1.4,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _buildMoreButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        CupertinoIcons.ellipsis_vertical,
        color: Colors.white.withOpacity(0.6),
        size: 20,
      ),
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(CupertinoIcons.delete, color: Colors.red.shade400, size: 20),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red.shade400)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'delete' && widget.onDelete != null) {
          widget.onDelete!();
        }
      },
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildActionButton(
          icon:
              widget.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          label: widget.likesCount.toString(),
          onTap: _handleLike,
          isActive: widget.isLiked,
          activeColor: Colors.red,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: CupertinoIcons.reply,
          label: widget.repliesCount > 0
              ? widget.repliesCount.toString()
              : 'Reply',
          onTap: _handleReplyTap,
          isActive: _isReplying,
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    required Color activeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? activeColor : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplySection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(
                    CupertinoIcons.person_fill,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    focusNode: _replyFocusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Write your reply...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isReplying = false;
                    });
                    _replyController.clear();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.6),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                _buildSubmitButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _replyController,
      builder: (context, value, child) {
        final bool hasText = value.text.trim().isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasText
                  ? [Colors.blue, Colors.blue.shade700]
                  : [Colors.grey, Colors.grey.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: hasText
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
            onPressed: hasText ? _handleSubmitReply : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.paperplane_fill,
                  size: 16,
                  color: hasText ? Colors.white : Colors.white54,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reply',
                  style: TextStyle(
                    color: hasText ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
