import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60), // 60 seconds
    receiveTimeout: const Duration(seconds: 60), // 60 seconds
    sendTimeout: const Duration(seconds: 60), // 60 seconds
  ));
  final String baseUrl = 'https://fine-lizard-smoothly.ngrok-free.app/api/auth';

  Future<File> compressFile(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.absolute.path}_compressed.jpg',
      quality: 70, // Adjust quality as needed
    );
    return result ?? file;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'userName': response.data['userName'],
          'userProfileImage': response.data['userProfileImage'],
          'firstName': response.data['firstName'],
          'lastName': response.data['lastName'],
          'email': response.data['email'],
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Login failed. Please try again.',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final Map<String, dynamic> errorResponse = e.response!.data;
        return {
          'success': false,
          'message': errorResponse['message'] ??
              'Error occurred. Please try again later.',
        };
      } else {
        return {
          'success': false,
          'message': 'Network error occurred. Please check your connection.',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Unexpected error occurred. Please try again later.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOTP(
      String email, String username, String otp, String fcmToken) async {
    try {
      final response = await _dio.post(
        '$baseUrl/verify-otp',
        data: {
          'email': email,
          'username': username,
          'otp': otp,
          'fcmToken': fcmToken, // Pass fcmToken in the request data
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP verification successful.',
          'username': response.data['username'],
          'profileImage': response.data['profileImage'],
          'avatarImage': response.data['avatarImage'],
          'token': response.data['token'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ??
              'OTP verification failed. Please try again.',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final Map<String, dynamic> errorResponse = e.response!.data;
        return {
          'success': false,
          'message': errorResponse['message'] ??
              'Error occurred. Please try again later.',
        };
      } else {
        return {
          'success': false,
          'message': 'Network error occurred. Please check your connection.',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Unexpected error occurred. Please try again later.',
      };
    }
  }

  Future<Map<String, dynamic>> signup(String firstName, String lastName,
      String email, String password, String dob, String gender,
      {File? profileImage, File? avatarImage}) async {
    try {
      // Compress images if they are provided
      if (profileImage != null) {
        profileImage = await compressFile(profileImage);
      }
      if (avatarImage != null) {
        avatarImage = await compressFile(avatarImage);
      }

      final formData = FormData.fromMap({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'dob': dob,
        'gender': gender,
        if (profileImage != null)
          'profilePicture': await MultipartFile.fromFile(profileImage.path),
        if (avatarImage != null)
          'avatar': await MultipartFile.fromFile(avatarImage.path),
      });

      final response = await _dio.post(
        '$baseUrl/signup',
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'username': responseData['username'],
          'profilePicture': responseData['profilePicture'],
          'firstName': responseData['firstName'],
          'lastName': responseData['lastName'],
          'email': responseData['email'],
        };
      } else {
        final responseData = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Signup failed. Please try again.',
        };
      }
    } on DioException catch (e) {
      String errorMessage =
          'Network error occurred. Please check your connection.';
      if (e.response != null) {
        final errorResponse = e.response!.data;
        errorMessage = errorResponse is Map<String, dynamic>
            ? errorResponse['message'] ??
                'Error occurred. Please try again later.'
            : 'Error occurred. Please try again later.';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Unexpected error occurred. Please try again later.',
      };
    }
  }
}
