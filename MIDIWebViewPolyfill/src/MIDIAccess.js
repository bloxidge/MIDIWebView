import MIDIEventDispatcher from "./MIDIEventDispatcher"
import MIDIInput from "./MIDIInput"
import MIDIOutput from "./MIDIOutput"
import { createMIDIPortMap, storePromiseCallbacks } from "./util/utils"
import { MIDIPortConnectionState, MIDIPortDeviceState } from "./util/Enums"

class MIDIAccess extends MIDIEventDispatcher {
    constructor(options) {
        super();

        this._promise = new Promise(storePromiseCallbacks.bind(this));
        this._sources = null;
        this._destinations = null;
        this._inputs = null;
        this._outputs = null;
        this._timestampOrigin = 0;
        this._sysexAccessRequested = false;
        this.onstatechange = null;
        this.sysexEnabled = false;
        this.inputs = null;
        this.outputs = null;

        this._callback_onReady = this._callback_onReady.bind(this);
        this._callback_onNotReady = this._callback_onNotReady.bind(this);
        this._callback_receiveMIDIMessage = this._callback_receiveMIDIMessage.bind(this);
        this._callback_addDestination = this._callback_addDestination.bind(this);
        this._callback_addSource = this._callback_addSource.bind(this);
        this._callback_removeDestination = this._callback_removeDestination.bind(this);
        this._callback_removeSource = this._callback_removeSource.bind(this);

        if (typeof options !== "undefined") {
            if (options['sysex'] == true || options['sysex'] == "true") {
                this._sysexAccessRequested = true;
                options['sysex'] = true; // options['sysex'] must be a boolean value
            }
        }

        const param = { options, url: document.location.href };

        if (window.webkit) {
            window.webkit.messageHandlers.onready.postMessage(param);
        }
    }

    _callback_onReady(sources, destinations) {
        this._timestampOrigin = performance.now();

        const inputs = new Array(sources.length);
        for (let i = 0; i < sources.length; i++) {
            inputs[i] = new MIDIInput(sources[i].id, sources[i].name, sources[i].manufacturer, i, this);
        }

        this._inputs = inputs;
        this.inputs = createMIDIPortMap(inputs);

        const outputs = new Array(destinations.length);
        for (let i = 0; i < destinations.length; i++) {
            outputs[i] = new MIDIOutput(destinations[i].id, destinations[i].name, destinations[i].manufacturer, i, this);
        }

        this._outputs = outputs;
        this.outputs = createMIDIPortMap(outputs);

        this.sysexEnabled = this._sysexAccessRequested;

        this._resolve(this);
    }

    _callback_onNotReady() {
        this._reject({ code: 1 });
    }

    _callback_receiveMIDIMessage(index, receivedTime, data) {
        const evt = document.createEvent( "Event" );

        evt.initEvent( "midimessage", false, false );
        evt.receivedTime = receivedTime + this._timestampOrigin;
        evt.data = new Uint8Array(data);

        const input = this._inputs[index];
        if (input != null) {
            input.dispatchEvent(evt);
        }
    }

    _callback_addDestination(index, portInfo) {
        const evt = document.createEvent("Event");
        const output = new MIDIOutput(portInfo.id, portInfo.name, portInfo.manufacturer, index, this);

        this._outputs.splice(index, 0, output);
        this.outputs = createMIDIPortMap(this._outputs);

        output._setState(MIDIPortDeviceState.connected);
        output._setConnection(MIDIPortConnectionState.closed);

        evt.initEvent("statechange", false, false);
        evt.port = output;

        this.dispatchEvent(evt);
    }

    _callback_addSource(index, portInfo) {
        const evt = document.createEvent("Event");
        const input = new MIDIInput(portInfo.id, portInfo.name, portInfo.manufacturer, index, this);

        this._inputs.splice(index, 0, input);
        this.inputs = createMIDIPortMap(this._inputs);

        input._setState(MIDIPortDeviceState.connected);
        input._setConnection(MIDIPortConnectionState.closed);

        evt.initEvent("statechange", false, false);
        evt.port = input;

        this.dispatchEvent(evt);
    }

    _callback_removeDestination(index) {
        const evt = document.createEvent("Event");
        const output = this._outputs[index];

        output._setState(MIDIPortDeviceState.disconnected);
        output._setConnection(MIDIPortConnectionState.pending);

        evt.initEvent("statechange", false, false);
        evt.port = output;

        this._outputs.splice(index, 1);
        this.outputs = createMIDIPortMap(this._outputs);

        this.dispatchEvent(evt);
    }

    _callback_removeSource(index) {
        const evt = document.createEvent("Event");
        const input = this._inputs[index];

        input._setState(MIDIPortDeviceState.disconnected);
        input._setConnection(MIDIPortConnectionState.pending);

        evt.initEvent("statechange", false, false);
        evt.port = input;

        this._inputs.splice(index, 1);
        this.inputs = createMIDIPortMap(this._inputs);

        this.dispatchEvent(evt);
    }
}

export default MIDIAccess
