//
//  MIDIMessageHandler.swift
//  MIDIWebView
//
//  Created by Peter Bloxidge on 28/10/2019.
//

import WebKit
import WebMIDIKit

class MIDIMessageHandler: NSObject, WKScriptMessageHandler {
    
    let midiAccess = MIDIAccess()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "onready" {
            midiAccess.onStateChange = { port in
                if port.state == .connected, let input = port as? MIDIInput {
                    input.onMIDIMessage = { event in
                        print(event)
                        let js = "callback.receiveMIDIMessage(\(0), \(event.timestamp), \(Array(event.data)))"
                        DispatchQueue.main.async {
                            message.webView?.evaluateJavaScript(js, completionHandler: nil)
                        }
                    }
                }
                
                let m: Message = .statechange(MIDIConnectionEvent(port: port))
                message.webView?.evaluateJavaScript("callback.handleMessage(\(m.json));", completionHandler: nil)

//                switch (port.type, port.state) {
//                case (.input, .connected):
//                    message.webView?.evaluateJavaScript("callback.addSource(\(0), \(port.json));", completionHandler: nil)
//                    break;
//                case (.output, .connected):
//                    message.webView?.evaluateJavaScript("callback.addDestination(\(0), \(port.json));", completionHandler: nil)
//                    break
//                case (.input, .disconnected):
//                    message.webView?.evaluateJavaScript("callback.removeSource(\(0));", completionHandler: nil)
//                    break
//                case (.output, .disconnected):
//                    message.webView?.evaluateJavaScript("callback.removeDestination(\(0));", completionHandler: nil)
//                    break
//                }
            }
            
            print(midiAccess.inputs)
            print(midiAccess.outputs)
            
            message.webView?.evaluateJavaScript("callback.onReady(\(midiAccess.inputs.json), \(midiAccess.outputs.json));", completionHandler: nil)

            return
            
        } else if message.name == "send" {
            let dict = message.body as? [AnyHashable : Any]

            let array = dict?["data"] as? [AnyHashable]
            var data = Data(capacity: array?.count ?? 0)
            for number in array ?? [] {
                guard let number = number as? NSNumber else {
                    continue
                }
                var byte = UInt8(number.uintValue)
                data.append(&byte, count: 1)

            }
            
            let outputIndex = (dict?["outputPortIndex"] as? NSNumber)?.uintValue
            let deltatime = (dict?["deltaTime"] as? NSNumber)?.doubleValue
            
            let (_, output) = midiAccess.outputs[midiAccess.outputs.startIndex]
            output.send(data, offset: deltatime)
            
            return
            
        } else if message.name == "clear" {
            let dict = message.body as? [AnyHashable : Any]
            let outputIndex = (dict?["outputPortIndex"] as? NSNumber)?.uintValue
            
//            midiDriver.clear(withDestinationIndex: ItemCount(outputIndex ?? 0))
        }
    }
    
    private func invokeCallback(_ message: Message) {
        
    }
}
