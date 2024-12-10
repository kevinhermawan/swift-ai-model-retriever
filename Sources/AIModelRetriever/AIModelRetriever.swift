//
//  AIModelRetriever.swift
//  AIModelRetriever
//
//  Created by Kevin Hermawan on 10/13/24.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A struct that retrieves AI models from various providers.
public struct AIModelRetriever: Sendable {
    /// Initializes a new instance of ``AIModelRetriever``.
    public init() {}
    
    private func performRequest<T: Decodable, E: ProviderError>(_ request: URLRequest, errorType: E.Type) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIModelRetrieverError.serverError(statusCode: 0, message: response.description)
            }
            
            // Check for API errors first, as they might come with 200 status
            if let errorResponse = try? JSONDecoder().decode(E.self, from: data) {
                throw AIModelRetrieverError.serverError(statusCode: httpResponse.statusCode, message: errorResponse.errorMessage)
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw AIModelRetrieverError.serverError(statusCode: httpResponse.statusCode, message: response.description)
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch is CancellationError {
            throw AIModelRetrieverError.cancelled
        } catch let error as URLError where error.code == .cancelled {
            throw AIModelRetrieverError.cancelled
        } catch let error as DecodingError {
            throw AIModelRetrieverError.decodingError(error)
        } catch let error as AIModelRetrieverError {
            throw error
        } catch {
            throw AIModelRetrieverError.networkError(error)
        }
    }
    
    private func createRequest(for endpoint: URL, with headers: [String: String]? = nil) -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

// MARK: - Anthropic
public extension AIModelRetriever {
    /// Retrieves a list of AI models from Anthropic.
    ///
    /// The list of available models is sourced from Anthropic's official documentation:
    /// [Anthropic Models Documentation](https://docs.anthropic.com/en/docs/about-claude/models)
    ///
    /// - Returns: An array of ``AIModel`` that represents Anthropic's available models.
    func anthropic() -> [AIModel] {
        return [
            AIModel(id: "claude-3-5-sonnet-latest", name: "Claude 3.5 Sonnet"),
            AIModel(id: "claude-3-5-haiku-latest", name: "Claude 3.5 Haiku"),
            AIModel(id: "claude-3-opus-latest", name: "Claude 3 Opus (Latest)"),
            AIModel(id: "claude-3-sonnet-20240229", name: "Claude 3 Sonnet"),
            AIModel(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku")
        ]
    }
}

// MARK: - Cohere
public extension AIModelRetriever {
    /// Retrieves a list of AI models from Cohere.
    ///
    /// - Parameters:
    ///   - apiKey: The API key that authenticates with the API.
    ///
    /// - Returns: An array of ``AIModel`` that represents Cohere's available models.
    ///
    /// - Throws: An error that occurs if the request is cancelled, if the network request fails, if the server returns an error, or if the response cannot be decoded.
    func cohere(apiKey: String) async throws -> [AIModel] {
        guard let defaultEndpoint = URL(string: "https://api.cohere.com/v1/models?page_size=1000") else { return [] }
        
        let allHeaders = ["Authorization": "Bearer \(apiKey)"]
        
        let request = createRequest(for: defaultEndpoint, with: allHeaders)
        let response: CohereResponse = try await performRequest(request, errorType: CohereError.self)
        
        return response.models.map { AIModel(id: $0.name, name: $0.name) }
    }
    
    private struct CohereResponse: Decodable {
        let models: [CohereModel]
    }
    
    private struct CohereModel: Decodable {
        let name: String
    }
    
    private struct CohereError: ProviderError {
        let message: String
        
        var errorMessage: String { message }
    }
}

// MARK: - Google
public extension AIModelRetriever {
    /// Retrieves a list of AI models from Google.
    ///
    /// The list of available models is sourced from Google's official documentation:
    /// [Google Models Documentation](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/models)
    ///
    /// - Returns: An array of ``AIModel`` that represents Google's available models.
    func google() -> [AIModel] {
        return [
            AIModel(id: "gemini-1.5-flash", name: "Gemini 1.5 Flash"),
            AIModel(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro"),
            AIModel(id: "gemini-1.0-pro", name: "Gemini 1.0 Pro"),
            AIModel(id: "gemini-1.0-pro-vision", name: "Gemini 1.0 Pro Vision")
        ]
    }
}

// MARK: - Ollama
public extension AIModelRetriever {
    /// Retrieves a list of AI models from Ollama.
    ///
    /// - Parameters:
    ///   - endpoint: The URL endpoint for the Ollama API. If not provided, it defaults to "http://localhost:11434/api/tags".
    ///   - headers: Optional dictionary of HTTP headers to include in the request.
    ///
    /// - Returns: An array of ``AIModel`` that represents Ollama's available models.
    ///
    /// - Throws: An error that occurs if the request is cancelled, if the network request fails, if the server returns an error, or if the response cannot be decoded.
    func ollama(endpoint: URL? = nil, headers: [String: String]? = nil) async throws -> [AIModel] {
        guard let defaultEndpoint = URL(string: "http://localhost:11434/api/tags") else { return [] }
        
        let request = createRequest(for: endpoint ?? defaultEndpoint, with: headers)
        let response: OllamaResponse = try await performRequest(request, errorType: OllamaError.self)
        
        return response.models.map { AIModel(id: $0.model, name: $0.name) }
    }
    
    private struct OllamaResponse: Decodable {
        let models: [OllamaModel]
    }
    
    private struct OllamaModel: Decodable {
        let name: String
        let model: String
    }
    
    private struct OllamaError: ProviderError {
        let error: Error
        
        struct Error: Decodable {
            let message: String
        }
        
        var errorMessage: String { error.message }
    }
}

// MARK: - OpenAI
public extension AIModelRetriever {
    /// Retrieves a list of AI models from OpenAI or OpenAI-compatible APIs.
    ///
    /// - Parameters:
    ///   - apiKey: The API key that authenticates with the API.
    ///   - endpoint: The URL endpoint for the API. If not provided, it defaults to "https://api.openai.com/v1/models".
    ///   - headers: Optional dictionary of additional HTTP headers to include in the request.
    ///
    /// - Returns: An array of ``AIModel`` that represents the available models from the specified API.
    ///
    /// - Throws: An error that occurs if the request is cancelled, if the network request fails, if the server returns an error, or if the response cannot be decoded.
    func openAI(apiKey: String, endpoint: URL? = nil, headers: [String: String]? = nil) async throws -> [AIModel] {
        guard let defaultEndpoint = URL(string: "https://api.openai.com/v1/models") else { return [] }
        
        var allHeaders = headers ?? [:]
        allHeaders["Authorization"] = "Bearer \(apiKey)"
        
        let request = createRequest(for: endpoint ?? defaultEndpoint, with: allHeaders)
        let response: OpenAIResponse = try await performRequest(request, errorType: OpenAIError.self)
        
        return response.data.map { AIModel(id: $0.id, name: $0.id) }
    }
    
    private struct OpenAIResponse: Decodable {
        let data: [OpenAIModel]
    }
    
    private struct OpenAIModel: Decodable {
        let id: String
    }
    
    private struct OpenAIError: ProviderError {
        let error: Error
        
        struct Error: Decodable {
            let message: String
        }
        
        var errorMessage: String { error.message }
    }
}

// MARK: - Supporting Types
private extension AIModelRetriever {
    protocol ProviderError: Decodable {
        var errorMessage: String { get }
    }
}
