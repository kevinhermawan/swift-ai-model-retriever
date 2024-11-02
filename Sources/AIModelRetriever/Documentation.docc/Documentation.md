# ``AIModelRetriever``

A utility for retrieving AI model information from various providers.

## Overview

The ``AIModelRetriever`` package provides a simple and unified way to fetch AI model information from different providers such as Anthropic, Google, Ollama, and OpenAI (including OpenAI-compatible APIs).

## Usage

### Initialization

To start using the ``AIModelRetriever`` package, first import it and create an instance of the ``AIModelRetriever`` struct:

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

> The Anthropic models are hardcoded. They do not require an API call to retrieve.

### Retrieving Cohere Models

```swift
let models = modelRetriever.cohere(apiKey: "your-cohere-api-key")

for model in models {
    print("Model ID: \(model.id), Name: \(model.name)")
}
```

### Retrieving Google Models

```swift
let models = modelRetriever.google()

for model in models {
    print("Model ID: \(model.id), Name: \(model.name)")
}
```

> The Google models are hardcoded. They do not require an API call to retrieve.

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
do {
    let models = try await retriever.openAI(apiKey: "your-openai-api-key")

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
let customEndpoint = URL(string: "https://api.your-openai-compatible-service.com/v1/models")!

do {
    let models = try await modelRetriever.openAI(apiKey: "your-api-key", endpoint: customEndpoint)

    for model in models {
        print("Model ID: \(model.id), Name: \(model.name)")
    }
} catch {
    print("Error retrieving models from OpenAI-compatible API: \(error)")
}
```

### Error Handling

``AIModelRetrieverError`` provides structured error handling through the ``AIModelRetrieverError`` enum. This enum contains several cases that represent different types of errors you might encounter:

```swift
do {
    let models = try await modelRetriever.openAI(apiKey: "your-api-key")
} catch let error as AIModelRetrieverError {
    switch error {
    case .serverError(let statusCode, let message):
        // Handle server-side errors (e.g., invalid API key, rate limits)
        print("Server Error [\(statusCode)]: \(message)")
    case .networkError(let error):
        // Handle network-related errors (e.g., no internet connection)
        print("Network Error: \(error.localizedDescription)")
    case .decodingError(let error):
        // Handle errors that occur when the response cannot be decoded
        print("Decoding Error: \(error)")
    case .cancelled:
        // Handle requests that are cancelled
        print("Request was cancelled")
    }
} catch {
    // Handle any other errors
    print("An unexpected error occurred: \(error)")
}
```
