import 'package:tinatasks/api/client.dart';
import 'package:tinatasks/api/service.dart';
import 'package:tinatasks/models/label.dart';
import 'package:tinatasks/service/services.dart';

class LabelAPIService extends APIService implements LabelService {
  LabelAPIService(TinaClient client) : super(client);

  @override
  Future<Label?> create(Label label) {
    return client.put('/labels', body: label.toJson()).then((response) {
      if (response == null) return null;
      return Label.fromJson(response.body);
    });
  }

  @override
  Future<Label?> delete(Label label) {
    return client.delete('/labels/${label.id}').then((response) {
      if (response == null) return null;
      return Label.fromJson(response.body);
    });
  }

  @override
  Future<Label?> get(int labelID) {
    return client.get('/labels/$labelID').then((response) {
      if (response == null) return null;
      return Label.fromJson(response.body);
    });
  }

  @override
  Future<List<Label>?> getAll({String? query}) {
    String params =
        query == null ? '' : '?s=' + Uri.encodeQueryComponent(query);
    return client.get('/labels$params').then((response) {
      if (response == null) return null;
      return convertList(response.body, (result) => Label.fromJson(result));
    });
  }

  @override
  Future<Label?> update(Label label) {
    return client.post('/labels/${label.id}', body: label).then((response) {
      if (response == null) return null;
      return Label.fromJson(response.body);
    });
  }
}
