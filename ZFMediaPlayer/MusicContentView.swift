//
//  MusicContentView.swift
//  ZFMediaPlayer
//
//  Created by 郑峰 on 2022/12/22.
//

import UIKit

class MusicContentView: UIView, UITableViewDelegate, UITableViewDataSource {

    var titleDataArray = Array<String>() {
        didSet {
            titleTableView?.reloadData()
        }
    }
    var player:ZFMusicPlayer?
    var lrcImage:UIImage?
    
    private var scrollView:UIScrollView?
    private var titleTableView:UITableView?
    private var lrcImageLabel:UILabel?
    private var lrcImageView: UIImageView?
    // 单行歌词显示
    private var singleLrcLabel:UILabel?
    // 多行歌词显示
    private var multiLrcLabel:UILabel?
    private var lines:Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        lines = 5
        // 初始化滚动视图
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(scrollView!)
        scrollView?.backgroundColor = UIColor.clear
        // 初始化歌曲列表
        titleTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width - 90, height: self.frame.size.height - 40), style: .plain)
        titleTableView?.backgroundColor = UIColor.clear
        titleTableView?.delegate = self
        titleTableView?.dataSource = self
        // 设置表格行间无分割线
        titleTableView?.separatorStyle = .none
        scrollView?.addSubview(titleTableView!)
        // 设置滚动视图可滚动范围
        scrollView?.contentSize = CGSize(width: self.frame.size.width * 2, height: self.frame.size.height)
        scrollView?.showsHorizontalScrollIndicator = false
        // 设置滚动视图翻页效果
        scrollView?.isPagingEnabled = true
        // 初始化单行歌词显示控件
        singleLrcLabel = UILabel(frame: CGRect(x: 20, y: self.frame.size.height - 50, width: self.frame.size.width - 40, height: 50))
        singleLrcLabel?.backgroundColor = UIColor.clear
        singleLrcLabel?.textColor = UIColor.white
        singleLrcLabel?.textAlignment = .center
        singleLrcLabel?.numberOfLines = 0;
        scrollView?.addSubview(singleLrcLabel!)
        // 初始化多行歌词显示控件
        multiLrcLabel = UILabel(frame: CGRect(x: self.frame.size.width + 20, y: 50, width: self.frame.size.width - 40, height: self.frame.size.height - 100))
        multiLrcLabel?.numberOfLines = lines!
        multiLrcLabel?.textAlignment = .center
        multiLrcLabel?.textColor = UIColor.white
        scrollView?.addSubview(multiLrcLabel!)
        // 初始化锁屏图片上的歌词标签
        lrcImageLabel = UILabel(frame: CGRect(x: 20, y: 0, width: frame.width - 40, height: frame.height))/////////////////////
        lrcImageLabel?.numberOfLines = lines!
        lrcImageLabel?.textAlignment = .center
        lrcImageLabel?.textColor = UIColor.white
    }
    
    // 设置当前界面显示的歌词 && 歌曲的播放时间
    func currentLRC(array:Array<LRCItem>, index:Int) {
        let lineLRC = array[index].lrc
        if singleLrcLabel?.text == lineLRC {
            return
        }
        singleLrcLabel?.text = lineLRC
        var lrcStr = String()
        if index < lines!/2 {
            // 前面用\n补齐
            let offset = lines!/2 - index
            for _ in 0..<offset {
                lrcStr.append("\n")
            }
            for i in 0..<(lines!-index) {
                lrcStr = lrcStr.appendingFormat("%@\n", array[i].lrc)
            }
        } else if array.count-1-index < lines!/2 {
            // 后面用\n补齐
            let offset = lines!/2 - (array.count-1-index)
            for i in index-lines!/2..<array.count {
                lrcStr = lrcStr.appendingFormat("%@\n", array[i].lrc)
            }
            for _ in 0..<offset {
                lrcStr.append("\n")
            }
        } else {
            for i in 0..<lines! {
                lrcStr.append(array[index - lines!/2 + i].lrc)
                lrcStr.append("\n")
            }
        }
        let attriStr = NSMutableAttributedString(string: lrcStr)
        let nsText = lrcStr as NSString
        let range = nsText.range(of: array[index].lrc)
        attriStr.setAttributes([NSAttributedString.Key.foregroundColor:UIColor.green], range: range)
        multiLrcLabel?.attributedText = attriStr
        lrcImageLabel?.attributedText = attriStr
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleDataArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID");
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
            cell?.backgroundColor = UIColor.clear
            cell?.textLabel?.textColor = UIColor.white
            cell?.selectionStyle = .none
        }
        cell?.textLabel?.text = self.titleDataArray[indexPath.row]
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.player?.playAt(index: indexPath.row, playing: self.player!.isPlaying)
    }
}
