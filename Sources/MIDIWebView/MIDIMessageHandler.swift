//
//  MIDIMessageHandler.swift
//  MIDIWebView
//
//  Created by Peter Bloxidge on 28/10/2019.
//

import WebKit

class MIDIMessageHandler: NSObject, WKScriptMessageHandler {
    
    var midiDriver = MIDIDriver()
    var confirmSysExAvailability: ((_ url: String?) -> Bool)?
    
    private var sysexEnabled = false

    func invokeJSCallback_onNotReady(_ webView: WKWebView?) {
        webView?.evaluateJavaScript("_callback_onNotReady();", completionHandler: nil)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        guard let midiDriver = midiDriver else {
//            return
//        }
        
        if message.name == "onready" {
            var timestampOrigin: UInt64 = 0

            let dict = message.body as? [AnyHashable : Any]

            let MIDIoptions = dict?["options"] as? [AnyHashable : Any]
            let url = dict?["url"] as? String

            sysexEnabled = false
            let sysexOption = MIDIoptions?["sysex"]
            if (sysexOption is NSNumber) && (sysexOption as? NSNumber)?.boolValue ?? false == true {
                if let confirmSysExAvailability = confirmSysExAvailability {
                    if confirmSysExAvailability(url) == false {
                        invokeJSCallback_onNotReady(message.webView)
                        return
                    } else {
                        sysexEnabled = true
                    }
                } else {
                    invokeJSCallback_onNotReady(message.webView)
                    return
                }
            }

            if !midiDriver.isAvailable {
                invokeJSCallback_onNotReady(message.webView)
                return
            }

            // Setup the callback for receiving MIDI message.
            midiDriver.onMessageReceived = { index, receivedData, timestamp in
                guard let receivedData = receivedData else { return }
                let bytes = [UInt8](receivedData)
                var array = [AnyHashable](repeating: 0, count: receivedData.count)
                var sysexIncluded = false
                for byte in bytes {
                    array.append(NSNumber(value: byte))

                    if byte == 0xf0 {
                        sysexIncluded = true
                    }
                }

                if self.sysexEnabled == false && sysexIncluded == true {
                    // should throw InvalidAccessError exception here
                    return
                }

                var dataJSON: Data? = nil
                do {
                    dataJSON = try JSONSerialization.data(withJSONObject: array, options: [])
                } catch {
                }
                var dataJSONStr: String? = nil
                if let dataJSON = dataJSON {
                    dataJSONStr = String(data: dataJSON, encoding: .utf8)
                }

                let deltaTime_ms = Double(timestamp - timestampOrigin)
                message.webView?.evaluateJavaScript(String(format: "_callback_receiveMIDIMessage(%lu, %f, %@);", index, deltaTime_ms, dataJSONStr ?? ""), completionHandler: nil)
            }

            midiDriver.onDestinationPortAdded = { index in
                let info = self.midiDriver.portinfo(fromDestinationEndpointIndex: index)
                var JSON: Data? = nil
                do {
                    JSON = try JSONSerialization.data(withJSONObject: info, options: [])
                } catch {
                }
                var JSONStr: String? = nil
                if let JSON = JSON {
                    JSONStr = String(data: JSON, encoding: .utf8)
                }

                message.webView?.evaluateJavaScript(String(format: "_callback_addDestination(%lu, %@);", index, JSONStr ?? ""), completionHandler: nil)
            }

            midiDriver.onSourcePortAdded = { index in
                let info = self.midiDriver.portinfo(fromSourceEndpointIndex: index)
                var JSON: Data? = nil
                do {
                    JSON = try JSONSerialization.data(withJSONObject: info, options: [])
                } catch {
                }
                var JSONStr: String? = nil
                if let JSON = JSON {
                    JSONStr = String(data: JSON, encoding: .utf8)
                }

                message.webView?.evaluateJavaScript(String(format: "_callback_addSource(%lu, %@);", index, JSONStr ?? ""), completionHandler: nil)
            }

            midiDriver.onDestinationPortRemoved = { index in
                message.webView?.evaluateJavaScript(String(format: "_callback_removeDestination(%lu);", index), completionHandler: nil)
            }

            midiDriver.onSourcePortRemoved = { index in
                message.webView?.evaluateJavaScript(String(format: "_callback_removeSource(%lu);", index), completionHandler: nil)
            }
            
            // Send all MIDI ports information when the setup request is received.
            let srcCount = midiDriver.numberOfSources()
            let destCount = midiDriver.numberOfDestinations()

            var srcs = [Any](repeating: 0, count: Int(srcCount))
            var dests = [Any](repeating: 0, count: Int(destCount))


            for srcIndex in 0..<Int(srcCount) {
                let info = midiDriver.portinfo(fromSourceEndpointIndex: ItemCount(srcIndex))
                if info == nil {
                    invokeJSCallback_onNotReady(message.webView)
                    return
                }
                srcs.append(info)
            }

            for destIndex in 0..<Int(destCount) {
                let info = midiDriver.portinfo(fromDestinationEndpointIndex: ItemCount(destIndex))
                if info == nil {
                    invokeJSCallback_onNotReady(message.webView)
                    return
                }
                dests.append(info)
            }

            var srcsJSON: Data? = nil
            do {
                srcsJSON = try JSONSerialization.data(withJSONObject: srcs, options: [])
            } catch {
                invokeJSCallback_onNotReady(message.webView)
                return
            }
            var srcsJSONStr: String? = nil
            if let srcsJSON = srcsJSON {
                srcsJSONStr = String(data: srcsJSON, encoding: .utf8)
            }

            var destsJSON: Data? = nil
            do {
                destsJSON = try JSONSerialization.data(withJSONObject: dests, options: [])
            } catch {
                invokeJSCallback_onNotReady(message.webView)
                return
            }
            var destsJSONStr: String? = nil
            if let destsJSON = destsJSON {
                destsJSONStr = String(data: destsJSON, encoding: .utf8)
            }

            timestampOrigin = mach_absolute_time()

            message.webView?.evaluateJavaScript("_callback_onReady(\(srcsJSONStr ?? ""), \(destsJSONStr ?? ""));", completionHandler: nil)

            return
            
        } else if message.name == "send" {
            let dict = message.body as? [AnyHashable : Any]

            let array = dict?["data"] as? [AnyHashable]
            var data = Data(capacity: array?.count ?? 0)
            var sysexIncluded = false
            for number in array ?? [] {
                guard let number = number as? NSNumber else {
                    continue
                }
                var byte = UInt8(number.uintValue)
                data.append(&byte, count: 1)

                if byte == 0xf0 {
                    sysexIncluded = true
                }
            }
            if sysexEnabled == false && sysexIncluded == true {
                return
            }
            
            let outputIndex = (dict?["outputPortIndex"] as? NSNumber)?.uintValue
            let deltatime = (dict?["deltaTime"] as? NSNumber)?.floatValue
            midiDriver.sendMessage(data, toDestinationIndex: ItemCount(outputIndex ?? 0), deltatime: deltatime ?? 0)
            
            return
            
        } else if message.name == "clear" {
            let dict = message.body as? [AnyHashable : Any]
            let outputIndex = (dict?["outputPortIndex"] as? NSNumber)?.uintValue
            
            midiDriver.clear(withDestinationIndex: ItemCount(outputIndex ?? 0))
        }
    }
}

