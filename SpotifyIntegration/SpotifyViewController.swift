//
//  SpotifyViewController.swift
//  HeartBit
//
//  Created by Balázs Morvay on 2021. 02. 11..
//  Copyright © 2021. BitRaptors. All rights reserved.
//

import UIKit
import Interface_DependencyInjection
import RxSwift
import RxCocoa
import Interface_Routing
import StoreKit




class SpotifyViewController: UIViewController {
    
    // MARK: - Properties
    
    private let screenHeight = UIScreen.main.bounds.height
    
    private let spotifyHelper: SpotifyHelperProtocol = Resolver.resolve()
    
    private let currentPageRepo: CurrentPageRepositoryProtocol = Resolver.resolve()
    
    private let disposeBag = DisposeBag()
    
    private var isPlaying: Bool = false
    
    // MARK: - Constants and personalization
    
    let defaultAlbumCoverImage: UIImage = UIImage(named: "easteregg")!
    
    let playingImage: UIImage = UIImage(named: "play")!
    let stoppedImage: UIImage = UIImage(named: "pause")!
    
    let skipBackImage: UIImage = UIImage(named: "back")!
    let skipForwardImage: UIImage = UIImage(named: "next")!
    
    /// The tint color for the back, forward, play/pause buttons
    let buttonTintColor: UIColor = UIColor(named: "text_secondary")!
    
    let openSpotifyButtonTintColor: UIColor = UIColor(named: "green")!
    
    
    // MARK: - Outlets
    @IBOutlet weak var faderView: UIView!
    
    @IBOutlet weak var bottomSheetView: UIView!
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var previousTrackButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    
    
    @IBOutlet weak var openSpotifyButton: UIButton!
    
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateIn()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        animateOut()
        
        spotifyHelper.setAlbumImageSize(to: CGSize(width: albumImageView.bounds.width * 2,
                                                   height: albumImageView.bounds.height * 2))
        
        self.previousTrackButton.tintColor = self.buttonTintColor
        self.playPauseButton.tintColor = self.buttonTintColor
        self.nextTrackButton.tintColor = self.buttonTintColor
        
        setSubscriptions()
        setActions()
    }
    
    
    // MARK: - Other funcs
    
    private func animateIn() {
        UIView.animate(withDuration: 0.2, animations: {
            self.faderView.alpha = 0.4
        }) { (_) in
            self.animateBottomSheetIn()
        }
    }
    
    private func animateOut() {
        UIView.animate(withDuration: 0.2, animations: {
            self.faderView.alpha = 0.0
        }, completion: { _ in
            self.animateBottomSheetOut()
        })
    }
    
    
    private func animateBottomSheetIn() {
        UIView.animate(withDuration: 0.1,
                       delay: 0.1,
                       options: [.curveEaseOut]) {
            self.bottomSheetView.transform = .identity
            self.bottomSheetView.alpha = 1.0
        }
    }
    
    private func animateBottomSheetOut() {
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.curveEaseIn]) {
            self.bottomSheetView.transform = CGAffineTransform(translationX: 0,
                                                               y: self.screenHeight)
        }
    }

    
    /// Updates the UI from the SpotifyHelper's output observables
    private func setSubscriptions() {
        
        // Any errors are bound to the current page
        spotifyHelper.errorOutput.map { (spotifyError) -> Page in
            .sheet(UIAlertController(title: spotifyError.errorTitle,
                                     message: spotifyError.errorMessage,
                                     preferredStyle: .alert))
        }.bind(to: currentPageRepo.currentPage)
        .disposed(by: disposeBag)
        
        
        // Bind the album covers to the image view. If no album cover exists, put a default image
        spotifyHelper.imagePublisher.map { (image) -> UIImage in
            return image ?? self.defaultAlbumCoverImage
        }.bind(to: self.albumImageView.rx.image)
        .disposed(by: disposeBag)
        
        
        spotifyHelper.spotifyStateOutput.isPausedObservable.map { (optionaBool) -> Bool in
            optionaBool ?? true
        }.subscribe(onNext: { (paused) in
            if paused {
                self.playPauseButton.setImage(self.stoppedImage, for: .normal)
            } else {
                self.playPauseButton.setImage(self.playingImage, for: .normal)
            }
        }).disposed(by: disposeBag)
        
        
        // We need to save if the music is currently playing to determine on the next play/pause button tap what to do
        spotifyHelper.spotifyStateOutput.isPausedObservable.subscribe(onNext: { (playing) in
            self.isPlaying = playing ?? false
        }).disposed(by: disposeBag)

        
        spotifyHelper.spotifyStateOutput.trackObservable.subscribe(onNext: { (track) in
            self.titleLabel.text = track?.name
            self.artistLabel.text = track?.artist.name
        }).disposed(by: disposeBag)
        
        
        // Disable certain controls if the users account is restricted
        spotifyHelper.spotifyStateOutput.playbackRestrictionsObservable.subscribe(onNext: { (restrictions) in
            
            if restrictions?.canSkipNext != .some(true) {
                self.nextTrackButton.isEnabled = false
            } else {
                self.nextTrackButton.isEnabled = true
            }
            
            if restrictions?.canSkipPrevious != .some(true) {
                self.previousTrackButton.isEnabled = false
            } else {
                self.previousTrackButton.isEnabled = true
            }
            
        }).disposed(by: disposeBag)
        
    }
    
    /// Sets the actions for the tappable buttons
    private func setActions() {
        
        self.playPauseButton.rx.tap.subscribe(onNext: { (_) in
            self.isPlaying ? self.spotifyHelper.pausePlay() : self.spotifyHelper.resumePlay()
        }).disposed(by: disposeBag)
        
        self.previousTrackButton.rx.tap.subscribe(onNext: { (_) in
            self.spotifyHelper.skipToPreviousTrack()
        }).disposed(by: disposeBag)
        
        self.nextTrackButton.rx.tap.subscribe(onNext: { _ in
            self.spotifyHelper.skipToNextTrack()
        }).disposed(by: disposeBag)
        
        self.openSpotifyButton.rx.tap.subscribe(onNext: { (_) in
            // TODO
        }).disposed(by: disposeBag)


    }
    
    
    

}


// MARK: SKStoreProductViewControllerDelegate
extension SpotifyViewController: SKStoreProductViewControllerDelegate {
    private func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            self.currentPageRepo.currentPage.accept(.sheet(UIAlertController(title: "Simulator In Use",
                                                                             message: "The App Store is not available in the iOS simulator, please test this feature on a physical device.",
                                                                             preferredStyle: .alert)))
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()], completionBlock: { (success, error) in
                loadingView.removeFromSuperview()
                if let error = error {
                    self.currentPageRepo.currentPage.accept(.sheet(UIAlertController(title: "Failed to find Spotify on the AppStore.",
                                                                                     message: error.localizedDescription,
                                                                                     preferredStyle: .alert)))
                } else {
                    self.present(storeProductViewController, animated: true, completion: nil)
                }
            })
        }
    }

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
