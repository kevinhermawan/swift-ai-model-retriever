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
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIModelRetrieverError.badServerResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw AIModelRetrieverError.serverError(statusCode: httpResponse.statusCode, error: String(data: data, encoding: .utf8))
        }
        
        return try JSONDecoder().decode(T.self, from: data)
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
    /// - Returns: An array of ``AIModel`` that represents Anthropic's available models.
    func anthropic() -> [AIModel] {
        return [
            AIModel(id: "claude-3-5-sonnet-latest", name: "Claude 3.5 Sonnet (Latest)"),
            AIModel(id: "claude-3-5-sonnet-20241022", name: "Claude 3.5 Sonnet (20241022)"),
            AIModel(id: "claude-3-opus-latest", name: "Claude 3 Opus (Latest)"),
            AIModel(id: "claude-3-opus-20240229", name: "Claude 3 Opus (20240229)"),
            AIModel(id: "claude-3-sonnet-20240229", name: "Claude 3 Sonnet (20240229)"),
            AIModel(id: "claude-3-haiku-20240307", name: "Claude 3 Haiku (20240307)")
        ]
    }
}

// MARK: - Cohere
public extension AIModelRetriever {
    /// Retrieves a list of AI models from Cohere.
    ///
    /// - Parameters:
    ///   - apiKey: The API key for authenticating with the API.
    ///
    /// - Returns: An array of ``AIModel`` that represents Cohere's available models.
    ///
    /// - Throws: An error if the network request fails or if the response cannot be decoded.
    func cohere(apiKey: String) async throws -> [AIModel] {
        guard let defaultEndpoint = URL(string: "https://api.cohere.com/v1/models?page_size=1000") else { return [] }
        
        let allHeaders = ["Authorization": "Bearer \(apiKey)"]
        
        let request = createRequest(for: defaultEndpoint, with: allHeaders)
        let response: CohereResponse = try await performRequest(request)
        
        return response.models.map { AIModel(id: $0.name, name: $0.name) }
    }
    
    private struct CohereResponse: Decodable {
        let models: [CohereModel]
    }
    
    private struct CohereModel: Decodable {
        let name: String
    }
}

// MARK: - Google
public extension AIModelRetriever {
    /// Retrieves a list of AI models from Google.
    ///
    /// This method returns a predefined list of Google's AI models.
    ///
    /// - Returns: An array of ``AIModel`` that represents Google's available models.
    func google() -> [AIModel] {
        return [
            AIModel(id: "gemini-1.5-flash", name: "Gemini 1.5 Flash"),
            AIModel(id: "gemini-1.5-flash-8b", name: "Gemini 1.5 Flash-8B"),
            AIModel(id: "gemini-1.5-pro", name: "Gemini 1.5 Pro"),
            AIModel(id: "gemini-1.0-pro", name: "Gemini 1.0 Pro"),
            AIModel(id: "text-embedding-004", name: "Text Embedding"),
            AIModel(id: "aqa", name: "AQA")
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
    /// - Throws: An error if the network request fails or if the response cannot be decoded.
    func ollama(endpoint: URL? = nil, headers: [String: String]? = nil) async throws -> [AIModel] {
        guard let defaultEndpoint = URL(string: "http://localhost:11434/api/tags") else { return [] }
        
        let request = createRequest(for: endpoint ?? defaultEndpoint, with: headers)
        let response: OllamaResponse = try await performRequest(request)
        
        return response.models.map { AIModel(id: $0.model, name: $0.name) }
    }
    
    private struct OllamaResponse: Decodable {
        let models: [OllamaModel]
    }
    
    private struct OllamaModel: Decodable {
        let name: String
        let model: String
    }
}

// MARK: - OpenAI
public extension AIModelRetriever {
    /// Retrieves a list of AI models from OpenAI or OpenAI-compatible APIs.
    ///
    /// - Parameters:
    ///   - apiKey: The API key for authenticating with the API.
    ///   - endpoint: The URL endpoint for the API. If not provided, it defaults to "https://api.openai.com/v1/models".
    ///   - headers: Optional dictionary of additional HTTP headers to include in the request.
    ///
    /// - Returns: An array of ``AIModel`` that represents the available models from the specified API.
    ///
    /// - Throws: An error if the network request fails or if the response cannot be decoded.
    func openAI(apiKey: String, endpoint: URL? = nil, headers: [String: String]? = nil) async throws -> [AIModel] {
        guard let defaultEndpoint = URL(string: "https://api.openai.com/v1/models") else { return [] }
        
        var allHeaders = headers ?? [:]
        allHeaders["Authorization"] = "Bearer \(apiKey)"
        
        let request = createRequest(for: endpoint ?? defaultEndpoint, with: allHeaders)
        let response: OpenAIResponse = try await performRequest(request)
        
        return response.data.map { AIModel(id: $0.id, name: $0.id) }
    }
    
    private struct OpenAIResponse: Decodable {
        let data: [OpenAIModel]
    }
    
    private struct OpenAIModel: Decodable {
        let id: String
    }
}
