import 'package:flutter/foundation.dart';

String getApiBaseUrl() {
  const envBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (envBaseUrl.isNotEmpty) {
    return envBaseUrl;
  }

  if (kIsWeb) {
    return 'http://localhost:7100';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:7100';
    default:
      return 'http://localhost:7100';
  }
}