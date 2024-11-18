import 'package:eureka_final_version/frontend/models/genie.dart';

class GenieResponse {
  final bool success;
  final Genie? genie;

  GenieResponse({required this.success, this.genie});
}
