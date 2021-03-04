//
//  LiveHostViewController.swift
//  VideoKitLiveStream
//
//  Created by Dennis Stücken on 2/10/21.
//
import Foundation
import UIKit
import VideoKitLive
import VideoKitCore
import ReplayKit

// Streaming Presets
enum BroadcastingPreset {
    case ultraHigh
    case high
    case medium
    case low
}

// Broadcasting profile
public class BroadcastingProfile {
    public var width : Int = 0
    public var height : Int = 0
    public var fps : Int = 0
    public var bitrate : Int = 0
    
    init(width: Int, height: Int, fps: Int, bitrate: Int) {
        self.width = width
        self.height = height
        self.fps = fps
        self.bitrate = bitrate
    }
}

class BroadcastViewController: UIViewController {
    internal var vkLive: VKLiveStream = VKLiveStream()
    internal var stream: VKStream?
    internal var streamer: VKStreamerProtocol? {
        didSet {
            streamer?.delegate = self
        }
    }
    internal var streamType: VKStreamProfile
    
    private var profile: BroadcastingProfile = BroadcastingProfile(width: 1280, height: 720, fps: 30, bitrate: 3000000)
    
    // Converts a Preset to a Profile
    public func usePreset(preset: BroadcastingPreset) {
        switch preset {
        case .ultraHigh:
            profile = BroadcastingProfile(width: 1920, height: 1080, fps: 30, bitrate: 5000000)
        case .high:
            profile = BroadcastingProfile(width: 1280, height: 720, fps: 30, bitrate: 3000000)
        case .medium:
            profile = BroadcastingProfile(width: 960, height: 540, fps: 30, bitrate: 2000000)
        case .low:
            profile = BroadcastingProfile(width: 640, height: 360, fps: 30, bitrate: 1000000)
        }
    }
    
    private let streamView: UIView = {
        UIView(frame: .zero)
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.backgroundColor = .red
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.text = "READY"
        return label
    }()
    
    private let fpsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "FPS: 0"
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont(name: "Avenir-Medium", size: 16)!
        return label
    }()
    
    private let streamButton: Button = {
        let button = Button(frame: .zero)
        button.setTitle(" Start Streaming ", for: .normal)
        return button
    }()
    
    init(streamType: VKStreamProfile) {
        self.streamType = streamType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.streamType = .lowLatency
        super.init(coder: coder)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopHosting()
    }
}

// Stream delegate
extension BroadcastViewController: VKStreamerDelegate {
    func streamDidReceiveStatistics(fps: Int, bytesOut: Int, bytesIn: Int) {
        fpsLabel.text = "FPS: \(fps), BytesOut: \(bytesOut)"
    }
    
    func streamOrientationChanged(to orientation: AVCaptureVideoOrientation) {
        print("Orientation changed.")
    }
    
    /// Called if max reconnection attempts where hit and the stream failed to connect
    func streamDidFailToConnect(_ stream: VideoKitCore.VKStream, connectionAttempts: Int) {
        print("Failed to connect to stream.")
    }
    
    func streamStatusChanged(_ stream: VKStream, state: VKLiveStreamState) {
        if state == .connected {
            changeStatus("connected")
        }
        
        else if state == .streamingRequest {
            changeStatus("connecting")
        }
        
        else if state == .streaming {
            changeStatus("streaming")
        }
        
        else if state == .stopped {
            changeStatus("stopped")
        }
        
        else if state == .failed {
            changeStatus("failed")
        }
    }
    
    func streamError(_ stream: VKStream, message: String, statusCode: String) {
        changeStatus("error")
    }
}

// Start/Stop hosting
extension BroadcastViewController {
    internal func stopHosting() {
        guard let stream = stream else {
            print("There is no stream to close.")
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        vkLive.stopHosting(stream: stream) { (success) in
            if success {
                print("Stream Ended")
            } else {
                print("Error Ending Stream")
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func startHosting(completion: @escaping () -> Void) {
        vkLive.streamer?.width = profile.width
        vkLive.streamer?.height = profile.height
        vkLive.streamer?.fps = profile.fps
        vkLive.streamer?.bitrate = profile.bitrate
        
        // Host your stream
        vkLive.host(type: self.streamType, inView: streamView) { (streamer, stream, error) in
            guard let stream = stream else {
                let alert = UIAlertController(title: "Error", message: "There was an error starting your stream. (\(error?.localizedDescription ?? "")", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                self.present(alert, animated: true)
                return
            }
            
            print("Stream started: \(stream.id)")
            self.stream = stream
            self.streamer = streamer
            completion()
            
            // Putting stream id into clipboard
            UIPasteboard.general.string = stream.id
        }
    }
}

// UI
extension BroadcastViewController {
    @objc internal func streamButtonTapped() {
        guard let streamer = streamer else { return }
        print(streamer.state)
        if streamer.state == .streaming {
            streamer.stop()
            streamButton.setTitle("Start Streaming", for: .normal)
            fpsLabel.text = ""
        } else {
            changeStatus("starting")
            streamer.start()
            streamButton.setTitle("Stop Streaming", for: .normal)
        }
    }
    
    fileprivate func changeStatus(_ string: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = string.uppercased()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Preparing live stream
        view.addSubview(streamView)
        streamView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            streamView.topAnchor.constraint(equalTo: view.topAnchor),
            streamView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            streamView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            streamView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        view.addSubview(streamButton)
        streamButton.translatesAutoresizingMaskIntoConstraints = false
        streamButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        streamButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        streamButton.widthAnchor.constraint(equalToConstant: 175).isActive = true
        
        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            statusLabel.widthAnchor.constraint(equalToConstant: 175),
            statusLabel.heightAnchor.constraint(equalToConstant: 35),
        ])
        
        view.addSubview(fpsLabel)
        fpsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fpsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            fpsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            fpsLabel.widthAnchor.constraint(equalToConstant: 250),
            fpsLabel.heightAnchor.constraint(equalToConstant: 35),
        ])
        
        streamButton.addTarget(self, action: #selector(streamButtonTapped), for: .touchUpInside)
        view.bringSubviewToFront(streamButton)
    }
}
