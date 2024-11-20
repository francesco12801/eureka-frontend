import 'package:eureka_final_version/frontend/api/genie/genie_helper.dart';
import 'package:eureka_final_version/frontend/api/user/user_helper.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/models/genie.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenieCard extends StatelessWidget {
  final Genie genie;
  final EurekaUser user;
  final GenieHelper genieHelper;
  final UserHelper userHelper = UserHelper();

  GenieCard(
      {required this.genie,
      required this.user,
      required this.genieHelper,
      super.key});

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
                    genie.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    genie.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildImagePlaceholder(),
                  const SizedBox(height: 16),
                  _buildActionBar(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Use FutureBuilder to handle the asynchronous call for profile image
        FutureBuilder<String?>(
          future:
              userHelper.getProfileImage(), // The Future you want to resolve
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for the future to resolve
              return const CircleAvatar(
                backgroundColor: Colors.grey, // Placeholder color
                radius: 25,
              );
            } else if (snapshot.hasError) {
              // Handle error if any
              return const CircleAvatar(
                backgroundColor: Colors.grey, // Placeholder color
                radius: 25,
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              // Display the profile image once the future resolves
              return CircleAvatar(
                backgroundImage: NetworkImage(snapshot.data!),
                radius: 25,
              );
            } else {
              // Fallback in case there's no data
              return const CircleAvatar(
                backgroundColor: Colors.grey, // Placeholder color
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
                genie.nameSurnameCreator,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
              Text(
                genie.professionUser!,
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
            genieHelper.formatDate(genie.createdAt.toString()),
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildActionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconWithCount(CupertinoIcons.heart, genie.likes),
        _buildIconWithCount(CupertinoIcons.chat_bubble, genie.comments),
        _buildIconWithCount(CupertinoIcons.bookmark, genie.saved),
        const Icon(CupertinoIcons.arrowshape_turn_up_right, color: iconColor),
      ],
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
