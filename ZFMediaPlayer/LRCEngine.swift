//
//  LRCEngine.swift
//  ZFMediaPlayer
//
//  Created by 郑峰 on 2022/12/22.
//

import UIKit

class LRCEngine: NSObject {
    
    var author:String?
    var album:String?
    var title:String?
    
    private var lrcArray:Array<LRCItem>?
    
    init(fileName:String){
        super.init()
        lrcArray = Array<LRCItem>()
        createData(file:fileName)
    }
    
    func createData(file:String) {
        // 读取文件
        let lrcPath = Bundle.main.resourcePath! + "/LRC/" + file + ".lrc"
        let dataStr = try! String(contentsOf: URL(filePath: lrcPath), encoding: .utf8)
        // 去掉\r
        let lrcArray = dataStr.components(separatedBy: "\r")
        // 解析并将空数据去掉
        for str in lrcArray {
            if str.count == 0 {
                continue
            }
            // 判读是歌词数据还是文件信息数据
            let c = str[str.index(after: str.startIndex)]
            if c >= "0" && c <= "9" {
                // 是歌词数据
                getLrc(data:str)
            } else {
                // 是文件信息数据
                getInfo(data: str)
            }
            
        }
        _ = self.lrcArray?.sorted(by: { item1, item2 in
            return item1.time < item2.time
        })
    }
    
    /// 获取当前时刻的歌词
    /// - Parameters:
    ///   - handle: 传入根据时间排序后的歌词数组，以及当前歌词对应的位置
    ///   - time: 时间点
//    func animate(withDuration duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil)
    func getCurrentLRC(time:Float, handle:((Array<LRCItem>, Int) -> Void)? = nil) {
        if handle == nil {
            return
        }
        
        if self.lrcArray?.count == 0 {
            handle!([], 0)
            return
        }
        
        UIView.animate(withDuration: 1) {
            print("")
        }
        // 找到大于time歌词的地方
        var index = -2
        for i in 0..<self.lrcArray!.count {
            if self.lrcArray![i].time > time {
                index = i - 1;
                break
            }
        }
        
        if index == -1 {
            index = 0;
        } else if index == -2 {
            // 没有更大的时间
            index = self.lrcArray!.count - 1
        }
        handle!(self.lrcArray!, index)
    }
    
    // MARK: - private
    
    private func getLrc(data:String) {
        // 按]分割
        let arr = data.components(separatedBy: "]")
        // 解析时间
//        for index in 0..<arr.count {
//            let timeStrTemp = arr[index]
//            // 去掉[
//            let timeStr = timeStrTemp[timeStrTemp.index(after: timeStrTemp.startIndex)...]
//            // 时间转换成秒为单位
//            let timeArr = timeStr.components(separatedBy: ":")
//            let min = CGFloat(Double(timeArr[0]) ?? 0)
//            let sec = CGFloat(Double(timeArr[1]) ?? 0)
//            // 创建模型
//            let item = LRCItem()
//            item.time = min * 60 + sec
//            item.lrc = arr.last!
//            self.lrcArray?.append(item)
//        }
        let timeStrTemp = arr[0]
        // 去掉[
        let timeStr = timeStrTemp[timeStrTemp.index(after: timeStrTemp.startIndex)...]
        // 时间转换成秒为单位
        let timeArr = timeStr.components(separatedBy: ":")
        let min = Float(timeArr[0])
        let sec = Float(timeArr[1])
        // 创建模型
        let item = LRCItem()
        item.time = min! * 60 + sec!
        item.lrc = arr.last!
        self.lrcArray?.append(item)
    }
    
    private func getInfo(data:String) {
        // 按]分割
        let arr = data.components(separatedBy: ":")
        let tempStr = arr[1]
        let content:String? = String(tempStr[..<tempStr.index(before: tempStr.endIndex)])
        if arr[0] == "[ti" {
            self.title = content
        } else if arr[0] == "[ar" {
            self.author = content
        } else if arr[0] == "[al" {
            self.album = content
        }
    }
    
}
