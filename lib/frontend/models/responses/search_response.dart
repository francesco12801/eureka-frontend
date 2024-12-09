import 'package:eureka_final_version/frontend/models/constant/genie.dart';
import 'package:eureka_final_version/frontend/models/constant/user.dart';

class SearchResult {
  final bool success;
  final List<EurekaUser>? users;
  final List<Genie>? genies;

  SearchResult({required this.success, this.users, this.genies});
}
