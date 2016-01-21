//
//  DrawerCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/29/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit

class DrawerCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var menuIcon: UILabel!
    
    var item: MenuItem!
    let border = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(item: MenuItem) {
        self.item = item
        itemLabel.text = item.title
        
        // Icon Defaults
        menuIcon.hidden = true
        menuIcon.textColor = SL_BLACK
        menuIcon.font = UIFont.ioniconOfSize(17)
        
        if item.title == "Add Course" {
            menuIcon.hidden = false
            menuIcon.text = String.ioniconWithCode("ion-plus")
        } else if item.title == "Settings" {
            menuIcon.hidden = false
            menuIcon.text = String.ioniconWithCode("ion-ios-gear")
        } else {
            let courses = NotificationService.noti.courseActivity.map { "\($1)" }
            let hasNotification = courses.indexOf(item.courseId)
            
            "\(item.title) has Notification: \(hasNotification)".log_debug()
            
            if hasNotification != nil {
                menuIcon.hidden = false
                menuIcon.textColor = SL_RED
                menuIcon.text = String.ioniconWithCode("ion-record")
            }
        }
        
        border.backgroundColor = SL_GRAY.colorWithAlphaComponent(0.3).CGColor
        border.frame = CGRect(x: 15, y: 0, width: layer.frame.width - 15, height: 0.5)
        layer.addSublayer(border)
    }
}
