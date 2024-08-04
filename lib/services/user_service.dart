import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final String baseUrl = 'https://itsrudra.xyz/api/users/';
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserService() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
  }

  Future<String> generateQRCode(String username) async {
    try {
      final token = await _secureStorage.read(key: 'token');

      final response = await _dio.post(
        '/$username/qrcode',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['qrPath']; // Assuming server sends qrPath directly
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to generate QR code',
        );
      }
    } on DioException catch (e) {
      throw e.error ?? 'Failed to connect to the server';
    }
  }

  Future<String> getQRCodeUrl(String username) async {
    try {
      final token = await _secureStorage.read(key: 'token');

      final response = await _dio.get(
        '/$username/qrcode',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['qrUrl']; // Assuming server sends qrUrl directly
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch QR code URL',
        );
      }
    } on DioException catch (e) {
      throw e.error ?? 'Failed to connect to the server';
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String username) async {
    try {
      final token = await _secureStorage.read(key: 'token');

      final response = await _dio.get(
        '/$username',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['user'] != null) {
          return {
            'username' : data['user']['username'] ?? '',
            'firstName': data['user']['firstName'] ?? '',
            'lastName': data['user']['lastName'] ?? '',
            'profilePicture': data['user']['profilePicture'] ?? '',
            'createdAt': data['user']['createdAt'] ?? '',
          };
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: 'User not found',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch user details',
        );
      }
    } on DioException catch (e) {
      throw e.error ?? 'Failed to connect to the server';
    }
  }
}
