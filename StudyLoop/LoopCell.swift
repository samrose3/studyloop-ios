//
//  LoopCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class LoopCell: UITableViewCell {
    
//    lazy var border: CALayer = {
//        let border = CALayer()
//        border.backgroundColor = SL_GRAY.colorWithAlphaComponent(0.3).CGColor
//        border.frame = CGRect(x: 15, y: 0, width: self.frame.width - 15, height: 0.5)
//        return border
//    }()
    
    lazy var loopLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.textColor = SL_BLACK
        return label
    }()
    
    lazy var newMessageInidcator: UILabel = {
        let label = UILabel()
        label.textColor = SL_RED
        label.font = UIFont.ioniconOfSize(17)
        label.text = String.ioniconWithName(.Record)
        return label
    }()
    
    lazy var lastLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureSubviews() {
        self.addSubview(self.loopLabel)
        self.addSubview(self.newMessageInidcator)
        self.addSubview(self.lastLabel)
        //self.layer.addSublayer(border)
        
        loopLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self.newMessageInidcator).offset(-20)
        }
        
        newMessageInidcator.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-20)
        }
        
        lastLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(loopLabel.snp_bottom).offset(1)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.bottom.equalTo(self).offset(-10)
        }
    }
    
    func configureCell(loop: Loop) {
        loopLabel.text = loop.subject
        lastLabel.text = loop.lastMessage
 
        let loops = NotificationService.noti.newMessages.map { "\($1)" }
        let hasNewMessage = loops.indexOf(loop.uid)
        
        if hasNewMessage != nil {
            newMessageInidcator.hidden = false
        } else {
            newMessageInidcator.hidden = true
        }
        
        let newLoops = NotificationService.noti.newLoops.map { "\($1)" }
        let isNewLoop = newLoops.indexOf(loop.uid)
        
        if isNewLoop != nil {
            self.backgroundColor = SL_LIGHT
        } else {
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        }
    }

}
