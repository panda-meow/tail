//
//  Scanner.swift
//  TailPackageDescription
//
//  Created by Matthew Paiz on 2/12/18.
//

import Foundation

public extension URL {
    
    public var modificationDate: Date? {
        let attributes = try! FileManager.default.attributesOfItem(atPath: path)
        return attributes[.modificationDate] as? Date
    }
    
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}


public class Scanner {
    
    private let baseDirectory: URL
    private let filter: (URL)->Bool
    
    public init(baseDirectory: URL, filter: @escaping (URL)->Bool) {
        self.baseDirectory = baseDirectory
        self.filter = filter
    }
    
    private func list(directory: URL) -> [URL] {
        var urls = [URL]()
        do {
            for url in try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
                
                if url.isDirectory {
                    urls.append(contentsOf: list(directory: url))
                } else if filter(url) {
                    urls.append(url)
                }
            }
            
        } catch {
            print("Exception Listing '\(directory.path)': \(error.localizedDescription)")
        }
        return urls
    }
    
    public func list() -> [URL] {
        return list(directory: baseDirectory)
    }
    
    public static func run(scanner: Scanner, callback: ()->Void) {
        
        var latest = Date()
        
        while true {
            let files = scanner.list().filter({
                if let modificationDate = $0.modificationDate, modificationDate.timeIntervalSince(latest) > 0 {
                    return true
                } else {
                    return false
                }
            }).map({ $0.path })
            
            if files.count > 0 {
                latest = Date()
                print("****** DETECTED REFRESH ******")
                callback()
            }
            usleep(100 * 1000)
        }
    }
    
}
