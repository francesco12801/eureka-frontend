import 'package:eureka_final_version/frontend/api/auth/auth_api.dart';
import 'package:eureka_final_version/frontend/components/my_style.dart';
import 'package:eureka_final_version/frontend/constants/routes.dart';
import 'package:eureka_final_version/frontend/models/post.dart';
import 'package:eureka_final_version/frontend/components/my_navigation_bar.dart';
import 'package:eureka_final_version/frontend/models/user.dart';
import 'package:eureka_final_version/frontend/views/LoginPage.dart';
import 'package:eureka_final_version/frontend/views/SearchPage.dart';
import 'package:eureka_final_version/frontend/api/navigation_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final EurekaUser userData;

  HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _secureStorage = const FlutterSecureStorage();
  final AuthHelper authHelper = AuthHelper();

  // On tap method for the navigation bar
  void onTap(int index) async {
    String? token = await _secureStorage.read(key: 'auth_token');

    if (token == null) {
      // Handle token not found
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Token Not Found'),
          content: Text('Token not found. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  loginRoute,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    bool isVerified = await authHelper.checkToken();

    if (isVerified) {
      switch (index) {
        case 0:
          Navigator.pushNamed(
            context,
            homePageRoute,
            arguments: widget.userData,
          );
          break;
        case 1:
          Navigator.pushNamed(
            context,
            notificationPageRoute,
            arguments: widget.userData,
          );
          break;
        case 2:
          Navigator.pushNamed(
            context,
            eurekaRoute,
            arguments: widget.userData,
          );
          break;
        case 3:
          Navigator.pushNamed(
            context,
            networkRoute,
            arguments: widget.userData,
          );
          break;
        case 4:
          Navigator.pushNamed(
            context,
            profileRoute,
            arguments: widget.userData,
          );
          break;
        default:
          Navigator.pushNamed(
            context,
            homePageRoute,
            arguments: widget.userData,
          );
      }
    } else {
      // Handle token verification failure
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Verification Failed'),
          content:
              const Text('Token verification failed. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                NavigationHelper.navigateToPage(context, const LoginPage());
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  final List<PostData> posts = [
    PostData(
      avatar: 'assets/images/bsc.jpeg',
      name: 'Francesco Tinessa',
      role: 'Software Engineer',
      time: 2,
      title: 'App Idea',
      content:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. ',
      likes: 2300,
      comments: 2300,
      saved: 3000,
    ),
    PostData(
      avatar: 'assets/images/bsc.jpeg',
      name: 'A. Franzoso',
      role: 'Software Engineer',
      time: 2,
      title: 'App Idea',
      content:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      likes: 2300,
      comments: 2300,
      saved: 4000,
    ),
  ];

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
                          icon: const Icon(
                            CupertinoIcons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(
                                  userData: widget.userData,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 150,
                          child: Image.asset(
                            'assets/images/slogan-nobackground.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.bubble_left_bubble_right,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // SliverList(
            //   delegate: SliverChildBuilderDelegate(
            //     (BuildContext context, int index) {
            //       return GenieCard(genie: posts[index]);
            //     },
            //     childCount: posts.length,
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          onTap(index);
        },
      ),
    );
  }
}
