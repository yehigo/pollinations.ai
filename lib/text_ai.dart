import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:http/http.dart' as http;
import 'package:pollinations_ai/api_config.dart';
import 'package:pollinations_ai/common.dart';

/// Pollinations API TextAi class.
/// This class is used to generate text using the Pollinations API.
class TextAi {
  String model;
  String system;
  bool contextual;
  List<Message> messages;
  dynamic seed;
  bool private;
  String reasoningEffort;
  bool jsonMode;
  String referrer;
  DateTime timestamp;
  List<Message>? images;
  String? prompt;
  Request? request;
  dynamic response;
  DateTime? time;

  /// Constructor for TextAi class.
  ///
  /// @param model The model to use for text generation. Default is "openai".
  /// @param system The system message to use for text generation. Default is "".
  /// @param contextual Whether to use contextual messages. Default is false.
  /// @param messages The list of messages to use for text generation. Default is an empty list.
  /// @param seed The seed to use for text generation. Default is "random".
  /// @param private Whether to make the text generation private. Default is false.
  /// @param reasoningEffort The reasoning effort to use for text generation. Default is "low".
  /// @param jsonMode Whether to use JSON mode for text generation. Default is false.
  /// @param referrer The referrer to use for the API call. Default is "pollinations.py".
  TextAi({
    this.model = "openai",
    this.system = "",
    this.contextual = false,
    this.messages = const [],
    this.seed = "random",
    this.private = false,
    this.reasoningEffort = "low",
    this.jsonMode = false,
    this.referrer = "pollinations.py",
  }) : timestamp = DateTime.now() {
    if (messages.isEmpty) {
      messages = List.empty(growable: true);
    }
    if (system.isNotEmpty) {
      this.messages = [
        Message(role: Role.system, content: system),
        ...messages,
      ];
    }
    this.images = null;
    this.prompt = null;
    this.request = null;
    this.response = null;
    this.time = null;
  }

  /// Add images to images list of the TextAi object.
  ///
  /// @param file The file path of the image or a list of file paths.
  /// @return The TextAi object with the added images.
  TextAi image(dynamic file) {
    if (file is String) {
      images = [Message.image(file)];
    } else if (file is List<String>) {
      images = file.map((f) => Message.image(f)).toList();
    }
    return this;
  }

  /// Calls the Pollinations API to generate text based on the provided prompt.
  ///
  /// @param prompt The prompt to use for text generation. If null, the last message in the list is used.
  /// @param display Whether to display the response character by character. Default is false.
  /// @param encode Whether to encode the response. Default is false.
  /// @return A Future that resolves to a TextAi object with the generated text.
  Future<TextAi> call({
    String? prompt,
    bool display = false,
    bool encode = false,
  }) async {
    if (prompt == null) {
      if (messages.isNotEmpty) {
        this.prompt = messages.last.content;
      }
    } else {
      this.prompt = prompt;
    }

    //this.messages = messages.map((message) {return message; }).toList();

    this.request = Request(
      model: model,
      prompt: this.prompt ?? "",
      system: system,
      contextual: contextual,
      messages: messages,
      images: images,
      seed: seed,
      private: private,
      reasoningEffort: reasoningEffort,
      jsonMode: jsonMode,
      referrer: referrer,
    );

    this.response = await request!.call(encode: encode);
    this.time = DateTime.now();

    messages.add(Message(role: Role.user, content: this.prompt ?? ""));
    messages.add(Message(role: Role.assistant, content: response));

    // Implement display logic if needed (requires console output in Flutter)
    if (display) {
      //  Use a function to simulate the character-by-character display
      await _displayResponse(response);
    }

    return this;
  }

  /// Simulate character-by-character display with delays
  /// @param text The text to display character by character.
  Future<void> _displayResponse(String text) async {
    for (int i = 0; i < text.length; i++) {
      Duration delay;
      if (i > 0 &&
          ![' ', '\t', '\n'].contains(text[i - 1]) &&
          !text[i - 1].contains(RegExp(r'[a-zA-Z0-9]'))) {
        delay = Duration(
          milliseconds: (100 + Random().nextInt(200)),
        ); // Longer delay
      } else {
        delay = Duration(
          milliseconds: (10 + Random().nextInt(40)),
        ); // Shorter delay
      }
      // Use Future.delayed for async delay
      await Future.delayed(delay);
      // Print the character.  In a Flutter app, you'd update the UI here.
      print(
        text[i],
      ); //  Replace with your UI update logic.  Use a StreamBuilder
    }
    print('\n');
  }

