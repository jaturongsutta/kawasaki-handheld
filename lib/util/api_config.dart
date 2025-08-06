import 'package:flutter/material.dart';

class ApiConfig {
  static const ApiConfig local = ApiConfig._(
    // endpoint: "http://172.20.10.13:84/api",
    endpoint: "http://192.168.1.10:84/api",
    // endpoint: "http://27.254.253.176:82/api",
    endpointDownloadApk: "https://bas-zeus.ftcs.in.th:86/api",
    endpointName: "Local",
    colors: [
      Color(0xFF11CDEF),
      Color(0xFF1171EF),
    ],
  );

  final String endpoint;
  final String endpointDownloadApk;
  final String endpointName;
  final List<Color> colors;

  const ApiConfig._({
    required this.endpoint,
    required this.endpointDownloadApk,
    required this.endpointName,
    required this.colors,
  });
}

class EndpointConfig {
  static const ApiConfig currentEndpoint = ApiConfig.local;
}

// const String appVersion = "250616-1";
