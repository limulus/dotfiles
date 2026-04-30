// Compile with: swiftc ~/.local/bin/audio-cycle.swift -o ~/.local/bin/audio-cycle

import CoreAudio
import Foundation

let targets = ["MX3s", "RØDE PodMic USB"]
let system = AudioObjectID(kAudioObjectSystemObject)

func addr(_ sel: AudioObjectPropertySelector,
          _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal)
-> AudioObjectPropertyAddress {
    AudioObjectPropertyAddress(mSelector: sel, mScope: scope,
                               mElement: kAudioObjectPropertyElementMain)
}

func allDevices() -> [AudioDeviceID] {
    var a = addr(kAudioHardwarePropertyDevices)
    var size: UInt32 = 0
    AudioObjectGetPropertyDataSize(system, &a, 0, nil, &size)
    var ids = [AudioDeviceID](repeating: 0,
                              count: Int(size) / MemoryLayout<AudioDeviceID>.size)
    AudioObjectGetPropertyData(system, &a, 0, nil, &size, &ids)
    return ids
}

func name(_ id: AudioDeviceID) -> String {
    var a = addr(kAudioDevicePropertyDeviceNameCFString)
    var n: Unmanaged<CFString>?
    var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
    AudioObjectGetPropertyData(id, &a, 0, nil, &size, &n)
    return n?.takeRetainedValue() as String? ?? ""
}

func hasOutput(_ id: AudioDeviceID) -> Bool {
    var a = addr(kAudioDevicePropertyStreams, kAudioObjectPropertyScopeOutput)
    var size: UInt32 = 0
    AudioObjectGetPropertyDataSize(id, &a, 0, nil, &size)
    return size > 0
}

func currentOutput() -> AudioDeviceID {
    var a = addr(kAudioHardwarePropertyDefaultOutputDevice)
    var id: AudioDeviceID = 0
    var size = UInt32(MemoryLayout<AudioDeviceID>.size)
    AudioObjectGetPropertyData(system, &a, 0, nil, &size, &id)
    return id
}

func setDefaultOutput(_ id: AudioDeviceID) -> OSStatus {
    var a = addr(kAudioHardwarePropertyDefaultOutputDevice)
    var d = id
    return AudioObjectSetPropertyData(system, &a, 0, nil,
                                      UInt32(MemoryLayout<AudioDeviceID>.size), &d)
}

func warn(_ s: String) {
    FileHandle.standardError.write(Data("\(s)\n".utf8))
}

// Available targets, preserving the cycle order from `targets`.
let outputs = allDevices().filter(hasOutput)
let available: [(name: String, id: AudioDeviceID)] = targets.compactMap { t in
    outputs.first(where: { name($0) == t }).map { (t, $0) }
}

let currentName = name(currentOutput())

guard !available.isEmpty else {
    print(currentName)
    warn("none of the target devices are connected")
    exit(1)
}

// Next in cycle, or first if current isn't part of the cycle.
let next: (name: String, id: AudioDeviceID) = {
    if let i = available.firstIndex(where: { $0.name == currentName }) {
        return available[(i + 1) % available.count]
    }
    return available[0]
}()

let status = setDefaultOutput(next.id)
guard status == 0 else {
    print(currentName)
    warn("failed to set output (OSStatus \(status))")
    exit(2)
}
print(next.name)
