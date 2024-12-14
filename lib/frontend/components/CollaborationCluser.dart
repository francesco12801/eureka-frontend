import 'package:eureka_final_version/frontend/models/constant/collaboration.dart';

class CollaborationCluster {
  final String genieId;
  final List<Collaboration> collaborations;
  bool isExpanded;
  String? genieName;
  String? genieOwner;

  CollaborationCluster({
    required this.genieId,
    required this.collaborations,
    this.isExpanded = false,
    this.genieName,
    this.genieOwner,
  });
}
