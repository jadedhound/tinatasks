import 'package:tinatasks/api/service.dart';
import 'package:tinatasks/models/project_view.dart';
import 'package:tinatasks/service/services.dart';

class ProjectViewAPIService extends APIService implements ProjectViewService {
  ProjectViewAPIService(client) : super(client);

  @override
  Future<ProjectView?> create(ProjectView view) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future delete(int projectId, int viewId) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<ProjectView?> get(int projectId, int viewId) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<ProjectView?> update(ProjectView view) {
    print(view.toJson());
    return client
        .post('/projects/${view.projectId}/views/${view.id}',
            body: view.toJson())
        .then((response) {
      if (response == null) return null;
      return ProjectView.fromJson(response.body);
    });
  }
}
