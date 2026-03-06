import Foundation
import Combine
import AppKit

class MusicPlayerMonitor: ObservableObject {
    @Published var currentTrack: String = ""
    @Published var isPlaying: Bool = false

    private var streamProcess: Process?
    private var outputPipe: Pipe?

    init() {
        startStreaming()
    }

    func togglePlayPause() {
        runAdapterCommand(["send", "2"])
    }

    func nextTrack() {
        runAdapterCommand(["send", "4"])
    }

    func previousTrack() {
        runAdapterCommand(["send", "5"])
    }

    // MARK: - MediaRemote Adapter Integration

    private func adapterPaths() -> (perlScript: String, frameworkPath: String, testClientPath: String)? {
        let bundle = Bundle.main
        guard let helpers = bundle.resourceURL?.deletingLastPathComponent().appendingPathComponent("Helpers") else {
            return nil
        }
        let script = helpers.appendingPathComponent("mediaremote-adapter.pl").path
        let framework = helpers.appendingPathComponent("MediaRemoteAdapter.framework").path
        let testClient = helpers.appendingPathComponent("MediaRemoteAdapterTestClient").path

        guard FileManager.default.fileExists(atPath: script),
              FileManager.default.fileExists(atPath: framework) else {
            return nil
        }
        return (script, framework, testClient)
    }

    private func startStreaming() {
        guard let paths = adapterPaths() else {
            NSLog("SpotBar: MediaRemote adapter not found in bundle")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
        process.arguments = [paths.perlScript, paths.frameworkPath, paths.testClientPath, "stream", "--no-diff", "--debounce=100"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        process.terminationHandler = { [weak self] proc in
            guard let self = self else { return }
            NSLog("SpotBar: adapter stream exited with code \(proc.terminationStatus), restarting...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.startStreaming()
            }
        }

        outputPipe = pipe
        streamProcess = process

        // Read output on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.readStream(pipe: pipe)
        }

        do {
            try process.run()
        } catch {
            NSLog("SpotBar: Failed to start adapter: \(error)")
        }
    }

    private func readStream(pipe: Pipe) {
        let handle = pipe.fileHandleForReading
        var buffer = Data()

        while true {
            let data = handle.availableData
            if data.isEmpty { break } // EOF

            buffer.append(data)

            // Process complete lines
            while let newlineRange = buffer.range(of: Data([0x0A])) {
                let lineData = buffer.subdata(in: buffer.startIndex..<newlineRange.lowerBound)
                buffer.removeSubrange(buffer.startIndex...newlineRange.lowerBound)
                processLine(lineData)
            }
        }
    }

    private func processLine(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let payload = json["payload"] as? [String: Any] else {
            return
        }

        let title = payload["title"] as? String
        let artist = payload["artist"] as? String
        let playing = payload["playing"] as? Bool ?? false

        let track: String
        if let title = title, !title.isEmpty {
            if let artist = artist, !artist.isEmpty {
                track = "\(artist) - \(title)"
            } else {
                track = title
            }
        } else {
            track = ""
        }

        DispatchQueue.main.async {
            self.currentTrack = track
            self.isPlaying = playing
        }
    }

    private func runAdapterCommand(_ args: [String]) {
        guard let paths = adapterPaths() else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
            process.arguments = [paths.perlScript, paths.frameworkPath, paths.testClientPath] + args
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            try? process.run()
            process.waitUntilExit()
        }
    }

    deinit {
        streamProcess?.terminate()
    }
}
