import 'package:eureka_final_version/frontend/models/genie.dart';
import 'package:eureka_final_version/frontend/models/user.dart';

class SearchResult {
  final bool success;
  final List<EurekaUser>? users;
  final List<Genie>? genies;

  SearchResult({required this.success, this.users, this.genies});
}
