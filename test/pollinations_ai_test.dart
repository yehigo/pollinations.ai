import 'package:test/test.dart';
import 'package:pollinations_ai/pollinations_ai.dart';

void main() {
  test('Sample test textAi string object', () {
    TextAi textAi = TextAi();
    String actualTextAiToStr = textAi.toString();
    String expectedTextAiToStr =
        "TextAi(model: openai, prompt: null, system: , contextual: false, messages: 0, referrer: pollinations.py, timestamp: ${textAi.timestamp})";
    expect(actualTextAiToStr, expectedTextAiToStr);
  });

  /// Test for ImageAi class
  test('Sample test ImageAi string object', () {
    ImageAi imageAi = ImageAi();
    String actualImageAiToStr = imageAi.toString();
    String expectedImageAiToStr =
        "ImageAi(model: flux, seed: random, width: 1024, height: 1024, enhance: false, nologo: false, private: false, safe: false, referrer: pollinations.py, timestamp: ${imageAi.timestamp})";
    expect(actualImageAiToStr, expectedImageAiToStr);
  });
}
