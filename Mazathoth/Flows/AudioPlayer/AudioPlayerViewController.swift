//
//  AudioPlayerViewController.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 14/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit
import MediaPlayer

public final class AudioPlayerViewController: UIViewController {
    
    private let file: FileSystemEntity
    
    // TODO: зависимость от синглтона вынести в assembly модуля
    private let player: AudioPlayerInterface = AudioPlayer.shared
    private var timer: Timer?
    
    private let playPauseButton = PlayPauseButton()
    private let timeSlider = UISlider()
    private let volumeSlider = MPVolumeView()
    
    private var shouldPositionTimeSlider = true
    
    // MARK: - Init
    
    init(file: FileSystemEntity) {
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
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.stop()
    }
    
    // MARK: - UI
    
    private func configureUI() {
        self.view.backgroundColor = .white
        self.navigationItem.title = self.file.name
        self.addPlayPauseButton()
        self.addTimeSlider()
        self.addVolumeSlider()
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
    
    private func addTimeSlider() {
        self.view.addSubview(self.timeSlider)
        self.timeSlider.translatesAutoresizingMaskIntoConstraints = false
        self.timeSlider.tintColor = .gray
        NSLayoutConstraint.activate([
            self.timeSlider.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 32.0),
            self.timeSlider.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -32.0),
            self.timeSlider.topAnchor.constraint(equalTo: self.playPauseButton.bottomAnchor, constant: 40.0)
            ])
    }
    
    private func addVolumeSlider() {
        self.view.addSubview(self.volumeSlider)
        self.volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        self.volumeSlider.showsRouteButton = false
        self.volumeSlider.tintColor = .lightGray
        NSLayoutConstraint.activate([
            self.volumeSlider.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 32.0),
            self.volumeSlider.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -32.0),
            self.volumeSlider.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60.0),
            self.volumeSlider.heightAnchor.constraint(equalToConstant: 40.0)
            ])
    }
    
    // MARK: - Private
    
    private func configurePlayer() {
        do {
            try self.player.open(.contentsOfPath(self.file.absolutePath))
        } catch {
            // TODO: Обработка ошибки открытия плеера
            print("Audio player cannot be open")
        }
    }
    
    private func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.shouldPositionTimeSlider else {
                return
            }
            self.timeSlider.value = Float(self.player.currentRelativeTime)
        }
    }
    
    // MARK: - Touch Handlers
    
    private func addTouchHandlers() {
        self.playPauseButton.onTap = { [weak self] in
            guard let self = self else { return }
            switch self.playPauseButton.kind {
            case .pause:
                self.playPauseButton.kind = .play
                self.player.pause()
            case .play:
                self.playPauseButton.kind = .pause
                self.player.play()
            }
        }
        self.timeSlider.addTarget(self, action: #selector(self.handleTouchDownSlider), for: .touchDown)
        self.timeSlider.addTarget(self, action: #selector(self.handleTouchUpSlider), for: .touchUpInside)
        self.timeSlider.addTarget(self, action: #selector(self.handleTouchUpSlider), for: .touchUpOutside)
    }
    
    @objc private func handleTouchUpSlider() {
        self.player.currentRelativeTime = Double(self.timeSlider.value)
        self.shouldPositionTimeSlider = true
    }
    
    @objc private func handleTouchDownSlider() {
        self.shouldPositionTimeSlider = false
    }
}
