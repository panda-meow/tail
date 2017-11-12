//
//  Project.swift
//  App
//
//  Created by Matthew Paiz on 11/11/17.
//

import Foundation
import Vapor


public struct Project: JSONRepresentable {

    public let id: Int
    public let name: String
    public let title: String
    public let categories: [String]
    public let likes: Int
    
    private let directory: URL
    
    public var thumbnailURL: URL {
        return url(for: "thumbnail")
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
    
    public init(directory: URL, id: Int, name: String, categories: [String], title: String, likes: Int) {
        self.directory = directory
        self.id = id
        self.name = name
        self.title = title
        self.likes = likes
        self.categories = categories
    }
    
    public func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("id", id)
        try json.set("name", name)
        try json.set("alterEgo", title)
        try json.set("title", title)
        try json.set("likes", likes)
        try json.set("categories", categories)
        try json.set("default", true)
        try json.set("thumbnail", hasThumbnail)
        try json.set("header", hasHeader)

        return json
    }
    
    private func url(for resource: String) -> URL {
        let jpg = directory.appendingPathComponent("\(resource).jpg")
        let png = directory.appendingPathComponent("\(resource).png")
        
        if FileManager.default.fileExists(atPath: jpg.path) {
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
        
        let categories = info.array(for: "Categories") ?? [ info.category ]

        return Project(directory: info.directory, id: info.id, name: info.name, categories: categories, title: title, likes: 0)
    }
}


