import Foundation
import App

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"



_ = ProjectManager.shared

let config = try Config()
try config.setup()

let drop = try Droplet(config)
try drop.setup()

drop.post("projects", "reload") { request in
    ProjectManager.shared.update()
    return Response(status: .ok)
}

drop.get("projects", Int.parameter) { request in
    let id = try request.parameters.next(Int.self)
    
    if let project = ProjectManager.shared.project(for: id) {
        let response = try! Response(status: .ok, json: project.makeJSON())
        response.headers["Access-Control-Allow-Origin"] = "*"
        
        return response
    } else {
        return Response(status: .notFound)
    }
}

drop.get("projects") { request in
    let response = try! Response(status: .ok, json: JSON(ProjectManager.shared.projects.map({ try! $0.makeJSON() })))
    response.headers["Access-Control-Allow-Origin"] = "*"
    return response
}

drop.get("projects", Int.parameter, "assets", String.parameter) { request in
    let id = try request.parameters.next(Int.self)
    let asset = try request.parameters.next(String.self)

    if let project = ProjectManager.shared.project(for: id),
        let url = project.asset(for: asset), let response = try? Response(filePath: url.path) {
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response
    } else {
        return Response(status: .notFound)
    }
}

drop.get("projects", Int.parameter, "thumbnail") { request in
    let id = try request.parameters.next(Int.self)
    
    if let project = ProjectManager.shared.project(for: id), let response = try? Response(filePath: project.thumbnailURL.path) {
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response
    } else {
        return Response(status: .notFound)
    }
}

drop.get("projects", Int.parameter, "header") { request in
    let id = try request.parameters.next(Int.self)
    
    if let project = ProjectManager.shared.project(for: id), let response = try? Response(filePath: project.headerURL.path) {
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response
    } else {
        return Response(status: .notFound)
    }
}

drop.get("projects", Int.parameter, "preview") { request in
    let id = try request.parameters.next(Int.self)
    
    if let project = ProjectManager.shared.project(for: id),
        let response = try? Response(filePath: project.previewURL.path) {
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response
    } else {
        return Response(status: .notFound)
    }
}



#if os(Linux)
#else
if let path = ProcessInfo.processInfo.environment["PANDA_HOME"] {
    let scanner = Scanner(baseDirectory: URL(fileURLWithPath: "\(path)/content", isDirectory: true), filter: { _ in return true })
    DispatchQueue.global(qos: .background).async {
        Scanner.run(scanner: scanner) {
            ProjectManager.shared.update()
        }
    }
}
#endif

try drop.run()
