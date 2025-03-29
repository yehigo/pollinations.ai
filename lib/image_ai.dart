import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pollinations_ai/api_config.dart';
import 'package:pollinations_ai/common.dart';

/// ImageAi class
/// This class is used to generate images using the Pollinations API.
class ImageAi {
  String model;
  dynamic seed;
  int width;
  int height;
  bool enhance;
  bool nologo;
  bool private;
  bool safe;
  String referrer;
  DateTime timestamp;

  String? prompt;
  dynamic response;
  String file = "pollinations-image.png";

  /// Constructor for ImageAi class.
  ///
  /// @param model The model to use for image generation. Default is "flux".
  /// @param seed The seed to use for image generation. Default is "random".
  /// @param width The width of the generated image. Default is 1024.
  /// @param height The height of the generated image. Default is 1024.
  /// @param enhance Whether to enhance the image. Default is false.
  /// @param nologo Whether to include a logo in the image. Default is false.
  /// @param private Whether to make the image private. Default is false.
  /// @param safe Whether to make the image safe. Default is false.
  /// @param referrer The referrer to use for the API call. Default is "pollinations.py".
  ImageAi({
    this.model = "flux",
    this.seed = "random",
    this.width = 1024,
    this.height = 1024,
    this.enhance = false,
    this.nologo = false,
    this.private = false,
    this.safe = false,
    this.referrer = "pollinations.py",
  }) : timestamp = DateTime.now();

  /// Calls the Pollinations API to generate an image based on the provided prompt.
  ///
  /// @param prompt The prompt to use for image generation.
  /// @return A Future that resolves to an ImageAi object with the generated image.
  Future<ImageAi> call(String prompt) async {
    final effectiveSeed = seed == "random" ? randomSeed() : seed;

    final request = ImageRequest(
      model: model,
      prompt: prompt,
      seed: effectiveSeed,
      width: width,
      height: height,
      enhance: enhance,
      nologo: nologo,
      private: private,
      safe: safe,
      referrer: referrer,
    );

    this.prompt = prompt;
    this.response = await request.call();

    return this;
  }

  /// Saves the generated image to a file.
  ///
  /// @param filePath The path to the file where the image will be saved.
  /// @return A Future that resolves to the ImageAi object.
  /// @throws StateError if the response is not an http.Response.
  /// @throws Exception if there is an error saving the image.
  Future<ImageAi> save(String filePath) async {
    if (response is! http.Response) {
      throw StateError('Response is not an http.Response.  Cannot save.');
    }
    file = filePath;
    final http.Response res = response; // Use a local variable
    final bytes = res.bodyBytes; // Get the bytes

    try {
      final fileHandle = await File(filePath).create(recursive: true);
      await fileHandle.writeAsBytes(bytes);
    } catch (e) {
      print("Error saving image: $e");
      rethrow; // Important: rethrow the error to be caught by the caller.
    }

    return this;
  }

  @override
  String toString() {
    return "ImageAi(model: $model, seed: $seed, width: $width, height: $height, enhance: $enhance, nologo: $nologo, private: $private, safe: $safe, referrer: $referrer, timestamp: $timestamp)";
  }

  String toJson() {
    return json.encode({
      "model": model,
      "seed": seed,
      "width": width,
      "height": height,
      "enhance": enhance,
      "nologo": nologo,
      "private": private,
      "safe": safe,
      "referrer": referrer,
      "timestamp": timestamp.toIso8601String(),
    });
  }

  /// Get the list of available models from the Pollinations API.
  /// @return A Future that resolves to a list of models.
  static Future<List<dynamic>> models() async {
    final response = await http
        .get(
          Uri.parse("https://${ApiConfig.getEndpoint(Api.image)}/models"),
          headers: ApiConfig.headers,
        )
        .timeout(Duration(seconds: ApiConfig.timeout));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }
}

/// ImageRequest class internal to [ImageAi]
/// This class is used to create a request for generating an image using the Pollinations API.
class ImageRequest {
  String model;
  String prompt;
  dynamic seed;
  int width;
  int height;
  bool enhance;
  bool nologo;
  bool private;
  bool safe;
  String referrer;
  DateTime timestamp;

  /// Constructor for ImageRequest class.
  ///
  /// @param model The model to use for image generation. Default is "flux".
  /// @param prompt The prompt to use for image generation.
  /// @param seed The seed to use for image generation. Default is "random".
  /// @param width The width of the generated image. Default is 1024.
  /// @param height The height of the generated image. Default is 1024.
  /// @param enhance Whether to enhance the image. Default is false.
  /// @param nologo Whether to include a logo in the image. Default is false.
  /// @param private Whether to make the image private. Default is false.
  /// @param safe Whether to make the image safe. Default is false.
  /// @param referrer The referrer to use for the API call. Default is "pollinations.py".
  ImageRequest({
    this.model = "flux",
    this.prompt = "",
    this.seed = "",
    this.width = 1024,
    this.height = 1024,
    this.enhance = false,
    this.nologo = false,
    this.private = false,
    this.safe = false,
    this.referrer = "pollinations.py",
  }) : timestamp = DateTime.now();

  /// Calls the Pollinations API to generate an image based on the provided prompt.
  /// @return A Future that resolves to an http.Response object with the generated image.
  Future<http.Response> call() async {
    final params = {
      "safe": safe.toString(),
      "seed": seedValue.toString(),
      "width": width.toString(),
      "height": height.toString(),
      "nologo": nologo.toString(),
      "private": private.toString(),
      "model": model,
      "enhance": enhance.toString(),
      "referrer": referrer,
    };

    final uri = Uri.parse(
      "https://${ApiConfig.getEndpoint(Api.image)}/prompt/$prompt",
    ).replace(queryParameters: params);

    final response = await http
        .get(uri, headers: ApiConfig.headers)
        .timeout(Duration(seconds: ApiConfig.timeout));
    return response;
  }

  /// Computes the seed value based on the provided seed parameter.
  /// If the seed is "random", it generates a random seed else it returns current value seed.
  /// @return The computed seed value.
  int computeSeedValue() {
    if (seed == "random") {
      seed = randomSeed();
    }
    return seed;
  }

  int get seedValue => computeSeedValue();

  @override
  String toString() {
    return "ImageRequest(model: $model, prompt: $prompt, seed: $seedValue, width: $width, height: $height, enhance: $enhance, nologo: $nologo, private: $private, safe: $safe, referrer: $referrer, timestamp: $timestamp)";
  }

  String toJson() {
    return json.encode({
      "class": "ImageRequest",
      "model": model,
      "prompt": prompt,
      "seed": seedValue,
      "width": width,
      "height": height,
      "enhance": enhance,
      "nologo": nologo,
      "private": private,
      "safe": safe,
      "referrer": referrer,
      "timestamp": timestamp.toIso8601String(),
    });
  }
}
