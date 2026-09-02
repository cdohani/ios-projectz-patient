//
//  SplashVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 03/10/2023.
//

import UIKit
import AVFoundation

class SplashVC: ParentViewController {
    
    //MARK: Outlets
    
    //MARK: Variable
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var didNavigate = false
    private var endObserver: NSObjectProtocol?
    
    //MARK: VCLifeCycle
    override var prefersStatusBarHidden: Bool { true }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        additionalSafeAreaInsets = .zero
        view.backgroundColor = .black
        
        // Hide storyboard placeholders
        view.subviews
            .compactMap { $0 as? UIImageView }
            .forEach { $0.isHidden = true }
        
        setupSplashVideo()
        startSplashFlow()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }
    
    //MARK: Functions
    private func setupSplashVideo() {
        guard let url = Bundle.main.url(forResource: "splash", withExtension: "mp4") else {
            print("SplashVC: splash.mp4 not found in bundle")
            return
        }
        
        let player = AVPlayer(url: url)
        player.isMuted = true
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        view.layer.insertSublayer(playerLayer, at: 0)
        
        self.player = player
        self.playerLayer = playerLayer
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func startSplashFlow() {
        guard Reachability.isConnectedToNetwork() else {
            player?.play()
            showAlertView(message: Constants.GenericStrings.internetNotFound)
            return
        }
        
        // Fallback if video is missing or never finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            self?.navigateToLanding()
        }
        
        guard let player else {
            navigateToLanding()
            return
        }
        
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.navigateToLanding()
        }
        
        player.play()
    }
    
    private func navigateToLanding() {
        guard !didNavigate else { return }
        didNavigate = true
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setLandingScreen()
        }
    }
    
    //MARK: ButtonActions

}
