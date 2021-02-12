//
//  CameraHostViewController.swift
//  VideoKitLiveStream
//
//  Created by Dennis Stücken on 2/10/21.
//
import Foundation
import VideoKitLive
import UIKit

class LowLatencyBroadcastViewController: BroadcastViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vkLive.streamer?.cameraPosition = .back
        vkLive.streamer?.streamingMode = .cameraVideoAndAudio
        vkLive.streamer?.bitrate = 1500000
        
        startHosting() {
            // The stream id for your viewers. Populate this to the devices that want to join.
            if let stream = self.stream {
                print(stream.id)
                print(stream.getPlaybackUrl()?.absoluteString ?? "Error retrieving stream URL")
            }
        }
    }
}
