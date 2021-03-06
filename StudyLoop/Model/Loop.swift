//
//  Loop.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation

class Loop {
    private var _uid: String!
    private var _courseId: String!
    private var _createdAt: Double!
    private var _subject: String!
    private var _universityId: String!
    private var _lastMessage: String!
    private var _updatedAt: Double?
    private var _hasCurrentUser: Bool!
    private var _userIds: [String]!
    private var _muted: Bool!
    
    var uid: String {
        return _uid
    }
    
    var courseId: String {
        return _courseId
    }
    
    var subject: String {
        return _subject
    }
    
    var createdAt: Double {
        return _createdAt
    }
    
    var universityId: String {
        return _universityId
    }
    
    var updatedAt: Double? {
        get {
            return _updatedAt
        }
        set(updatedAt) {
            _updatedAt = updatedAt
        }
    }
    
    var lastMessage: String {
        get {
            return _lastMessage
        }
        set(newLastMessage) {
            _lastMessage = newLastMessage
        }
    }
    
    var hasCurrentUser: Bool {
        get {
            return _hasCurrentUser
        }
        set(hasUser) {
            _hasCurrentUser = hasUser
        }
    }
    
    var userIds: [String] {
        return _userIds
    }
    
    var muted: Bool! {
        get {
            return _muted
        }
        set {
            _muted = newValue
        }
    }
    
    init(uid: String, loopDict: Dictionary<String, AnyObject>) {
        self._uid = uid
        self._courseId = loopDict["courseId"] as? String
        self._subject = loopDict["subject"] as? String
        self._universityId = loopDict["universityId"] as? String
        self._hasCurrentUser = false
        
        if let last = loopDict["lastMessage"] as? String {
            self._lastMessage = last
        } else {
            self._lastMessage = ""
        }
        
        if let last = loopDict["updatedAt"] as? String {
            self._updatedAt = Double(last)
        } else if let last = loopDict["updatedAt"] as? Int {
            self._updatedAt = Double(last)
        } else {
            self._updatedAt = nil
        }
        
        if let created = loopDict["createdAt"] as? Double {
            self._createdAt = created
        } else if let created = loopDict["createdAt"] as? String {
            self._createdAt = Double(created)
            
        }
        
        self._userIds = [String]()
        if let userIdsDict = loopDict["userIds"] as? Dictionary<String, AnyObject> {
            for (user, _) in userIdsDict {
                self._userIds.append(user)
            }
        }
        
        // Check for muted
        if let mutedLoops = UserService.us.currentUser.mutedLoopIds where mutedLoops.count > 0 {
            let isMuted = mutedLoops.indexOf(uid) == nil ? false : true
            self._muted = isMuted
        }
        
    }
}