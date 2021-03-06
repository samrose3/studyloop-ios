//
//  LoopMessageCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/8/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//*

import UIKit
import SnapKit
import Alamofire

class LoopMessageCell: UITableViewCell {
    
    var request: Request?
    var imageUrl = ""
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.textColor = SL_GREEN
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 10)
        label.textColor = SL_GRAY
        label.textAlignment = .Right
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var initialsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSans", size: 17)
        label.textColor = SL_CORAL
        label.textAlignment = .Center
        return label
    }()
    
    lazy var userAvatar: UIImageView = {
        let avatar = UIImageView(image: nil)
        avatar.backgroundColor = SL_LIGHT
        avatar.layer.cornerRadius = 20
        avatar.clipsToBounds = true
        return avatar
    }()
    
    lazy var attachmentImage: UIImageView = {
        let attachment = UIImageView(image: nil)
        attachment.contentMode = .ScaleAspectFit
        return attachment
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
        self.addSubview(self.userAvatar)
        self.addSubview(self.initialsLabel)
        self.addSubview(self.nameLabel)
        self.addSubview(self.timeLabel)
        self.addSubview(self.bodyLabel)
        self.addSubview(self.attachmentImage)
        
        userAvatar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(18)
            make.left.equalTo(self).offset(20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        initialsLabel.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.userAvatar)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(15)
            make.left.equalTo(self.userAvatar.snp_right).offset(10)
            make.right.equalTo(self.timeLabel.snp_left).offset(-10)
        }
        
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self.nameLabel.snp_right).offset(10)
            make.right.equalTo(self).offset(-20)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.nameLabel.snp_bottom).offset(1)
            make.left.equalTo(self.userAvatar.snp_right).offset(10)
            make.right.equalTo(self).offset(-20)
            make.bottom.equalTo(self.attachmentImage.snp_top).offset(-10)
        }
        
        attachmentImage.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.bodyLabel.snp_bottom).offset(10)
            make.left.equalTo(self.userAvatar.snp_right).offset(20)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(150)
            make.bottom.equalTo(self).offset(-10)
        }
    }
    
    func configureCell(text: String, name: String?, createdAt: Double, imageUrl: String?, attachmentUrl: String?) {
        self.selectionStyle = .None
        bodyLabel.text = text
        
        let time = TimeUtils.tu.timeStringFromUnixTime(createdAt)
        timeLabel.text = time
        
        if name != nil {
            nameLabel.text = name
            
            if imageUrl == nil {
                let nameArray = name!.characters.split{ $0 == " " }.map(String.init)
                
                var initialsArray = [String]()
                for name in nameArray {
                    if let letter = name.characters.first {
                        initialsArray.append(String(letter))
                    }
                }
                
                
                let initials = initialsArray.joinWithSeparator("")
                initialsLabel.text = initials
                
            }
        } else {
            nameLabel.text = "Removed User"
            initialsLabel.text = "RM"
        }
        
        if attachmentUrl != nil {
            self.imageUrl = attachmentUrl!
            if let img = LoopVC.imageCache.objectForKey(attachmentUrl!) as? UIImage {
                self.attachmentImage.image = img
                self.attachmentImage.hidden = false
                self.attachmentImage.snp_updateConstraints(closure: { (make) -> Void in
                    make.height.equalTo(img.size.height)
                })
            } else {
                let fullUrl = IMAGE_BASE + attachmentUrl!
                request = Alamofire.request(.GET, fullUrl).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let image = UIImage(data: data!)!
                        let newImageWidth = self.frame.width - self.userAvatar.frame.width - 10
                        let resizedImage = ImageUtil.iu.resizeImage(image, newWidth: newImageWidth)
                        
                        self.attachmentImage.image = resizedImage
                        self.attachmentImage.hidden = false
                        
                        self.attachmentImage.snp_updateConstraints(closure: { (make) -> Void in
                            make.height.equalTo(resizedImage.size.height)
                        })
                        
                        LoopVC.imageCache.setObject(resizedImage, forKey: attachmentUrl!)
                    } else {
                        print("There was an error!", err)
                    }
                })
            }
        } else {
            self.attachmentImage.hidden = true
            self.attachmentImage.image = nil
            
            self.attachmentImage.snp_updateConstraints(closure: { (make) -> Void in
                make.height.equalTo(0)
            })
        }
        
        if imageUrl != nil {
            initialsLabel.hidden = true
            if let img = LoopVC.imageCache.objectForKey(imageUrl!) as? UIImage {
                self.userAvatar.image = img
            } else {
                request = Alamofire.request(.GET, imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.userAvatar.image = img
                        LoopVC.imageCache.setObject(img, forKey: imageUrl!)
                    } else {
                        print("There was an error!", err)
                    }
                })
            }
        } else {
            initialsLabel.hidden = false
            userAvatar.image = nil
        }
    }
}
