import 'package:flutter/material.dart';

class Reference {
  final String reviewerName;
  final String reviewerPosition;
  final String reviewText;
  final String reviewTitle;
  final String profileImage;
  final double rating;
  final DateTime timestamp;

  Reference({
    required this.reviewerName,
    required this.reviewerPosition,
    required this.reviewText,
    required this.reviewTitle,
    required this.profileImage,
    required this.rating,
    required this.timestamp,
  });
}

class ReferencesView extends StatefulWidget {
  final Future<List<Reference>> referencesFuture;

  const ReferencesView({
    Key? key,
    required this.referencesFuture,
  }) : super(key: key);

  @override
  State<ReferencesView> createState() => _ReferencesViewState();
}

class _ReferencesViewState extends State<ReferencesView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reference>>(
      future: widget.referencesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading references: ${snapshot.error}',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Stay tuned!',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'References coming soon 🌟',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final reference = snapshot.data![index];
            return ReferenceCard(reference: reference);
          },
        );
      },
    );
  }
}

class ReferenceCard extends StatelessWidget {
  final Reference reference;

  const ReferenceCard({
    Key? key,
    required this.reference,
  }) : super(key: key);

  String _getTimeAgo() {
    final difference = DateTime.now().difference(reference.timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else {
      return '${(difference.inDays / 30).floor()}mo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(reference.profileImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reference.reviewerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getTimeAgo(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reference.reviewerPosition,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            reference.reviewTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reference.reviewText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < reference.rating.floor()
                    ? Icons.star
                    : index < reference.rating
                        ? Icons.star_half
                        : Icons.star_border,
                color: Colors.amber,
                size: 24,
              );
            }),
          ),
        ],
      ),
    );
  }
}
