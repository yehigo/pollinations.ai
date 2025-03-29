import 'dart:math';

/// Enum to represent the type of API being used.
enum Api { text, image }

/// Enum to represent the role of the user in the conversation with the AI.
enum Role { user, assistant, system }

/// Function to generate a random seed for generation.
/// The seed is a 32-bit unsigned integer.
int randomSeed() {
  return Random().nextInt(4294967296);
}
