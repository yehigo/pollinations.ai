
# Pollinations.ai Flutter/Dart SDK

```
Pollinations.ai

Effortlessly integrate the best generative AI models from Pollinations into your Flutter/Dart applications with this powerful SDK.
```

## Features
* Image Generation: Create stunning visuals using state-of-the-art AI models.
* Text Generation: Generate coherent and creative text with advanced language models.
* Model Exploration: Easily explore and list available AI models for both image and text generation

## Installing
Install the package by running the following command:
```bash
flutter pub add pollinations_ai
```
## Usage Examples
### Image Generation
```dart
import 'package:pollinations_ai/pollinations_ai.dart';

final ai = ImageAi(model: "flux");
ImageAi image= await ai.call("A beautiful sunset");
print(image.prompt, image.response)
image.save("pollinations-image.png");
```


## Text Generation
```dart
import 'package:pollinations_ai/pollinations_ai.dart';

final ai = TextAi(model: "gpt-3.5-turbo");
final TextAi text= await ai.call(display:false, // Simulate typing,
        encode=True  // Use proper encoding
        prompt: "A beautiful sunset");
print(text.response);

```

## List all models 
```dart 
import 'package:pollinations_ai/pollinations_ai.dart';

Future<List<String>> image_generation_ai_models = ImageAi.models();
Future<List<String>> futurelist text_ai_models = TextAi.models();
```

### Contributing
🤝 We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch 
```bash
git checkout -b feature/amazing-feature
```
3. Commit your changes 
```bash
git commit -m 'Add amazing feature' 
```
4. Push to the branch 
```bash
git push origin feature/amazing-feature
```
5. Open a Pull Request


## Acknowledgments

A big thank you to [pollinations](https://pollinations.ai/) and all contributors for their efforts in making this possible.
 
