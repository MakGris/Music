//
//  TrackDetailView.swift
//  MusicApp
//
//  Created by Maksim Grischenko on 13.10.2022.
//
import Foundation
import UIKit
import SDWebImage
import AVKit

protocol TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForNextTrack() -> SearchViewModel.Cell?
}

class TrackDetailView: UIView {
    
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var miniGoForwardButton: UIButton!
    
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    @IBOutlet weak var miniTrackImageView: UIImageView!
    
    @IBOutlet weak var miniTrackTitleLabel: UILabel!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton!
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var authorTitleLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MAinTabBarControllerDelegate?
    
//    MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        setupGestures()
    }
    
    //    MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        miniTrackTitleLabel.text = viewModel.trackName
        trackTitleLabel.text = viewModel.trackName
        authorTitleLabel.text = viewModel.artistName
        playTrack(previewURL: viewModel.previewUrl)
        monitorStartTime()
        observePlayerCurrentTime()
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        let string600 = viewModel.iconUrlString?.replacingOccurrences(
            of: "100x100",
            with: "600x600"
        )
        guard let url = URL(string: string600 ?? "") else { return }
        miniTrackImageView.sd_setImage(with: url)
        trackImageView.sd_setImage(with: url)
        
    }
    
    private func setupGestures() {
        miniTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized)))
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    private func playTrack(previewURL: String?) {
        print("try to listen track by URL: \(previewURL ?? "undefined")")
        
        guard let url = URL(string: previewURL ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
//    MARK: - Maximizing and minimizing gestures
    
    @objc private func handleTapMaximized() {
        print("tapping to maximized")
        self.tabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("began")
        case .changed:
            handlePanChanged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        @unknown default:
            print("unknown default case")
        }
    }
    
    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1,options: .curveEaseOut) {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.tabBarDelegate?.maximizeTrackDetailController(viewModel: nil)
            } else {
                self.miniTrackView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        }
    }
    
    @objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut) {
                self.maximizedStackView.transform = .identity
                if translation.y > 50 {
                    self.tabBarDelegate?.minimizeTrackDetailController()
                    self.miniPlayPauseButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }
                
            }
        @unknown default:
            print("unknown default")
        }
    }
    
//    MARK: - Time Setup
    
    private func monitorStartTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationTimeText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLabel.text = "-\(currentDurationTimeText)"
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }

    //    MARK: - Animations
    
    private func enlargeTrackImageView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut
        ) {
            self.trackImageView.transform = .identity
        }
    }
    
    private func reduceTrackImageView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut
        ) {
            let scale: CGFloat = 0.8
            self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
//    MARK: - @IBActions
    
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {
        let percantage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Double(percantage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
       
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        tabBarDelegate?.minimizeTrackDetailController()
        miniPlayPauseButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        self.removeFromSuperview()
    }
    
    @IBAction func previousTrack(_ sender: Any) {
        let cellViewModel = (delegate?.moveBackForPreviousTrack())
        guard let cellViewModel = cellViewModel else { return }
        self.set(viewModel: cellViewModel)
    }
    
    @IBAction func nextTrack(_ sender: Any) {
        let cellViewModel = (delegate?.moveForwardForNextTrack())
        guard let cellViewModel = cellViewModel else { return }
        self.set(viewModel: cellViewModel)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
            reduceTrackImageView()
        }
    }

}