  @override
  String toString() {
    return "TextAi(model: $model, prompt: $prompt, system: $system, contextual: $contextual, messages: ${messages.length}, referrer: $referrer, timestamp: $timestamp)";
  }

  String toJson() {
    return json.encode({
      "class": "TextAi",
      "model": model,
      "prompt": prompt,
      "system": system,
      "contextual": contextual,
      "messages": messages.length,
      "private": private,
      "reasoning_effort": reasoningEffort,
      "referrer": referrer,
      "timestamp": timestamp.toIso8601String(),
    });
  }

  /// Get the list of available models from the Pollinations API.
  /// @return A Future that resolves to a list of models.
  /// Note: This method is static and can be called without creating an instance of TextAi.
  static Future<List<String>> models() async {
    final response = await http
        .get(
          Uri.parse("https://${ApiConfig.getEndpoint(Api.text)}/models"),
          headers: ApiConfig.headers,
        )
        .timeout(Duration(seconds: ApiConfig.timeout));

    if (response.statusCode == 200) {
      List<dynamic> modelsJson = json.decode(response.body);
      return modelsJson.map((model) => model["name"].toString()).toList();
    }
    return [];
  }
}

/// Request class internal to [TextAi].
/// This class is used to create a request for generating text using the Pollinations API.
class Request {
  String model;
  String prompt;
  String system;
  bool contextual;
  List<Message>? messages;
  List<Message>? images;
  dynamic seed;
  bool private;
  String reasoningEffort;
  bool jsonMode;
  String referrer;
  DateTime timestamp;

  /// Constructor for Request class.
  ///
  /// @param model The model to use for text generation and mandatory parameter.
  /// @param prompt The prompt to use for text generation. Mandatory parameter.
  /// @param system The system message to use for text generation. Default is "".
  /// @param contextual Whether to use contextual messages. Default is false.
  /// @param messages The list of messages to use for text generation. Default is an empty list.
  /// @param images The list of images to use for text generation. Default is an empty list.
  /// @param seed The seed to use for text generation. Default is "random".
  /// @param private Whether to make the text generation private. Default is false.
  /// @param reasoningEffort The reasoning effort to use for text generation. Default is "low".
  /// @param jsonMode Whether to use JSON mode for text generation. Default is false.
  /// @param referrer The referrer to use for the API call. Default is "pollinations.py".
  Request({
    required this.model,
    required this.prompt,
    this.system = "",
    this.contextual = false,
    this.messages,
    this.images,
    this.seed = "random",
    this.private = false,
    this.reasoningEffort = "low",
    this.jsonMode = false,
    this.referrer = "pollinations.py",
  }) : timestamp = DateTime.now();
  //  Initialize seed here, in the initializer list.

  /// Compute the seed value based on the provided seed.
  /// @return The computed seed value.
  int computeSeedValue() {
    if (seed == "random") {
      seed = randomSeed();
    }
    return seed;
  }

  int get seedValue => computeSeedValue();

  /// Calls the Pollinations API to generate text based on the provided prompt.
  ///
  /// @param encode Whether to encode the response. Default is false.
  /// @return A Future that resolves to a string with the generated text or an error message.
  Future<String> call({bool encode = false}) async {
    try {
      if (contextual || (images != null && images!.isNotEmpty)) {
        List<Map<String, dynamic>> formattedMessages =
            messages?.map((message) {
              return message.call();
            }).toList() ??
            [];

        if (system.isNotEmpty &&
            (formattedMessages.isEmpty ||
                formattedMessages.first['role'] !=
                    EnumToString.convertToString(Role.system))) {
          formattedMessages.insert(
            0,
            Message(role: Role.system, content: system).call(),
          );
        }

        if (prompt.isNotEmpty) {
          if (images != null && images!.isNotEmpty) {
            // Ensure images are correctly formatted in the messages
            formattedMessages.add(
              Message(role: Role.user, content: prompt, images: images).call(),
            );
          } else {
            formattedMessages.add(
              Message(role: Role.user, content: prompt).call(),
            );
          }
        }

        final response = await http
            .post(
              Uri.parse("https://${ApiConfig.getEndpoint(Api.text)}/"),
              headers: ApiConfig.headers,
              body: json.encode({
                "model": model,
                "messages": formattedMessages,
                "seed": seed.toString(),
                "private": private.toString(),
                "reasoning_effort": reasoningEffort,
                "json": jsonMode.toString(),
                "referrer": referrer,
              }),
            )
            .timeout(Duration(seconds: ApiConfig.timeout));

        if (response.statusCode == 200) {
          if (jsonMode) {
            try {
              return json.decode(response.body);
            } catch (e) {
              return response.body;
            }
          } else {
            return response.body;
          }
        } else {
          return "An error occurred: ${response.statusCode} - ${response.body}";
        }
      } else {
        final params = {
          "model": model,
          "seed": seed.toString(),
          "private": private.toString(),
          "reasoning_effort": reasoningEffort,
          "json": jsonMode.toString(),
          "referrer": referrer,
        };
        if (system.isNotEmpty) {
          params["system"] = system;
        }

        final uri = Uri.parse(
          "https://${ApiConfig.getEndpoint(Api.text)}/$prompt",
        ).replace(queryParameters: params);
        final response = await http
            .get(uri, headers: ApiConfig.headers)
            .timeout(Duration(seconds: ApiConfig.timeout));

        if (response.statusCode == 200) {
          if (jsonMode) {
            try {
              return json.decode(response.body);
            } catch (e) {
              return response.body;
            }
          } else {
            return response.body;
          }
        } else {
          return "An error occurred: ${response.statusCode} - ${response.body}";
        }
      }
    } catch (e) {
      return "An error occurred: $e";
    }
  }

