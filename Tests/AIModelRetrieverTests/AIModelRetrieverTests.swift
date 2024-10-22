//
//  AIModelRetrieverTests.swift
//  AIModelRetriever
//
//  Created by Kevin Hermawan on 10/14/24.
//

import XCTest
@testable import AIModelRetriever

final class AIModelRetrieverTests: XCTestCase {
    var retriever: AIModelRetriever!
    
    override func setUp() {
        super.setUp()
        
        retriever = AIModelRetriever()
        URLProtocol.registerClass(URLProtocolMock.self)
    }
    
    override func tearDown() {
        retriever = nil
        URLProtocol.unregisterClass(URLProtocolMock.self)
        URLProtocolMock.mockData = nil
        URLProtocolMock.mockError = nil
        URLProtocolMock.mockStatusCode = 200
        
        super.tearDown()
    }
    
    func testAnthropic() {
        let models = retriever.anthropic()
        
        XCTAssertFalse(models.isEmpty)
        XCTAssertTrue(models.contains { $0.id == "claude-3-5-sonnet-latest" })
        XCTAssertTrue(models.contains { $0.name == "Claude 3.5 Sonnet (Latest)" })
    }
    
    func testGoogle() {
        let models = retriever.google()
        
        XCTAssertFalse(models.isEmpty)
        XCTAssertTrue(models.contains { $0.id == "gemini-1.5-pro" })
        XCTAssertTrue(models.contains { $0.name == "Gemini 1.5 Pro" })
    }
    
    func testOllama() async throws {
        let mockResponseString = """
        {
            "models": [
                {"name": "Test Model 1", "model": "test-model-1"},
                {"name": "Test Model 2", "model": "test-model-2"}
            ]
        }
        """
        
        URLProtocolMock.mockData = mockResponseString.data(using: .utf8)
        
        let models = try await retriever.ollama()
        
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[0].id, "test-model-1")
        XCTAssertEqual(models[1].name, "Test Model 2")
    }
    
    func testOpenAI() async throws {
        let mockResponseString = """
        {
            "data": [
                {"id": "gpt-4"},
                {"id": "gpt-3.5-turbo"}
            ]
        }
        """
        
        URLProtocolMock.mockData = mockResponseString.data(using: .utf8)
        
        let models = try await retriever.openAI(apiKey: "test-key")
        
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[0].id, "gpt-4")
        XCTAssertEqual(models[1].id, "gpt-3.5-turbo")
    }
    
    func testOpenAICompatible() async throws {
        let mockResponseString = """
        {
            "data": [
                {"id": "custom-model-1"},
                {"id": "custom-model-2"}
            ]
        }
        """
        
        URLProtocolMock.mockData = mockResponseString.data(using: .utf8)
        
        let customEndpoint = URL(string: "https://api.custom-openai-service.com/v1/models")!
        let models = try await retriever.openAI(apiKey: "test-key", endpoint: customEndpoint)
        
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[0].id, "custom-model-1")
        XCTAssertEqual(models[1].id, "custom-model-2")
    }
    
    func testServerError() async {
        let errorResponse = """
        {
            "error": "Invalid API key"
        }
        """
        
        URLProtocolMock.mockData = errorResponse.data(using: .utf8)
        URLProtocolMock.mockStatusCode = 401
        
        do {
            _ = try await retriever.openAI(apiKey: "invalid-key")
            XCTFail("Expected an error to be thrown")
        } catch let error as AIModelRetrieverError {
            switch error {
            case .serverError(let statusCode, let errorMessage):
                XCTAssertEqual(statusCode, 401)
                
                if let errorData = errorMessage?.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: errorData, options: []) as? [String: Any],
                   let errorString = jsonObject["error"] as? String {
                    XCTAssertEqual(errorString, "Invalid API key")
                }
            default:
                XCTFail("Unexpected error type")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
