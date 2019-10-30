//
//  MIDIDriver.swift
//  MIDIWebView
//
//  Created by Peter Bloxidge on 28/10/2019.
//

import Foundation

//  Converted to Swift 5.1 by Swiftify v5.1.30744 - https://objectivec2swift.com/
class MIDIDriver: NSObject {
    
    private(set) var isAvailable = true
    
    var onMessageReceived: ((_ index: ItemCount, _ data: Data?, _ timestamp: UInt64) -> Void)?
    var onMessageReceivedFromVirtualEndpoint: ((_ index: ItemCount, _ data: Data?, _ timestamp: UInt64) -> Void)?
    var onDestinationPortAdded: ((_ index: ItemCount) -> Void)?
    var onSourcePortAdded: ((_ index: ItemCount) -> Void)?
    var onDestinationPortRemoved: ((_ index: ItemCount) -> Void)?
    var onSourcePortRemoved: ((_ index: ItemCount) -> Void)?
    
    func sendMessage(_ data: Data?, toDestinationIndex index: ItemCount, deltatime deltatime_ms: Float) -> OSStatus {
        return noErr
    }

    func sendMessage(_ data: Data?, toVirtualSourceIndex vindex: ItemCount, timestamp: UInt64) -> OSStatus {
        return noErr
    }

    func clear(withDestinationIndex index: ItemCount) -> OSStatus {
        return noErr
    }

    func portinfo(fromDestinationEndpointIndex index: ItemCount) -> [AnyHashable : Any]? {
        return [:]
    }

    func portinfo(fromSourceEndpointIndex index: ItemCount) -> [AnyHashable : Any]? {
        return [:]
    }

    func numberOfSources() -> ItemCount {
        return 0
    }

    func numberOfDestinations() -> ItemCount {
        return 0
    }

    func createVirtualSrcEndpoint(withName name: String?) -> ItemCount {
        return 0
    }

    func removeVirtualSrcEndpoint(withIndex vindex: ItemCount) {
    }

    func createVirtualDestEndpoint(withName name: String?) -> ItemCount {
        return 0
    }

    func removeVirtualDestEndpoint(withIndex vindex: ItemCount) {
    }
}

typealias ItemCount = UInt32
