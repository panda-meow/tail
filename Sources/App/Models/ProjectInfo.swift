//
//  ProjectInfo.swift
//  Run
//
//  Created by Matthew Paiz on 11/13/17.
//

import Foundation

public struct ProjectInfo {
    
    public let directory: URL
    
    public let id: Int
    public let name: String
    
    private let properties: [String: String]
    
    fileprivate init(directory: URL, id: Int, name: String, properties: [String: String]) {
        self.directory = directory
        self.id = id
        self.name = name
        self.properties = properties
    }
    
    public func int(for key: String) -> Int? {
        if let value = properties[key] {
            return Int(value)
        } else {
            return nil
        }
    }
    
    public func string(for key: String) -> String? {
        return properties[key]
    }
    
    public func array(for key: String) -> [String]? {
        return properties[key]?.commaSeparatedArray()
    }
    
    private static func process(lines: [String]) -> [String: String] {
        var properties = [String: String]()
        
        for line in lines {
            if let range = line.range(of: ":") {
                let key = String(line[..<range.lowerBound])
                let value = String(line[range.upperBound...])
                
                properties[key] = value
            }
        }
        
        return properties
    }
    
    static func parse(id: Int, url: URL) -> ProjectInfo? {
        let name = url.pathComponents[url.pathComponents.count - 1]
        
        
        if let lines = (try? String(contentsOf: url.appendingPathComponent("info")))?.components(separatedBy: .newlines) {
            let properties = process(lines: lines)
            return ProjectInfo(directory: url, id: id, name: name, properties: properties)
        } else {
            print("Failed to parse ProjectInfo!")
            return nil
        }
    }
    
    
}
