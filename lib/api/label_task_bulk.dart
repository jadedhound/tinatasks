import 'package:tinatasks/api/client.dart';
import 'package:tinatasks/api/service.dart';
import 'package:tinatasks/models/label.dart';
import 'package:tinatasks/models/labelTaskBulk.dart';
import 'package:tinatasks/models/task.dart';
import 'package:tinatasks/service/services.dart';

class LabelTaskBulkAPIService extends APIService
    implements LabelTaskBulkService {
  LabelTaskBulkAPIService(Client client) : super(client);

  @override
  Future<List<Label>?> update(Task task, List<Label>? labels) {
    if (labels == null) labels = [];
    return client
        .post('/tasks/${task.id}/labels/bulk',
            body: LabelTaskBulk(labels: labels).toJSON())
        .then((response) {
      if (response == null) return null;
      return convertList(
          response.body['labels'], (result) => Label.fromJson(result));
    });
  }
}
