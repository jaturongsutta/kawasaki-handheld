import 'package:flutter/material.dart';

class ApiConfig {
  static const ApiConfig local = ApiConfig._(
      endpoint: "http://192.168.1.103:84/api", //local
      endpointName: "Local",
      colors: [
        Color(0xFF11CDEF),
        Color(0xFF1171EF),
      ],
      endpointOCR: 'http://192.168.1.103:8765',
      bearerTokenOCR: 'test_api_token123');

  static const ApiConfig sandbox = ApiConfig._(
      endpoint: "http://27.254.253.176:82/api", // sandbox
      endpointName: "Sandbox",
      colors: [
        Color(0xFF11CDEF),
        Color.fromARGB(255, 239, 150, 17),
      ],
      endpointOCR: 'http://27.254.253.176:81/kmt-ocr-api',
      bearerTokenOCR: 'test_api_token123');

  static const ApiConfig kmtDev = ApiConfig._(
      endpoint: "http://192.168.1.15:83/api", // kmtDev
      endpointName: "Development",
      colors: [
        Color(0xFF11CDEF),
        Color.fromARGB(255, 180, 74, 194),
      ],
      endpointOCR: 'http://192.168.1.15:8765',
      bearerTokenOCR: 'test_api_token123');

  static const ApiConfig kmtProd = ApiConfig._(
      endpoint: "http://192.168.1.20:82/api", // kmtProd
      endpointName: "Production",
      colors: [
        Color(0xFF11CDEF),
        Color(0xFF6CC24A),
      ],
      endpointOCR: 'http://192.168.1.20:8765',
      bearerTokenOCR: 'test_api_token123');

  final String endpoint;
  final String endpointOCR;
  final String bearerTokenOCR;
  final String endpointName;
  final List<Color> colors;

  const ApiConfig._({
    required this.endpoint,
    required this.endpointName,
    required this.colors,
    required this.endpointOCR,
    required this.bearerTokenOCR,
  });
}

class EndpointConfig {
  static const ApiConfig currentEndpoint = ApiConfig.kmtDev;
}

// const String appVersion = "250616-1";
