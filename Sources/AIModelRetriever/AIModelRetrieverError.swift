//
//  AIModelRetrieverError.swift
//  AIModelRetriever
//
//  Created by Kevin Hermawan on 10/13/24.
//

import Foundation

/// An enum that represents errors that can occur during AI model retrieval.
public enum AIModelRetrieverError: Error, Sendable {
    /// Indicates that the server response was not in the expected format.
    case badServerResponse
    
    /// Indicates that the server returned an error.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code returned by the server.
    ///   - error: An optional string that contains additional error information provided by the server.
    case serverError(statusCode: Int, error: String?)
}
