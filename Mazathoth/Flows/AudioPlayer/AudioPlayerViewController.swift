//
//  AudioPlayerViewController.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 14/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit
import AVFoundation

public final class AudioPlayerViewController: UIViewController {
    
    private let file: InternalFile
    
    // TODO: для плеера будет отдельный класс
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    private let playPauseButton = PlayPauseButton()
    private let slider = UISlider()
    
    // MARK: - Init
    
    init(file: InternalFile) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configurePlayer()
        self.startTimer()
        self.addTouchHandlers()
    }
    
    // MARK: - UI
    
    private func configureUI() {
        self.view.backgroundColor = .white
        self.navigationItem.title = self.file.name
        self.addPlayPauseButton()
        self.addSlider()
    }
    
    private func addPlayPauseButton() {
        self.view.addSubview(self.playPauseButton)
        self.playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.playPauseButton.widthAnchor.constraint(equalToConstant: 100.0),
            self.playPauseButton.heightAnchor.constraint(equalToConstant: 100.0),
            self.playPauseButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.playPauseButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
    }
    
    private func addSlider() {
        self.view.addSubview(self.slider)
        self.slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.slider.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 32.0),
            self.slider.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -32.0),
            self.slider.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60.0)
            ])
    }
    
    // MARK: - Private
    
    private func configurePlayer() {
        guard let data = FileManager.default.contents(atPath: self.file.absolutePath) else {
            // TODO: показать ошибку
            return
        }
        do {
            let player = try AVAudioPlayer(data: data)
            self.player = player
        } catch {
            // TODO: показать ошибку
        }
    }
    
    private func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.slider.value = Float(player.currentTime / player.duration)
        }
    }
    
    // MARK: - Touch Handlers
    
    private func addTouchHandlers() {
        self.playPauseButton.onTap = { [weak self] in
            guard let self = self else { return }
            switch self.playPauseButton.kind {
            case .pause:
                self.playPauseButton.kind = .play
                self.player?.pause()
            case .play:
                self.playPauseButton.kind = .pause
                self.player?.play()
            }
        }
        self.slider.addTarget(self, action: #selector(self.sliderValueChanged), for: .valueChanged)
    }
    
    @objc private func sliderValueChanged() {
        guard let player = self.player else { return }
        let value = self.slider.value
        let duration = player.duration
        player.currentTime = duration * TimeInterval(value)
    }
}
