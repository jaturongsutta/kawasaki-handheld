import 'package:flutter/material.dart';

class ApiConfig {
  static const ApiConfig local = ApiConfig._(
    endpoint: "http://192.168.1.10:84/api", //local
    endpointDownloadApk: "https://bas-zeus.ftcs.in.th:86/api",
    endpointName: "Local",
    colors: [
      Color(0xFF11CDEF),
      Color(0xFF1171EF),
    ],
  );

  static const ApiConfig sandbox = ApiConfig._(
    endpoint: "http://27.254.253.176:82/api", // sandbox
    endpointDownloadApk: "https://bas-zeus.ftcs.in.th:86/api",
    endpointName: "Local",
    colors: [
      Color(0xFF11CDEF),
      Color(0xFF1171EF),
    ],
  );

  static const ApiConfig customer = ApiConfig._(
    endpoint: "http://192.168.1.15:83/api", // customer
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
  static const ApiConfig currentEndpoint = ApiConfig.customer;
}

// const String appVersion = "250616-1";
