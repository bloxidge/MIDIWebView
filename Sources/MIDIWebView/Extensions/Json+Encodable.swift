//
//  Json+Encodable.swift
//  MIDIWebView
//
//  Created by Peter Bloxidge on 02/11/2019.
//

import Foundation

extension Encodable {
    var json: String {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(self), let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "null"
        }
        return jsonString
    }
}
