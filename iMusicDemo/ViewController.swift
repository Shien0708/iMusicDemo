//
//  ViewController.swift
//  iMusicDemo
//
//  Created by 方仕賢 on 2022/1/4.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var fireplaceImageView: UIImageView!
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var endingTimeLabel: UILabel!
    @IBOutlet weak var startingTimeLabel: UILabel!
    
    @IBOutlet weak var singerLabel: UILabel!
    
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    
    var musicIndex = 0
    
    var timer : Timer?
    var player = AVPlayer()
    var playItem: AVPlayerItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNowPlaying()
        setupRemoteCommandCenter()
        
        timeSlider.setThumbImage(UIImage(named: "circle"), for: .normal)
        volumeSlider.setThumbImage(UIImage(named: "circle"), for: .normal)
        
        setMusic(currentMusic: 0)
        fireplaceImageView.image = UIImage.animatedImageNamed("fireplace-", duration: 1)
        dogImageView.image = UIImage.animatedImageNamed("sleepingDog-", duration: 2)
    }
    
    
    
    func countDown(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.timeSlider.value += 1
            self.startingTimeLabel.text = self.displayTime(self.player.currentTime().seconds)
            self.endingTimeLabel.text = self.displayTime(Double(self.timeSlider.maximumValue)-self.player.currentTime().seconds)
            if self.timeSlider.value == self.timeSlider.maximumValue {
                if self.musicIndex == myMusic.count-1 && self.repeatButton.tintColor == .white && self.shuffleButton.tintColor == .white {
                    self.playButton.isHidden = false
                    self.pauseButton.isHidden = true
                } else {
                    self.changeMusic(self.forwardButton)
                }
                
            }
        })
    }
    
    func displayTime(_ sec: Double) -> String {
        var string = ""
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        
        if sec >= 0 && sec < 10 {
            string = "0:0\(String(describing: formatter.string(from: sec)!))"
        } else if sec < 60 && sec > 10 {
            string = "0:\(String(describing: formatter.string(from: sec)!))"
        } else {
            string = "\(String(describing: formatter.string(from: sec)!))"
        }
        
        return string
    }
    
    func setupNowPlaying(){
        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = myMusic[musicIndex].name
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        nowPlayingInfo[MPMediaItemPropertyArtist] = myMusic[musicIndex].singer
       
        if let image = UIImage(named: myMusic[musicIndex].imageName) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {size in
                return image
            })
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
       
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget {event in
                self.play(self.playButton)
                MPNowPlayingInfoCenter.default().playbackState = .playing
                return .success
        }
        
        commandCenter.pauseCommand.addTarget{event in
                self.pause(self.pauseButton)
            MPNowPlayingInfoCenter.default().playbackState = .paused
                return .success
        }
        
        commandCenter.nextTrackCommand.addTarget{event in
            self.changeMusic(self.forwardButton)
            MPNowPlayingInfoCenter.default().playbackState = .playing
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget{event in
            self.changeMusic(self.forwardButton)
            MPNowPlayingInfoCenter.default().playbackState = .playing
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.changePlaybackRateCommand.isEnabled = true
    }
    
    
    func setMusic(currentMusic: Int){
        let fileUrl = Bundle.main.url(forResource: "\(myMusic[currentMusic].name)", withExtension: "mp3")!
        
        playItem = AVPlayerItem(url: fileUrl)
        
        musicImageView.image = UIImage(named: myMusic[currentMusic].imageName)
        singerLabel.text = myMusic[currentMusic].singer
        songLabel.text = myMusic[currentMusic].name
        
        timeSlider.maximumValue = Float(myMusic[musicIndex].time)
        timeSlider.value = 0
        
        startingTimeLabel.text = displayTime(0)
        endingTimeLabel.text = displayTime(Double(timeSlider.maximumValue))
        player.replaceCurrentItem(with: playItem)
    }
    
    
    @IBAction func changeMusic(_ sender: UIButton) {
        
        if shuffleButton.tintColor == .blue {
            musicIndex = Int.random(in: 0...myMusic.count-1)
        } else if repeatButton.currentImage != UIImage(systemName: "repeat.1") {
            if sender == forwardButton {
                musicIndex = (musicIndex+1) % myMusic.count
            } else {
                musicIndex = (musicIndex-1+myMusic.count) % myMusic.count
            }
        }
        
        setMusic(currentMusic: musicIndex)
        setupNowPlaying()
        play(playButton)
    }
    

    
    @IBAction func pause(_ sender: Any) {
        playButton.isHidden = false
        pauseButton.isHidden = true
        timer?.invalidate()
        player.pause()
        setupNowPlaying()
    }
    
    
    @IBAction func setTime(_ sender: UISlider) {
        let time = sender.value
        player.seek(to: CMTime(value: CMTimeValue(time), timescale: 1))
        startingTimeLabel.text = displayTime(player.currentTime().seconds)
        endingTimeLabel.text = displayTime(Double(timeSlider.maximumValue)-player.currentTime().seconds)
        setupNowPlaying()
    }
    
    
    @IBAction func play(_ sender: UIButton) {
        playButton.isHidden = true
        pauseButton.isHidden = false
        
        player.play()
        
        countDown()
        setupNowPlaying()
    }
    
    
    
    @IBAction func setVolume(_ sender: UISlider) {
        player.volume = sender.value
    }
    

    @IBAction func `repeat`(_ sender: Any) {
        if repeatButton.tintColor == .white {
            repeatButton.tintColor = .blue
            shuffleButton.tintColor = .white
        } else if repeatButton.currentImage == UIImage(systemName: "repeat.1") {
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
            repeatButton.tintColor = .white
        } else {
            repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        }
    }
    
    
    @IBAction func shuffle(_ sender: Any) {
        if shuffleButton.tintColor == .blue {
            shuffleButton.tintColor = .white
        } else {
            shuffleButton.tintColor = .blue
            repeatButton.tintColor = .white
            repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        }
    }
    
}

