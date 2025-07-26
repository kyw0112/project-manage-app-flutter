
import 'package:actual/my_project/model/member_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'project_repository.g.dart';

@RestApi()
abstract class ProjectRepository{
  //여러개의 인스턴스에서 같은 디오를 공유하는 이유?
  //공통되는 부분을 baseUrl로 넣는다? ex: http://$ip/project_member
  //_ProjectRepository는 retrofit에 의해 자동으로 생성됨
  factory ProjectRepository(Dio dio, {String baseUrl}) = _ProjectRepository;

  //http://$ip/project_member
  // @GET('/')
  // paginate()

  //http://$ip/project_member/:id
  @GET('/{id}')
  Future<MemberModel> getProjectMember({
    // @Path() required String id,
    @Path('id') required String projectId,

  });

  //abstract로 선언했기에 인스턴스를 생성못하므로 함수의 바디 부분은 적어줄 필요 없다.
  //어떤 값이 반환되는가? -> 어떤 모델로 맵핑이 되는가?

}