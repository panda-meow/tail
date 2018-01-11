//
//  Project.swift
//  App
//
//  Created by Matthew Paiz on 11/11/17.
//

import Foundation
import Vapor

public struct ProjectSection: JSONRepresentable {
    public let type: String
    public let attributes: [String: Any]

    public static func parse(url: URL, content: URL) throws -> ProjectSection? {
        var properties = [String: String]()
        
        let lines = (try String(contentsOf: url, encoding: .utf8)).components(separatedBy: .newlines)
        for line in lines {
            if let range = line.range(of: ":") {
                let key = String(line[..<range.lowerBound])
                let value = String(line[range.upperBound...]).trim()
                
                if value.starts(with: "#") {
                    properties[key] = try? String(contentsOf: content.appendingPathComponent(value.replacingOccurrences(of: "#", with: "")), encoding: .utf8)
                } else {
                    properties[key] = value
                }
                
                
            }
        }
        
        if let type = properties["type"] {
            return ProjectSection(type: type, attributes: properties)
        } else {
            return nil
        }
    }
    
    public func makeJSON() throws -> JSON {
        var json = JSON()
        
        for (key, value) in attributes {
            try json.set(key, value)
        }

        return json
    }
}

public struct Project: JSONRepresentable {

    public let id: Int
    public let name: String
    public let title: String
    public let categories: [String]
    public let likes: Int
    public let attributes: [String: String]
    
    private let directory: URL
    private let sections: [ProjectSection]
    
    public var thumbnailURL: URL {
        return url(for: "thumbnail")
    }
    
    public var text: [URL] {
        let textDir = directory.appendingPathComponent("text", isDirectory: true)
        if FileManager.default.fileExists(atPath: textDir.path),
            let urls = try? FileManager.default.contentsOfDirectory(at: textDir, includingPropertiesForKeys: nil, options: []).filter({
                return !$0.lastPathComponent.hasPrefix(".")
            }) {
            return urls
        } else {
            return []
        }
    }
    
    public var headerURL: URL {
        return url(for: "header")
    }

    public var hasThumbnail: Bool {
        return FileManager.default.fileExists(atPath: thumbnailURL.path)
    }
    
    public var hasHeader: Bool {
        return FileManager.default.fileExists(atPath: headerURL.path)
    }
    
    public var hasJS: Bool {
        return headerURL.lastPathComponent.hasSuffix(".js")
    }
    
    public init(directory: URL, id: Int, name: String, categories: [String], title: String, likes: Int, attributes: [String: String]) {
        self.directory = directory
        self.id = id
        self.name = name
        self.title = title
        self.likes = likes
        self.categories = categories
        self.attributes = attributes
        
        var i = 0
        
        let content = directory.appendingPathComponent("content", isDirectory: true)
        
        var sections = [ProjectSection]()
        var section = directory.appendingPathComponent("sections", isDirectory: true).appendingPathComponent("\(i)")
        
        while FileManager.default.fileExists(atPath: section.path) {
            if let value = try? ProjectSection.parse(url: section, content: content), let section = value  {
                sections.append(section)
            }
            i += 1
            section = directory.appendingPathComponent("sections", isDirectory: true).appendingPathComponent("\(i)")
        }
        
        self.sections = sections
    }
    
    public func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("id", id)
        try json.set("name", name)
        try json.set("title", title)
        try json.set("categories", categories)
        try json.set("sections", sections)
        
        var attributes = self.attributes
        attributes.removeValue(forKey: "Title")
        attributes.removeValue(forKey: "Categories")

        try json.set("attributes", attributes)

        return json
    }
    
    public func asset(for name: String) -> URL? {
        let assetURL = directory.appendingPathComponent("assets", isDirectory: true)
        
        if let urls = try? FileManager.default.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: nil, options: [])
            .filter({ return !$0.lastPathComponent.hasPrefix(".") }) {
            
            for url in urls {
                if url.lastPathComponent == name {
                    return url
                }
            }
        }
        
        return nil
    }
    
    private func url(for resource: String, supportJS: Bool = false) -> URL {
        let jpg = directory.appendingPathComponent("\(resource).jpg")
        let js = directory.appendingPathComponent("\(resource).js")
        let png = directory.appendingPathComponent("\(resource).png")
        
        if supportJS, FileManager.default.fileExists(atPath: js.path) {
            return js
        } else if FileManager.default.fileExists(atPath: jpg.path) {
            return jpg
        } else {
            return png
        }
    }
}

extension Project {

    public static func parse(info: ProjectInfo) throws -> Project? {
        
        guard let title = info.string(for: "Title") else {
            throw ProjectParseError.invalidProperty(name: "Title")
        }
        
        let categories = info.array(for: "Categories") ?? []
        
        return Project(directory: info.directory, id: info.id, name: info.name, categories: categories, title: title, likes: 0, attributes: info.properties)
    }
}


