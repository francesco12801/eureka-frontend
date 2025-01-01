import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlManager {
  static String collabURL = dotenv.env['COLLAB_API_URL'] ?? '';
  static String notifyURL = dotenv.env['NOTIFICATION_API_URL'] ?? '';
  static String userURL = dotenv.env['SPRING_API_USER'] ?? '';
  static String genieURL = dotenv.env['GENIE_API_URL'] ?? '';
  static String authURL = dotenv.env['SPRING_API_AUTH'] ?? '';
  static String searchURL = dotenv.env['SEARCH_API_URL'] ?? '';
  static String toggleURL = dotenv.env['TOGGLE_API_URL'] ?? '';
  static String modifyProfileURL = dotenv.env['SPRING_API_EDIT_PROFILE'] ?? '';
  static String commentURL = dotenv.env['COMMENT_API_URL'] ?? '';
  static String middlewareURL = dotenv.env['MIDDLEWARE_API_URL'] ?? '';
  static String meetingURL = dotenv.env['MEETING_API_URL'] ?? '';

  static String getCollabURL() {
    return collabURL;
  }

  static String getMeetingURL() {
    return meetingURL;
  }

  static String getCommentURL() {
    return commentURL;
  }

  static String getNotifyURL() {
    return notifyURL;
  }

  static String getUserURL() {
    return userURL;
  }

  static String getGenieURL() {
    return genieURL;
  }

  static String getAuthURL() {
    return authURL;
  }

  static String getSearchURL() {
    return searchURL;
  }

  static String getToggleURL() {
    return toggleURL;
  }

  static String getModifyURL() {
    return modifyProfileURL;
  }

  static String getMiddlewareURL() {
    return middlewareURL;
  }
}
