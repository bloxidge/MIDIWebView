/**
 * Create read-only iterable map from array of ports
 * @param ports [MIDIPort]
 */
export function createMIDIPortMap(ports) {
    const portMap = new Map(ports.map(port => [port.id, port]));
    // Delete mutating functions to simulate ReadonlyMap
    delete portMap.clear;
    delete portMap.delete;
    delete portMap.set;
    return portMap
}

/**
 * Helper function to store resolve/reject callbacks on instance of the object. (Must bind to object on usage)
 * @param resolve
 * @param reject
 */
export function storePromiseCallbacks(resolve, reject) {
    this._resolve = resolve;
    this._reject = reject;
}