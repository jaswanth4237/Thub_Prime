String getApiBaseUrl() {
  const envBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (envBaseUrl.isNotEmpty) {
    return envBaseUrl;
  }

  return 'https://backend-thubprime.onrender.com';
}
