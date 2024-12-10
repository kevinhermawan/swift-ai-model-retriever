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
        
        super.tearDown()
    }
    
    /// Tests that the `anthropic` method returns a non-empty list of models
    /// and contains specific expected models.
    func testAnthropic() {
        let models = retriever.anthropic()
        
        XCTAssertFalse(models.isEmpty)
        XCTAssertTrue(models.contains { $0.id == "claude-3-5-sonnet-latest" })
        XCTAssertTrue(models.contains { $0.name == "Claude 3.5 Sonnet" })
    }
    
    /// Tests that the `cohere` method successfully retrieves models
    /// and maps them correctly from the API response.
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
    
    /// Tests that the `google` method returns a non-empty list of models
    /// and contains specific expected models.
    func testGoogle() {
        let models = retriever.google()
        
        XCTAssertFalse(models.isEmpty)
        XCTAssertTrue(models.contains { $0.id == "gemini-1.5-pro" })
        XCTAssertTrue(models.contains { $0.name == "Gemini 1.5 Pro" })
    }
    
    /// Tests that the `ollama` method successfully retrieves models
    /// and maps them correctly from the API response.
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
    
    /// Tests that the `openAI` method successfully retrieves models from OpenAI
    /// and maps them correctly from the API response.
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
    
    /// Tests that the `openAI` method successfully retrieves models from an OpenAI-compatible API
    /// and maps them correctly from the API response.
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
    /// Tests that a server error with status code 401 is correctly handled
    /// and throws `serverError` with the appropriate message.
    func testServerError() async throws {
        let mockErrorResponse = """
        {
            "error": {
                "message": "Invalid API key provided"
            }
        }
        """
        
        URLProtocolMock.mockData = mockErrorResponse.data(using: .utf8)
        URLProtocolMock.mockStatusCode = 401
        
        do {
            let _ = try await retriever.openAI(apiKey: "test-key")
            
            XCTFail("Expected serverError to be thrown")
        } catch let error as AIModelRetrieverError {
            switch error {
            case .serverError(let statusCode, let message):
                XCTAssertEqual(statusCode, 401)
                XCTAssertEqual(message, "Invalid API key provided")
            default:
                XCTFail("Expected serverError but got \(error)")
            }
        }
    }
    
    /// Tests that a server error with status code 200 but an error message in the response body
    /// is correctly handled and throws `serverError` with the appropriate message.
    func testServerErrorWithStatusCode200() async throws {
        let mockErrorResponse = """
        {
            "error": {
                "message": "An error occurred"
            }
        }
        """
        
        URLProtocolMock.mockData = mockErrorResponse.data(using: .utf8)
        URLProtocolMock.mockStatusCode = 200
        
        do {
            let _ = try await retriever.openAI(apiKey: "test-key")
            XCTFail("Expected serverError to be thrown")
        } catch let error as AIModelRetrieverError {
            switch error {
            case .serverError(let statusCode, let message):
                XCTAssertEqual(statusCode, 200)
                XCTAssertEqual(message, "An error occurred")
            default:
                XCTFail("Expected serverError but got \(error)")
            }
        }
    }
    
    /// Tests that a network error (e.g., no internet connection) is correctly handled
    /// and throws `networkError` with the appropriate underlying error.
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
    
    /// Tests that a decoding error (invalid JSON response) is correctly handled
    /// and throws `decodingError` with the appropriate underlying error.
    func testDecodingError() async throws {
        let invalidJSON = "Invalid JSON"
        
        URLProtocolMock.mockData = invalidJSON.data(using: .utf8)
        URLProtocolMock.mockStatusCode = 200
        
        do {
            let _ = try await retriever.openAI(apiKey: "test-key")
            
            XCTFail("Expected decodingError to be thrown")
        } catch let error as AIModelRetrieverError {
            switch error {
            case .decodingError(let underlyingError):
                XCTAssertTrue(underlyingError is DecodingError)
            default:
                XCTFail("Expected decodingError but got \(error)")
            }
        }
    }
    
    /// Tests that a cancellation error (e.g., URL loading cancelled) is correctly handled
    /// and throws `cancelled`.
    func testURLErrorCancelled() async throws {
        URLProtocolMock.mockError = URLError(.cancelled)
        
        do {
            let _ = try await retriever.openAI(apiKey: "test-key")
            
            XCTFail("Expected cancelled error to be thrown")
        } catch let error as AIModelRetrieverError {
            switch error {
            case .cancelled:
                break
            default:
                XCTFail("Expected cancelled error but got \(error)")
            }
        }
    }
    
    /// Tests that a task cancellation is correctly handled
    /// and throws `cancelled` when the task is cancelled before completion.
    func testCancellationError() async throws {
        let mockResponseString = """
        {
            "data": [
                {"id": "gpt-4"},
                {"id": "gpt-3.5-turbo"}
            ]
        }
        """
        
        URLProtocolMock.mockData = mockResponseString.data(using: .utf8)
        URLProtocolMock.mockStatusCode = 200
        URLProtocolMock.responseDelay = 1.0
        
        let expectation = expectation(description: "Wait for task cancellation")
        
        let task = Task {
            do {
                let _ = try await retriever.openAI(apiKey: "test-key")
                XCTFail("Expected task to be cancelled")
            } catch let error as AIModelRetrieverError {
                switch error {
                case .cancelled:
                    expectation.fulfill()
                default:
                    XCTFail("Expected cancelled error but got \(error)")
                    expectation.fulfill()
                }
            } catch {
                XCTFail("Unexpected error: \(error)")
                expectation.fulfill()
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            task.cancel()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        URLProtocolMock.responseDelay = nil
    }
}
