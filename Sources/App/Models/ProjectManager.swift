//
//  ProjectManager.swift
//  App
//
//  Created by Matthew Paiz on 11/12/17.
//

import Foundation


public enum ProjectParseError: Error {
    case invalidProperty(name: String)
}

public struct ProjectInfo {
    
    public let directory: URL
    
    public let id: Int
    public let name: String
    public let category: String
    
    private let properties: [String: String]
    
    fileprivate init(directory: URL, id: Int, name: String, category: String, properties: [String: String]) {
        self.directory = directory
        self.id = id
        self.name = name
        self.category = category
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
    
    fileprivate static func parse(id: Int, url: URL) -> ProjectInfo? {
        let name = url.pathComponents[url.pathComponents.count - 1]
        let category = url.pathComponents[url.pathComponents.count - 2]
        
        
        if let lines = (try? String(contentsOf: url.appendingPathComponent("info")))?.components(separatedBy: .newlines) {
            let properties = process(lines: lines)
            return ProjectInfo(directory: url, id: id, name: name, category: category, properties: properties)
        } else {
            return nil
        }
    }
    

}

public class ProjectManager {
    
    public static let `shared` = ProjectManager()
    
    private var categories: [String: [Project]]!
    
    public var projects: [Project] {
        get {
            return categories.values.array.reduce([], +)
        }
    }

    private init() {
        categories = self.scan()
    }
    
    public func project(for id: Int) -> Project? {
        for project in projects {
            if id == project.id {
                return project
            }
        }
        
        return nil
    }

    private func scan(category: URL) -> [Project] {
        do {
            var projects = [Project]()
            
            let urls = try FileManager.default.contentsOfDirectory(at: category, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for (index, url) in urls.enumerated() {
                print("**** Processing \(url.lastPathComponent) ****")

                if let info = ProjectInfo.parse(id: index, url: url), let project = try Project.parse(info: info) {
                    projects.append(project)
                }
                
            }
            
            return projects
        } catch {
            fatalError("Exception processing projects: \(error.localizedDescription)")
        }
        
    }
    
    private func scan() -> [String: [Project]] {
        do {
            
            var categories = [String: [Project]]()
            
            let urls = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/Users/matt/Portfolio/Projects"), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for url in urls {
                categories[url.lastPathComponent] = scan(category: url)
            }
            
            return categories

        } catch {
            fatalError("Exception processing projects: \(error.localizedDescription)")
        }
    }

}
