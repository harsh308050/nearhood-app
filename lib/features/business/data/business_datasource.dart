import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:nearhood/core/network/http_response.dart';

class BusinessDataSource {
  final ApiUrls _apiUrls = ApiUrls();
  final http.Client _client = http.Client();

  Future<HttpActions> _http() async {
    return HttpActions(
      client: _client,
      baseUrl: _apiUrls.baseUrl,
      tokenProvider: () async =>
          FirebaseAuth.instance.currentUser?.getIdToken(),
    );
  }

  Future<HttpResponse> checkBusinessProfile() async {
    final httpActions = await _http();
    return httpActions.get('/business/my/profile');
  }

  Future<HttpResponse> registerBusiness(Map<String, dynamic> data) async {
    final httpActions = await _http();
    return httpActions.post('/business/register', body: data);
  }

  Future<HttpResponse> uploadMedia(String filePath, String field) async {
    final httpActions = await _http();
    final file = await http.MultipartFile.fromPath(field, filePath);
    return httpActions.postMultipart('/business/upload-media', files: [file]);
  }

  void dispose() {
    _client.close();
  }
}
