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
    static var mockStatusCode: Int?
    static var responseDelay: TimeInterval?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = URLProtocolMock.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        if let delay = URLProtocolMock.responseDelay {
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                self.sendResponse()
            }
        } else {
            sendResponse()
        }
    }

    private func sendResponse() {
        if let data = URLProtocolMock.mockData, let url = request.url {
            let response = HTTPURLResponse(url: url, statusCode: URLProtocolMock.mockStatusCode ?? 200, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        client?.urlProtocol(self, didFailWithError: NSError(domain: "No mock data", code: -1, userInfo: nil))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
