//
//  WatchStreamViewController.swift
//  VideoKitLiveStream
//
//  Created by Dennis Stücken on 2/10/21.
//
import UIKit
import VideoKitLive

class WatchStreamViewController: UIViewController {
    
    @IBOutlet weak var idTextField: TextField!
    @IBOutlet var joinButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func joinButtonTapped() {
        guard let streamId = idTextField.text else { return }
        
        let streamVC = JoinViewController(streamId: streamId)
        streamVC.modalPresentationStyle = .automatic
        present(streamVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
