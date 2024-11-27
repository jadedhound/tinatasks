import 'package:tinatasks/api/client.dart';
import 'package:tinatasks/api/service.dart';
import 'package:tinatasks/models/server.dart';

import '../service/services.dart';

class ServerAPIService extends APIService implements ServerService {
  ServerAPIService(Client client) : super(client);

  @override
  Future<Server?> getInfo() {
    return client.get('/info').then((value) {
      if (value == null) return null;
      return Server.fromJson(value.body);
    });
  }
}
