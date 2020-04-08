import MIDIEventDispatcher from "./MIDIEventDispatcher"
import { MIDIPortConnectionState, MIDIPortDeviceState } from "./util/Enums"
import { storePromiseCallbacks } from "./util/utils"

class MIDIPort extends MIDIEventDispatcher {
    constructor(id, name, manufacturer, index, midiaccess) {
        super();

        this._index = index;
        this.id = id;
        this.name = name;
        this.manufacturer = manufacturer;
        this._midiaccess = midiaccess;

        this.type = "";
        this.version = "";
        this.state = MIDIPortDeviceState.connected;
        this.connection = MIDIPortConnectionState.closed;
        this._promise = new Promise(storePromiseCallbacks.bind(this));

        window.addEventListener('unload', function() {
            this._midiaccess = null;
        });
    }

    _setConnection(newState) {
        if (this.connection !== newState) {
            this.connection = newState;

            var evt = document.createEvent("Event");
            evt.initEvent("statechange", false, false);
            evt.port = this;
            this.dispatchEvent(evt);

            if (this._midiaccess) {
                this._midiaccess.dispatchEvent(evt);
            }
        }
    };

    _setState(newState) {
        if (this.state !== newState) {
            this.state = newState;

            var evt = document.createEvent("Event");
            evt.initEvent("statechange", false, false);
            evt.port = this;
            this.dispatchEvent(evt);

            if (this._midiaccess) {
                this._midiaccess.dispatchEvent(evt);
            }
        }
    };

    open() {
        this._setConnection(MIDIPortConnectionState.open);

        setTimeout(function() {
            this._resolve(this);
        }.bind(this), 0);

        return this._promise;
    };

    close() {
        this._setConnection(MIDIPortConnectionState.closed);

        setTimeout(function() {
            this._resolve(this);
        }.bind(this), 0);

        return this._promise;
    };
}

export default MIDIPort
