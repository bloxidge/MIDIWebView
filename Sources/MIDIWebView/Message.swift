//
//  CallbackMessage.swift
//  MIDIWebView
//
//  Created by Peter Bloxidge on 02/11/2019.
//

import WebMIDIKit

internal enum Message: Encodable {
    enum CodingKeys: CodingKey {
        case type, event
    }
    
    case statechange(MIDIConnectionEvent)
    case midimessage(MIDIMessageEvent)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .statechange(let event):
            try container.encode("statechange", forKey: .type)
            try container.encode(event, forKey: .event)
        case .midimessage(let event):
            try container.encode("midimessage", forKey: .type)
            try container.encode(event, forKey: .event)
        }
    }
}

//internal struct Message<T: Encodable>: Encodable {
//
//    typealias Payload = T
//
//    let type: MessageType
//    let payload: Payload
//}
