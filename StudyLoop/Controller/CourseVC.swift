//
//  CourseVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import KYDrawerController

class CourseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingBtn: UIBarButtonItem!
    @IBOutlet weak var addLoopBtn: MaterialButton!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var noCourseLbl: UILabel!
    
    var loops = [Loop]()
    var snapCache: [FDataSnapshot]?
    var ref: Firebase!
    var selectedLoop: Loop! = nil
    var handle: UInt!
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set Add Loop Icon
        addLoopBtn.titleLabel?.font = UIFont.ioniconOfSize(30)
        addLoopBtn.setTitle(String.ioniconWithName(.AndroidAdd), forState: .Normal)
        
        // Set navigation menu title and icons
        settingBtn.setTitleTextAttributes(attributes, forState: .Normal)
        settingBtn.title = ""
        menuBtn.setTitleTextAttributes(attributes, forState: .Normal)
        menuBtn.title = String.ioniconWithName(.Navicon)
        
        // Table
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64.0
        
        checkUserData { (result) -> Void in
            print(result)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Load last viewed course or selected course
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String {
            noCourseLbl.hidden = true
            addLoopBtn.hidden = false
            settingBtn.title = String.ioniconWithName(.More)
            ActivityService.act.setLastCourse(courseId)
            
            if let courseTitle = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE_TITLE) as? String {
                navigationItem.title = courseTitle
            }
            
            // Get Loops in Course
            handle = DataService.ds.REF_LOOPS
                .queryOrderedByChild("courseId")
                .queryEqualToValue(courseId)
                .observeEventType(.Value, withBlock: {
                    snapshot in
                    
                    // Clear current loops
                    self.loops.removeAll()
                    
                    // Add new set of loops
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        self.snapCache = snapshots
                        self.refreshLoopObjects(snapshots)
                    }
                    
                    self.loops.sortInPlace { return $0.createdAt > $1.createdAt }
                    
                    self.tableView.reloadData()
                })
        } else {
            loops.removeAll()
            tableView.reloadData()
            noCourseLbl.hidden = false
            addLoopBtn.hidden = true
            settingBtn.title = ""
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE_TITLE)
        }
    }
    
    func refreshLoopObjects(snapshots: [FDataSnapshot]?) {
        // Guard against nil
        guard snapshots != nil else {
            return
        }
        
        // Clear current loops
        self.loops.removeAll()
        
        // Reconstruct loops, updating UserSettings through Loop() construction
        for snap in snapshots! {
            if let loopDict = snap.value as? Dictionary<String, AnyObject> {
                
                // Create Loop Object
                let loop = Loop(uid: snap.key, loopDict: loopDict)
                
                // Check if user is in loop
                let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
                let userIndex = loop.userIds.indexOf((userId)!)
                if userIndex != nil {
                    loop.hasCurrentUser = true
                }
                self.loops.append(loop)
            }
        }
        
        // Reorder loops
        self.loops.sortInPlace { return $0.createdAt > $1.createdAt }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // Watch for notifications
        Event.register(NOTIFICATION) {
            self.tableView.reloadData()
        }
        
        // Watch for mute
        Event.register(REFRESH_LOOPS) {
            self.refreshLoopObjects(self.snapCache)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Remove Notifications
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String {
            let courseNotifications = NotificationService.noti.notifications.filter { $0.courseId == courseId && $0.type == LOOP_CREATED }
            for notification in courseNotifications {
                NotificationService.noti.removeNotification(notification.uid)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        //Remove Firebase observer handler
        if handle != nil {
            DataService.ds.REF_LOOPS.removeObserverWithHandle(handle)
        }
    }
    
    
    func checkUserData(completion: (result: Bool) -> Void) {
        if UserService.us.currentUser.universityId == nil {
            // Go to select University
            print("select university")
            self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
        } else {
            if let tempPassword = UserService.us.currentUser.isTemporaryPassword where tempPassword == 1 {
                // change password
                print("change password")
                self.performSegueWithIdentifier(SEGUE_CHANGE_PWD, sender: nil)
            } else {
                // Get last course
                ActivityService.act.getLastCourse({ (courseId) -> Void in
                    NSUserDefaults.standardUserDefaults().setValue(courseId, forKey: KEY_COURSE)
                    completion(result: true)
                })
            }
        }
    }
    
    // MARK: - Table View Funcs
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let loop = loops[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("LoopCell") as? LoopCell {
            cell.configureCell(loop)
            return cell
        }
        return LoopCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row < loops.count && loops.count > 0 {
            selectedLoop = loops[indexPath.row]
            
            if selectedLoop.hasCurrentUser == true {
                self.performSegueWithIdentifier(SEGUE_MESSAGES, sender: nil)
            } else {
                joinLoop()
            }
        } else {
            print("Selected row index is out of range. Selected \(indexPath.row) and only \(loops.count) in Loops)")
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false //true
    }
    
    /* -- Was going to have this to swipe-to-mute a channel
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        self.selectedLoop = loops[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LoopCell
        
        let label = self.selectedLoop.muted == false ? "Mute" : "Unmute"
        let muteAction = UITableViewRowAction(style: .Default, title: label) { (action, indexPath) -> Void in
            let muted = self.loops[indexPath.row].muted!
            self.loops[indexPath.row].muted = !muted
            
            cell.mutedIndicator.text = muted ? String.ioniconWithName(.AndroidVolumeOff) : ""
            UserService.us.setMuteCourse(self.selectedLoop.uid, isMuted: muted)
            
            self.tableView.editing = false
        }
        muteAction.backgroundColor = SL_GREEN
        
        return [muteAction]
    }
    */
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: - Loop Logic
    
    func joinLoop() {
        let alert = UIAlertController(title: "Join Loop", message: "Do you want to join \(selectedLoop.subject)?", preferredStyle: .Alert)
        let join = UIAlertAction(title: "Join", style: .Default, handler: joinLoopHandler)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let preferredAction = join
        alert.addAction(preferredAction)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func joinLoopHandler(alert: UIAlertAction) -> Void {
        addUserToLoop()
    }
    
    func addUserToLoop() {
        let currentUser = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        DataService.ds.REF_LOOPS.childByAppendingPath(selectedLoop.uid).childByAppendingPath("userIds").childByAppendingPath(currentUser).setValue(true)
        UserService.us.REF_USER_CURRENT.childByAppendingPath("loopIds").childByAppendingPath(selectedLoop.uid).setValue(true)
        self.performSegueWithIdentifier(SEGUE_MESSAGES, sender: nil)
    }
    
    
    // MARK: - Button Actions
    
    @IBAction func didTapSettingsButton(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) != nil {
            performSegueWithIdentifier(SEGUE_COURSE_SETTINGS, sender: nil)
        }
    }
    
    @IBAction func didTapAddLoopButton(sender: AnyObject) {
        performSegueWithIdentifier(SEGUE_ADD_LOOP, sender: nil)
    }
    
    @IBAction func didTapOpenButton(sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            drawerController.setDrawerState(.Opened, animated: true)
        }
    }
    
    
    
    // MARK: - Segue Prep
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SEGUE_LOOP) {
            let loopVC = segue.destinationViewController as! LoopVC
            loopVC.loop = selectedLoop
        }
        
        if(segue.identifier == SEGUE_MESSAGES) {
            let messagesVC = segue.destinationViewController as! MessagesViewController
            messagesVC.loop = selectedLoop
            messagesVC.senderId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as! String
            messagesVC.senderDisplayName = UserService.us.currentUser.name
        }
    }
}
