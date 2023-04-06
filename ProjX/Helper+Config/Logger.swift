//
//  Logger.swift
//  ProjX
//
//  Created by Sathya on 04/04/23.
//

import Foundation

class Logger {

    private init() {}

    static func log(_ message: Any..., line: Int = #line, filename: String = (#file as NSString).lastPathComponent) {
        print("[\(line):\(filename)]", message)
    }

    func logDocumentsDirectory() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print(documentsPath)
    }

}
