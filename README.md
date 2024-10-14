# AIModelRetriever

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkevinhermawan%2Fswift-ai-model-retriever%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kevinhermawan/swift-ai-model-retriever) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkevinhermawan%2Fswift-ai-model-retriever%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kevinhermawan/swift-ai-model-retriever)

A utility for retrieving AI model information from various providers.

## Overview

The `AIModelRetriever` package provides a simple and unified way to fetch AI model information from different providers such as Anthropic, Google, Ollama, and OpenAI (including OpenAI-compatible APIs).

## Installation

You can add `AIModelRetriever` as a dependency to your project using Swift Package Manager by adding it to the dependencies value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/kevinhermawan/swift-ai-model-retriever.git", .upToNextMajor(from: "1.0.0"))
],
targets: [
    .target(
        /// ...
        dependencies: [.product(name: "AIModelRetriever", package: "swift-ai-model-retriever")])
]
```

Alternatively, in Xcode:

1. Open your project in Xcode.
2. Click on `File` -> `Swift Packages` -> `Add Package Dependency...`
3. Enter the repository URL: `https://github.com/kevinhermawan/swift-ai-model-retriever.git`
4. Choose the version you want to add. You probably want to add the latest version.
5. Click `Add Package`.

## Documentation

You can find the documentation here: [https://kevinhermawan.github.io/swift-ai-model-retriever/documentation/aimodelretriever](https://kevinhermawan.github.io/swift-ai-model-retriever/documentation/aimodelretriever)

## Usage

### Initialization

To start using the `AIModelRetriever` package, first import it and create an instance of the `AIModelRetriever` struct:

```swift
import AIModelRetriever

let modelRetriever = AIModelRetriever()
```

### Retrieving Anthropic Models

```swift
let models = modelRetriever.anthropic()

for model in models {
    print("Model ID: \(model.id), Name: \(model.name)")
}
```

> Note: The Anthropic models are hardcoded. They do not require an API call to retrieve.

### Retrieving Google Models

```swift
let models = modelRetriever.google()

for model in models {
    print("Model ID: \(model.id), Name: \(model.name)")
}
```

> Note: The Google models are hardcoded. They do not require an API call to retrieve.

### Retrieving Ollama Models

```swift
do {
    let models = try await retriever.ollama()

    for model in models {
        print("Model ID: \(model.id), Name: \(model.name)")
    }
} catch {
    print("Error retrieving Ollama models: \(error)")
}
```

### Retrieving OpenAI Models

```swift
let apiKey = "your-openai-api-key"

do {
    let models = try await retriever.openAI(apiKey: apiKey)

    for model in models {
        print("Model ID: \(model.id), Name: \(model.name)")
    }
} catch {
    print("Error retrieving OpenAI models: \(error)")
}
```

### Retrieving Models from OpenAI-compatible APIs

The `openAI(apiKey:endpoint:headers:)` method can also be used with OpenAI-compatible APIs by specifying a custom endpoint:

```swift
let apiKey = "your-api-key"
let customEndpoint = URL(string: "https://api.your-openai-compatible-service.com/v1/models")!

do {
    let models = try await modelRetriever.openAI(apiKey: apiKey, endpoint: customEndpoint)

    for model in models {
        print("Model ID: \(model.id), Name: \(model.name)")
    }
} catch {
    print("Error retrieving models from OpenAI-compatible API: \(error)")
}
```

### Error Handling

The package uses `AIModelRetrieverError` to represent specific errors that may occur. You can catch and handle these errors as follows:

```swift
let apiKey = "your-openai-api-key"

do {
    let models = try await modelRetriever.openai(apiKey: apiKey)
    // Process models
} catch let error as AIModelRetrieverError {
    switch error {
    case .badServerResponse:
        print("Received an invalid response from the server")
    case .serverError(let statusCode, let errorMessage):
        print("Server error (status \(statusCode)): \(errorMessage ?? "No error message provided")")
    }
} catch {
    print("An unexpected error occurred: \(error)")
}
```

## Donations

If you find `AIModelRetriever` helpful and would like to support its development, consider making a donation. Your contribution helps maintain the project and develop new features.

- [GitHub Sponsors](https://github.com/sponsors/kevinhermawan)
- [Buy Me a Coffee](https://buymeacoffee.com/kevinhermawan)

Your support is greatly appreciated!

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have any suggestions or improvements.

## License

This repository is available under the [Apache License 2.0](LICENSE).
