
# pollinations_ai

```
Pollinations.ai: (https://pollinations.ai/)

Work with the best generative models from Pollinations using this SDK for flutter/dart.
```


## Installing

```
   flutter pub add pollinations_ai
```

## Image Generation
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
    final text= await ai.call(display:false, // Simulate typing,
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