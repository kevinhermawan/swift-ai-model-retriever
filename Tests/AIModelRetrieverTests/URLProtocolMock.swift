//
//  URLProtocolMock.swift
//  AIModelRetriever
//
//  Created by Kevin Hermawan on 10/14/24.
//

import Foundation

final class URLProtocolMock: URLProtocol {
    static var mockData: Data?
    static var mockError: Error?
    static var mockStatusCode: Int = 200
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = URLProtocolMock.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let data = URLProtocolMock.mockData {
                client?.urlProtocol(self, didLoad: data)
            }
            
            let response = HTTPURLResponse(url: request.url!, statusCode: URLProtocolMock.mockStatusCode, httpVersion: nil, headerFields: nil)!
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
