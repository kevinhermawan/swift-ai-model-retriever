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

> Note: The Anthropic models are hardcoded. They do not require an API call to retrieve.

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

``AIModelRetrieverError`` provides structured error handling through the ``AIModelRetrieverError`` enum. This enum contains three cases that represent different types of errors you might encounter:

```swift
do {
    let models = try await modelRetriever.openai(apiKey: "your-api-key")
} catch let error as LLMChatOpenAIError {
    switch error {
    case .serverError(let message):
        // Handle server-side errors (e.g., invalid API key, rate limits)
        print("Server Error: \(message)")
    case .networkError(let error):
        // Handle network-related errors (e.g., no internet connection)
        print("Network Error: \(error.localizedDescription)")
    case .badServerResponse:
        // Handle invalid server responses
        print("Invalid response received from server")
    case .cancelled:
        // Handle cancelled requests
        print("Request cancelled")
    }
}
```
