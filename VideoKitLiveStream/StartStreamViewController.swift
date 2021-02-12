//
//  ViewController.swift
//  VideoKitTableFeed
//
//  Created by Dennis Stücken on 11/11/20.
//
import UIKit
import VideoKitLive


class StartStreamViewController: UIViewController {
    
    @IBOutlet var hostButton: Button!
    @IBOutlet var presetSelector: UISegmentedControl!
    
    var segments = [BroadcastingPreset.low, BroadcastingPreset.medium, BroadcastingPreset.high]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func hostButtonTapped() {
        let streamVC = LowLatencyBroadcastViewController(streamType: .lowLatency)
        streamVC.usePreset(preset: segments[presetSelector.selectedSegmentIndex])
        streamVC.modalPresentationStyle = .automatic
        present(streamVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
