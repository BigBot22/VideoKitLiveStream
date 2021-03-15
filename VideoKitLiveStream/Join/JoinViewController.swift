//
//  JoinViewController.swift
//  VideoKitLiveStream
//
//  Created by Dennis Stücken on 1/29/21.
//
import Foundation
import UIKit
import VideoKitLive
import VideoKitCore

class JoinViewController: UIViewController {
    public var vkLive: VKLiveStream = VKLiveStream()
    public var streamId: String?
    private var stream: VKStream?
    
    private let streamView: UIView = {
        UIView(frame: .zero)
    }()
    
    init(streamId id: String) {
        self.streamId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let streamId = streamId else {
            print("Please set id of the stream you want to join.")
            return
        }
        
        DispatchQueue.main.async {
            // Join your stream
            self.vkLive.join(streamId: streamId, inView: self.streamView) { (stream, error) in
                guard let stream = stream else { return }
                self.stream = stream
                
                // You joined the stream!
            }
        }
    }
}
