import 'package:flutter/material.dart';

class ApiConfig {
  static const ApiConfig local = ApiConfig._(
    endpoint: "http://192.168.1.10:84/api", //local
    endpointName: "Local",
    colors: [
      Color(0xFF11CDEF),
      Color(0xFF1171EF),
    ],
  );

  static const ApiConfig sandbox = ApiConfig._(
    endpoint: "http://27.254.253.176:82/api", // sandbox
    endpointName: "Sandbox",
    colors: [
      Color(0xFF11CDEF),
      Color.fromARGB(255, 239, 150, 17),
    ],
  );

  static const ApiConfig kmtDev = ApiConfig._(
    endpoint: "[backend Url]", // kmtDev
    endpointName: "Development",
    colors: [
      Color(0xFF11CDEF),
      Color.fromARGB(255, 180, 74, 194),
    ],
  );

  static const ApiConfig kmtProd = ApiConfig._(
    endpoint: "[backend Url]", // kmtProd
    endpointName: "Production",
    colors: [
      Color(0xFF11CDEF),
      Color(0xFF6CC24A),
    ],
  );

  final String endpoint;
  final String endpointName;
  final List<Color> colors;

  const ApiConfig._({
    required this.endpoint,
    required this.endpointName,
    required this.colors,
  });
}

class EndpointConfig {
  static const ApiConfig currentEndpoint = ApiConfig.kmtDev;
}

// const String appVersion = "250616-1";
