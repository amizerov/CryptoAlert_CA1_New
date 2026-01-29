//
//  Error.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 15.11.2021.
//

import Foundation

let logger = Logger()

public class Logger: WebApiProtocol {
    
    public var Version = ""
    
    var CheckServerCompleted: ((_ srv: ServerData, _ res: String) -> ())?
    var api = WebApi()
    init() {
        api.delegate = self
        let ver = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let bld = Bundle.main.infoDictionary!["CFBundleVersion"]!
        Version = "\(ver)(\(bld))"
    }
    public func CheckServer(compl: @escaping (_ srv: ServerData, _ res: String) -> ()) {
        api.CheckServer()
        CheckServerCompleted = compl
    }
    public func Log(_ err: String) {
        api.WriteLog(err.replacingOccurrences(of: " ", with: "_"))
    }
    
    public func ApiRequestDone(_ jsonData: Data) {
        var srv = ServerData()
        var res = ""
        let str = String(data: jsonData, encoding: .utf8)!
        if str.count < 1 {
            res = "No data from server"
        }
        else {
            do {
                srv = try JSONDecoder().decode(ServerData.self, from: jsonData) as ServerData
            }
            catch {
                res = "Error parsing data from server"
            }
        }
        CheckServerCompleted!(srv, res)
    }
}

public struct ServerData: Codable {
    var DbVersion = ""
    var CountUsers = 0
    var CountDevices = 0
}
