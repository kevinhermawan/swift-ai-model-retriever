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
        
        URLProtocol.registerClass(URLProtocolMock.self)
        retriever = AIModelRetriever()
    }
    
    override func tearDown() {
        retriever = nil
        URLProtocol.unregisterClass(URLProtocolMock.self)
        URLProtocolMock.mockData = nil
        URLProtocolMock.mockError = nil
        
        super.tearDown()
    }
    
    func testAnthropic() {
        let models = retriever.anthropic()
        
        XCTAssertFalse(models.isEmpty)
        XCTAssertTrue(models.contains { $0.id == "claude-3-5-sonnet-latest" })
        XCTAssertTrue(models.contains { $0.name == "Claude 3.5 Sonnet (Latest)" })
    }
    
    func testCohere() async throws {
        let mockResponseString = """
        {
            "models": [
                {"name": "test-model-1"},
                {"name": "test-model-2"}
            ]
        }
        """
        
        URLProtocolMock.mockData = mockResponseString.data(using: .utf8)
        
        let models = try await retriever.cohere(apiKey: "test-key")
        
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[0].id, "test-model-1")
        XCTAssertEqual(models[1].name, "test-model-2")
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
}

// MARK: - Error Handling
extension AIModelRetrieverTests {
    func testServerError() async throws {
        let mockErrorResponse = """
        {
            "error": {
                "message": "Invalid API key provided"
            }
        }
        """
        
        URLProtocolMock.mockData = mockErrorResponse.data(using: .utf8)
        
        do {
            let _ = try await retriever.openAI(apiKey: "test-key")

            XCTFail("Expected serverError to be thrown")
        } catch let error as AIModelRetrieverError {
            switch error {
            case .serverError(let message):
                XCTAssertEqual(message, "Invalid API key provided")
            default:
                XCTFail("Expected serverError but got \(error)")
            }
        }
    }
    
    func testNetworkError() async throws {
        URLProtocolMock.mockError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet,
            userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."]
        )
        
        do {
            let _ = try await retriever.openAI(apiKey: "test-key")

            XCTFail("Expected networkError to be thrown")
        } catch let error as AIModelRetrieverError {
            switch error {
            case .networkError(let underlyingError):
                XCTAssertEqual((underlyingError as NSError).code, NSURLErrorNotConnectedToInternet)
            default:
                XCTFail("Expected networkError but got \(error)")
            }
        }
    }
}