  @override
  String toString() {
    return "Request(model: $model, prompt: $prompt, system: $system, contextual: $contextual, messages: ${messages?.length ?? 0}, referrer: $referrer, timestamp: $timestamp)";
  }

  String toJson() {
    return json.encode({
      "class": "Request",
      "model": model,
      "prompt": prompt,
      "system": system,
      "contextual": contextual,
      "messages": messages?.length ?? 0,
      "private": private,
      "reasoning_effort": reasoningEffort,
      "referrer": referrer,
      "images": images?.length ?? 0,
      "timestamp": timestamp.toIso8601String(),
    });
  }
}

/// Message class to represent a message in the conversation.
class Message {
  Role role;
  String content;
  dynamic images;
  DateTime timestamp;

  /// Constructor for Message class.
  ///
  /// @param role The role of the message (user, assistant, system).
  /// @param content The content of the message.
  /// @param images The images associated with the message. Default is null.
  Message({required this.role, required this.content, this.images})
    : timestamp = DateTime.now() {
    if (images != null) {
      images = images is Map<String, dynamic> ? [images] : List.from(images);
    }
  }

  /// Static method to create a message with an image.
  ///
  /// @param file The file path of the image.
  /// @return A Message object with the image.
  static Message image(String file) {
    return Message(
      role: Role.user,
      content: "",
      images: {
        "type": "image_url",
        "image_url": {
          "url": encodeImageToDataUrl(file),
        }, //  Call an async function
      },
    );
  }

  /// Converts the message to a format suitable for the API call.
  /// @return A Map of String, dynamic(text or image base64encoded) representing the message.
  Map<String, dynamic> call() {
    Map<String, dynamic> message = {"role": EnumToString.convertToString(role)};
    message["content"] = [
      {"type": "text", "text": content},
    ];
    if (images != null) {
      if (images is Map<String, dynamic>) {
        images = [images];
      }
      message["content"].addAll(images);
    }
    return message;
  }

  @override
  String toString() {
    return "Message(role: ${EnumToString.convertToString(role)}, content: $content, images: ${images?.length ?? 0}, timestamp: $timestamp)";
  }

  String toJson() {
    return json.encode({
      "class": "Message",
      "role": EnumToString.convertToString(role),
      "content": content,
      "images": images?.length ?? 0,
      "timestamp": timestamp.toIso8601String(),
    });
  }

  /// Encodes an image file to a Base64 data URL.
  /// @param filePath The path to the image file.
  /// @return A Future that resolves to a Base64 data URL string.
  static Future<String> encodeImageToDataUrl(String filePath) async {
    // Read the image file as bytes
    final bytes = File(filePath).readAsBytesSync();
    // Encode the image to Base64
    final encodedImage = base64Encode(bytes);
    // Extract the file extension
    final fileExtension = filePath.split('.').last.toLowerCase();

    // Define MIME types
    final mimeTypes = {
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'gif': 'image/gif',
      'webp': 'image/webp',
    };

    // Determine the MIME type
    final mimeType = mimeTypes[fileExtension] ?? 'image/png';

    // Return the formatted data URL
    return "data:$mimeType;base64,$encodedImage";
  }
}
