import 'package:pollinations_ai/common.dart';

/// This class is used to configure the API endpoints and headers for the Pollinations API.
class ApiConfig {
  static const String textEndpoint = "text.pollinations.ai";
  static const String imageEndpoint = "image.pollinations.ai";
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };
  static const int timeout = 80;

  /// Returns the endpoint based on the API type.
  /// @param api The API type [Api].
  /// @return The endpoint URL as a string.
  static String getEndpoint(Api api) {
    switch (api) {
      case Api.text:
        return textEndpoint;
      case Api.image:
        return imageEndpoint;
    }
  }
}
