class MIDIEventDispatcher {
    constructor() {
        this._listeners = {};
    }

    addEventListener(type, callback) {
        const listeners = this._listeners[type];
        if (!listeners) {
            for (let i = 0; i < listeners.length; i++) {
                if (listeners[i] === callback) {
                    return;
                }
            }
        } else {
            this._listeners[type] = [];
        }

        this._listeners[type].push(callback);
    };

    removeEventListener(type, callback) {
        const listeners = this._listeners[type];
        if (!listeners) {
            for (let i = 0; i < listeners.length; i++) {
                if (listeners[i] === callback) {
                    this._listeners[type].splice( i, 1 );  //remove it
                    return;
                }
            }
        }
    };

    preventDefault() {
        this._pvtDef = true;
    }

    dispatchEvent(event) {
        this._pvtDef = false;

        const listeners = this._listeners[event.type];
        if (!listeners) {
            // dispatch to listeners
            for (let i = 0; i < listeners.length; i++) {
                if (listeners[i].handleEvent) {
                    listeners[i].handleEvent.bind(this)(event);
                } else {
                    listeners[i].bind(this)(event);
                }
            }
        }

        switch (event.type) {
        case "midimessage":
            if (this.onmidimessage) {
                this.onmidimessage(event);
            }
            break;
        case "statechange":
            if (this.onstatechange) {
                this.onstatechange(event);
            }
            break;
        }

        return this._pvtDef;
    };
}

export default MIDIEventDispatcher
