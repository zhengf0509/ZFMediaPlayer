//
//  ZFMusicPlayer.swift
//  ZFMediaPlayer
//
//  Created by 郑峰 on 2022/12/22.
//

import UIKit
import AVFoundation

@objc protocol ZFMusicPlayerDelegate:NSObjectProtocol {
    @available(iOS 2.2, *)
    @objc optional func musicPlayEnd(willContinuePlaying:Bool)
}

class ZFMusicPlayer: NSObject, AVAudioPlayerDelegate {
    var songArray = Array<String>()
    var lrcsArray = Array<LRCEngine>()
    var isRunLoop = true
    var isRandom = false
    var isPlaying = false
    var delegate:ZFMusicPlayerDelegate?
    var currentIndex = 0
    var currentSongTime = 0
    var hadPlayerTime = 0
    
    private var player:AVAudioPlayer?
    private var timer:Timer?
    
    override init() {
        super.init()
        timer = Timer.scheduledTimer(timeInterval: 1/60.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func play() {
        if self.player != nil {
            self.player?.play()
            self.isPlaying = true
            return
        }
        
        guard songArray.count != 0 else {
            return
        }
        
        self.initPlayerAt(index: 0, playing: true)
    }
    
    func stop() {
        guard self.player != nil else {
            return
        }
        
        if self.player!.isPlaying {
            self.player?.stop()
            self.isPlaying = false
        }
    }
    
    func end() {
        guard self.player != nil else {
            return
        }
        self.player?.stop()
        self.isPlaying = false
        self.player = nil
    }
    
    func playOrStop() {
        if self.isPlaying {
            self.stop()
        } else {
            self.play()
        }
    }
    
    func lastMusic() {
        self.switchMusic(isNext: false)
    }
    
    func nextMusic() {
        self.switchMusic(isNext: true)
        
    }
    
    private func switchMusic(isNext:Bool) {
        guard self.player != nil else {
            return
        }
        let play = self.isPlaying
        self.player?.stop()
        isPlaying = false
        player = nil
        
        if (isNext) {
            currentIndex = (currentIndex + 1) % songArray.count
        } else {
            if (currentIndex == 0) {
                currentIndex = songArray.count - 1
            } else {
                currentIndex -= 1
            }
        }
        
        if isRandom {
            currentIndex = Int(arc4random()) % songArray.count
        }
        
        self.initPlayerAt(index: currentIndex, playing: play)
    }
    
    func playAt(index:Int, playing:Bool) {
        guard index >= 0 && index < songArray.count else {
            return
        }
        
        player?.stop()
        isPlaying = false
        player = nil
        
        self.initPlayerAt(index: index, playing: playing)
    }
    
    // MARK: - private
    
    @objc private func update() {
        if let p = player {
            hadPlayerTime = Int(p.currentTime)
        }
    }
    
    private func initPlayerAt(index:Int, playing:Bool) {
//        let path = Bundle.main.path(forResource: songArray[index], ofType: ".mp3")
        let path = Bundle.main.resourcePath! + "/Song/" + songArray[index] + ".mp3"
        let url = URL(filePath: path)
        self.player = try! AVAudioPlayer(contentsOf: url)
        self.player?.delegate = self
        if playing {
            self.player?.play()
        }
        isPlaying = playing
        currentIndex = index
        currentSongTime = Int(player!.duration)
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        isPlaying = false
        
        if currentIndex < songArray.count - 1 {
            currentIndex += 1
        } else if isRunLoop {
            currentIndex = 0
        } else {
            self.delegate?.musicPlayEnd?(willContinuePlaying: false)
            return
        }
        
        self.initPlayerAt(index: currentIndex, playing: true)
        self.delegate?.musicPlayEnd?(willContinuePlaying: true)
    }

}
