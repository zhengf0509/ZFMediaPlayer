//
//  ViewController.swift
//  ZFMediaPlayer
//
//  Created by 郑峰 on 2022/12/22.
//

import UIKit

class ViewController: UIViewController, ZFMusicPlayerDelegate {

    private var player:ZFMusicPlayer?
    private var contentView:MusicContentView?
    private var titleLabel:UILabel?
    private var progress:UIProgressView?
    private var playBtn:UIButton?
    private var nextBtn:UIButton?
    private var lastBtn:UIButton?
    private var circleBtn:UIButton?
    private var randomBtn:UIButton?
    private var dataArray:Array<String>?
    private var timer:Timer?
    private var isBack:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(phoneToBack), name: NSNotification.Name("goBack"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(phoneToForward), name: NSNotification.Name("goForward"), object: nil)
        isBack = false
        createData()
        createPlayer()
        createView()
        updateUI()
    }
    
    private func createData() {
        dataArray = ["艾辰-初雪的谎言", "艾辰-谁与归", "后弦-龙的传人 (Live)"]
    }
    
    private func createPlayer() {
        player = ZFMusicPlayer()
        player?.songArray = dataArray!
        var mulArr = Array<LRCEngine>()
        for index in 0..<dataArray!.count {
            let engine = LRCEngine(fileName: dataArray![index])
            mulArr.append(engine)
        }
        player?.lrcsArray = mulArr
        player?.delegate = self
    }
    
    private func createView() {
        // 创建背景
        let bg = UIImageView(frame: self.view.bounds)
        bg.image = UIImage(named: "BG.jpeg")
        bg.isUserInteractionEnabled = true
        self.view.addSubview(bg)
        // 创建歌曲标题
        titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 40))
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel?.textAlignment = .center
        titleLabel?.text = dataArray![0]
        titleLabel?.backgroundColor = UIColor.clear
        titleLabel?.textColor = UIColor.white
        bg.addSubview(titleLabel!)
        // 创建进度条
        progress = UIProgressView(progressViewStyle: .default)
        progress?.progressTintColor = UIColor.white
        progress?.frame = CGRect(x: 20, y: self.view.frame.height - 70, width: self.view.frame.width - 40, height: 5)
        bg.addSubview(progress!)
        // 创建播放按钮
        playBtn = UIButton(type: .custom)
        playBtn?.setBackgroundImage(UIImage(named: "play"), for: .normal)
        playBtn?.setBackgroundImage(UIImage(named: "pause"), for: .selected)
        playBtn?.frame = CGRect(x: self.view.frame.width/2 - 20, y: self.view.frame.height - 45, width: 40, height: 30)
        playBtn?.addTarget(self, action:#selector(playMusic), for: .touchDown)
        bg.addSubview(playBtn!)
        // 创建下一首按钮
        nextBtn = UIButton(type: .custom)
        nextBtn?.frame = CGRect(x: self.view.frame.width/2 + 40, y: self.view.frame.height - 45, width: 40, height: 30)
        nextBtn?.setBackgroundImage(UIImage(named: "nextSong"), for: .normal)
        nextBtn?.addTarget(self, action:#selector(nextSong), for: .touchUpInside)
        bg.addSubview(nextBtn!)
        // 创建上一首按钮
        lastBtn = UIButton(type: .custom)
        lastBtn?.frame = CGRect(x: self.view.frame.width/2 - 80, y: self.view.frame.height - 45, width: 40, height: 30)
        lastBtn?.setBackgroundImage(UIImage(named: "lastSong"), for: .normal)
        lastBtn?.addTarget(self, action:#selector(lastSong), for: .touchUpInside)
        bg.addSubview(lastBtn!)
        // 循环播放按钮
        circleBtn = UIButton(type: .custom)
        circleBtn?.setBackgroundImage(UIImage(named: "circleClose"), for: .normal)
        circleBtn?.setBackgroundImage(UIImage(named: "circleOpen"), for: .selected)
        circleBtn?.frame = CGRect(x: self.view.frame.width/2 - 140, y: self.view.frame.height - 45, width: 40, height: 30)
        circleBtn?.addTarget(self, action:#selector(circle), for: .touchUpInside)
        bg.addSubview(circleBtn!)
        // 随机播放按钮
        randomBtn = UIButton(type: .custom)
        randomBtn?.setBackgroundImage(UIImage(named: "randomClose"), for: .normal)
        randomBtn?.setBackgroundImage(UIImage(named: "randomOpen"), for: .selected)
        randomBtn?.frame = CGRect(x: self.view.frame.width/2 + 100, y: self.view.frame.height - 45, width: 40, height: 35)
        randomBtn?.addTarget(self, action:#selector(random), for: .touchUpInside)
        bg.addSubview(randomBtn!)
        // 歌词列表&&歌词显示控件
        contentView = MusicContentView(frame: CGRect(x: 0, y: 90, width: self.view.frame.width, height: self.view.frame.height - 150))
        contentView?.titleDataArray = dataArray!
        contentView?.player = player!
        bg.addSubview(contentView!)
        
        if !isBack! {
            return
        }
        
    }
    
    private func updateUI() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    // MARK: - action
    @objc private func phoneToBack() {
        isBack = true
    }
    
    @objc private func phoneToForward() {
        isBack = false
    }
    
    @objc private func playMusic() {
        if player!.isPlaying {
            playBtn?.isSelected = false
            player?.stop()
        } else {
            playBtn?.isSelected = true
            player?.play()
        }
    }
    
    @objc private func nextSong() {
        player?.nextMusic()
    }
    
    @objc private func lastSong() {
        player?.lastMusic()
    }
    
    @objc private func circle() {
        if player!.isRunLoop {
            player?.isRunLoop = false
            circleBtn?.isSelected = false
        } else {
            player?.isRunLoop = true
            circleBtn?.isSelected = true
        }
    }
    
    @objc private func random() {
        if player!.isRandom {
            player?.isRandom = false
            randomBtn?.isSelected = false
        } else {
            player?.isRandom = true
            randomBtn?.isSelected = true
        }
    }
    
    @objc private func update() {
        titleLabel?.text = dataArray![player!.currentIndex]
        // 更新进度条
        if player!.hadPlayerTime != 0 {
            let progress = Float(player!.hadPlayerTime) / Float(player!.currentSongTime)
            self.progress?.progress = progress
        }
        // 更新歌词
        let engine = player!.lrcsArray[player!.currentIndex]
        engine.getCurrentLRC(time: Float(player!.hadPlayerTime)) { lrcArray, index in
            self.contentView!.currentLRC(array: lrcArray, index: index)
        }
    }
    
    // MARK: - ZFMusicPlayerDelegate
    
    func musicPlayEnd(willContinuePlaying:Bool) {
        if willContinuePlaying {
            playBtn?.isSelected = true
        } else {
            playBtn?.isSelected = false
        }
    }


}

