//
//  LoopCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class LoopCell: UITableViewCell {
    
    @IBOutlet weak var loopLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newMessageIndicator: UILabel!
    @IBOutlet weak var mutedIndicator: UILabel!

    let border = CALayer()
    var university: University!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newMessageIndicator.textColor = SL_RED
        newMessageIndicator.font = UIFont.ioniconOfSize(14)
        newMessageIndicator.text = String.ioniconWithName(.Record)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(loop: Loop) {
        loopLabel.text = loop.subject
        newMessageIndicator.hidden = true
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        
        if loop.lastMessage == "" {
            lastLabel.text = "No messages 😢 Say something! 📣"
        } else {
            lastLabel.text = loop.lastMessage
        }
        
        if loop.updatedAt != nil {
            let date = TimeUtils.tu.dayStringFromTime(loop.updatedAt!)
            dateLabel.text = date
        } else {
            dateLabel.text = ""
        }
        
        if let muted = loop.muted where muted == true {
            self.mutedIndicator.text = String.ioniconWithName(.AndroidVolumeOff)
        } else {
            self.mutedIndicator.text = ""
        }
        
        let loopNotifications = NotificationService.noti.notifications.filter { $0.loopId == loop.uid }
        if loopNotifications.count > 0 {
            if loopNotifications[0].type == LOOP_MESSAGE_RECEIVED {
                newMessageIndicator.hidden = false
            } else if loopNotifications[0].type == LOOP_CREATED {
                self.backgroundColor = SL_LIGHT
            }
        }
    }
}
