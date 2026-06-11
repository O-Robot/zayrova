import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zayrova/config/api_constants.dart';
import 'package:zayrova/core/exceptions/api_exceptions.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.baseUrl = ApiConstants.baseUrl,
    this.timeout = ApiConstants.receiveTimeout,
    Map<String, String>? defaultHeaders,
  }) : _httpClient = httpClient ?? http.Client(),
       _defaultHeaders = defaultHeaders ?? const {};

  final http.Client _httpClient;
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> _defaultHeaders;

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      'GET',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) {
    return _request(
      'POST',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) {
    return _request(
      'PUT',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) {
    return _request(
      'DELETE',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    try {
      final response = await _sendRequest(
        method,
        _buildUri(endpoint, queryParameters),
        headers: headers,
        body: body,
      ).timeout(timeout);

      return _handleResponse(response.statusCode, response.body);
    } on TimeoutException {
      throw const NetworkException('The request timed out. Please try again.');
    } on http.ClientException {
      throw const NetworkException(
        'Unable to connect. Please check your internet connection.',
      );
    } on FormatException {
      throw ParsingException(
        'The server returned data in an unexpected format.',
        statusCode: null,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw UnknownException('Something went wrong: $error');
    }
  }

  Future<http.Response> _sendRequest(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    final requestHeaders = _buildHeaders(headers);
    final encodedBody = body == null ? null : json.encode(body);

    switch (method) {
      case 'GET':
        return _httpClient.get(uri, headers: requestHeaders);
      case 'POST':
        return _httpClient.post(uri, headers: requestHeaders, body: encodedBody);
      case 'PUT':
        return _httpClient.put(uri, headers: requestHeaders, body: encodedBody);
      case 'DELETE':
        return _httpClient.delete(
          uri,
          headers: requestHeaders,
          body: encodedBody,
        );
      default:
        throw UnknownException('Unsupported request method: $method');
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final uri = Uri.parse('$baseUrl$endpoint');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ..._defaultHeaders,
      ...?headers,
    };
  }

  dynamic _handleResponse(int statusCode, String responseBody) {
    if (statusCode == 401) {
      throw UnauthorizedException(
        'Your session has expired. Please sign in again.',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 500) {
      throw ServerException(
        'The server could not complete the request.',
        statusCode: statusCode,
      );
    }

    if (statusCode < 200 || statusCode >= 300) {
      throw ServerException(
        _extractErrorMessage(responseBody),
        statusCode: statusCode,
      );
    }

    if (responseBody.isEmpty) {
      return null;
    }

    try {
      return json.decode(responseBody);
    } on FormatException {
      throw ParsingException(
        'The server returned data in an unexpected format.',
        statusCode: statusCode,
      );
    }
  }

  String _extractErrorMessage(String responseBody) {
    if (responseBody.isEmpty) {
      return 'The request could not be completed.';
    }

    try {
      final decodedBody = json.decode(responseBody);

      if (decodedBody is Map<String, dynamic>) {
        final message = decodedBody['message'] ?? decodedBody['error'];

        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } on FormatException {
      return responseBody;
    }

    return 'The request could not be completed.';
  }
}
