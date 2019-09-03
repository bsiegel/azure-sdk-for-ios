//
//  HttpRequest.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/23/19.
//

import Foundation

@objc public class HttpRequest: NSObject {
    
    @objc var httpMethod: HttpMethod
    @objc var url: String
    @objc var headers: HttpHeaders
    @objc var files: [String]?
    @objc var data: Data?
    
    @objc var query: [URLQueryItem]? {
        let comps = URLComponents(string: self.url)?.queryItems
        return comps
    }
    @objc var body: Data? {
        get {
            return self.data
        }
        set(newValue) {
            self.data = newValue
        }
    }
    
    @objc convenience public init(httpMethod: HttpMethod, url: String) {
        self.init(httpMethod: httpMethod, url: url, headers: HttpHeaders())
    }
    
    @objc public init(httpMethod: HttpMethod, url: String, headers: HttpHeaders? = nil, files: [String]? = nil, data: Data? = nil) {
        self.httpMethod = httpMethod
        self.url = url
        self.headers = headers ?? HttpHeaders()
        self.files = files
        self.data = data
    }
    
    private func format(data: AnyObject) -> String {
        // TODO: implement
        return ""
    }
    
    @objc public func format(queryParams: [String:String]) {
//        if let query = URLComponents(string: self.url)?.query {
//            self.url = self.url.components(separatedBy: "?").first!
//            for component in query.components(separatedBy: "&") {
//                let (key, value) = component.components(separatedBy: "=") {
//                    // TODO: Update params
//                }
//            }
//        }
    }
    
    @objc public func set(streamedDataBody data: Data) {
        // TODO: Check type here with guard statement
        self.data = data
        self.files = nil
    }
    
    @objc public func set(xmlBody data: Data) {
        // TODO: Implement
        // convert XML to UTF-8 string
        // replace "encoding='utf8'" with "encoding='utf-8'"
        // update Content-Length header with data content length
        self.files = nil
    }
    
    @objc public func set(jsonBody data: Data) {
        // TODO: Implement
        // dump json body to string
        // update Content-Length header
        self.files = nil
    }
    
    @objc public func set(formDataBody data: Data) {
        if let contentType = self.headers[HttpHeader.contentType]?.lowercased() {
            if contentType == "application/x-www-form-urlencoded" {
                // TODO: do something to data
                self.files = nil
                return
            }
        }
        // files = format(data: d) for each in data items...
        self.data = nil
    }
    
    @objc public func set(bytesBody data: Data) {
        self.headers[HttpHeader.contentLength] = data.count.description
        self.data = data
        self.files = nil
    }
}