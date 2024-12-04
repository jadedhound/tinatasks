import 'package:tinatasks/api/client.dart';
import 'package:tinatasks/api/response.dart';
import 'package:tinatasks/api/service.dart';
import 'package:tinatasks/models/bucket.dart';
import 'package:tinatasks/service/services.dart';

class BucketAPIService extends APIService implements BucketService {
  BucketAPIService(TinaClient client) : super(client);

  @override
  Future<Bucket?> add(int projectId, int viewId, Bucket bucket) {
    return client
        .put('/projects/$projectId/views/$viewId/buckets',
            body: bucket.toJson())
        .then((response) {
      if (response == null) return null;
      return Bucket.fromJson(response.body);
    });
  }

  @override
  Future delete(int projectId, int viewId, int bucketId) {
    return client
        .delete('/projects/$projectId/views/$viewId/buckets/$bucketId');
  }

  /* Not implemented in the Vikunja API
  @override
  Future<Bucket> get(int listId, int bucketId) {
    return client
        .get('/lists/$listId/buckets/$bucketId')
        .then((response) => Bucket.fromJSON(response.body));
  }
  */

  @override
  Future<Response?> getAllByList(int projectId, int viewId,
      [Map<String, List<String>>? queryParameters]) {
    return client
        .get('/projects/$projectId/views/$viewId/tasks', queryParameters)
        .then((response) => response != null
            ? new Response(
                convertList(response.body, (result) => Bucket.fromJson(result)),
                response.statusCode,
                response.headers)
            : null);
  }

  @override
  // TODO: implement maxPages
  int get maxPages => maxPages;

  @override
  Future<Bucket?> update(Bucket bucket, int projectId, int viewId) {
    return client
        .post('/projects/$projectId/views/$viewId/buckets/${bucket.id}',
            body: bucket.toJson())
        .then((response) {
      if (response == null) return null;
      return Bucket.fromJson(response.body);
    });
  }
}
