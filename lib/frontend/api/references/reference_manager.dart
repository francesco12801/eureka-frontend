import 'package:eureka_final_version/frontend/components/ReferencesView.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReferenceHelper {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<List<Reference>> getUserReferences() async {
    final String? references = await _secureStorage.read(key: 'references');
    if (references == null) {
      return [];
    }
    return [];
  }
}
