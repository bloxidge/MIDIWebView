import MIDIAccess from "./src/MIDIAccess"
import { MIDIPortDeviceState } from "./src/util/Enums"

function _requestMIDIAccess(options) {
    const access = new MIDIAccess(options);

    // Global webkit object available if using iOS WebKit WebView
    // if (window.webkit) {
        // Place global callback methods on webkit object
        window.callback = {
            onReady: access._callback_onReady,
            onNotReady: access._callback_onNotReady,
            receiveMIDIMessage: access._callback_receiveMIDIMessage,
            handleMessage: message => {
                console.log("Received message:");
                if (message.type === "statechange") {
                    const { port } = message.event;
                    switch (port.state) {
                    case MIDIPortDeviceState.connected:
                        switch (port.type) {
                        case "input":
                            access._callback_addSource(0, port);
                            break;
                        case "output":
                            access._callback_addDestination(0, port);
                            break;
                        }
                        break;
                    case MIDIPortDeviceState.disconnected:
                        switch (port.type) {
                        case "input":
                            access._callback_removeSource(0);
                            break;
                        case "output":
                            access._callback_removeDestination(0);
                            break;
                        }
                        break;
                    }
                }
                return true
            }
        };
        console.log("Did add callback methods.");
    // }

    // access.onstatechange = e => {
    //     console.log("StateChanged:");
    //     console.log(JSON.stringify(e.port));
    // };

    return access._promise;
}

// Browser doesn't support native WebMIDI API
if (!window.navigator.requestMIDIAccess) {
    window.navigator.requestMIDIAccess = _requestMIDIAccess;
}