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

public class ProjectManager {
    
    public static let `shared`: ProjectManager = {
        if let path = ProcessInfo.processInfo.environment["PANDA_HOME"] {
            return ProjectManager(directory: URL(fileURLWithPath: path))
        } else {
            fatalError("PANDA_HOME not set!!!")
        }
    }()
    
    public private(set) var projects: [Project]!
    
    private let directory: URL

    private init(directory: URL) {
        self.directory = directory
        update()
    }
    
    public func update() {
        projects = self.scan()
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
    
    private func scan() -> [Project] {
        do {
            var projects = [Project]()
            
            let urls = try FileManager.default.contentsOfDirectory(at: directory.appendingPathComponent("content", isDirectory: true), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
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
}
