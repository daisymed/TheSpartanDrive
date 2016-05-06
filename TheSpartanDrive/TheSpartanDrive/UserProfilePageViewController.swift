//
//  UserProfilePageViewController.swift
//  TheSpartanDrive
//
//  Created by Manbir Randhawa on 5/5/16.
//  Copyright © 2016 CMPE137Group5. All rights reserved.
//

import Foundation
import UIKit
import Parse

class UserProfilePageViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet weak var commentBoxText: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePageUsernameField: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var hostuser = PFUser()
    
    var commentss = [PFObject]()
    
    
    @IBAction func postACommentButton(sender: AnyObject) {
        
        let sharedPref = NSUserDefaults.standardUserDefaults()
        let userYouAreVisiting = sharedPref.valueForKey("VisitingUserProfile")
        
         var newComment = PFObject(className:"ProfileComments")
        newComment["UserProfile"] = hostuser
        newComment["PosterOfUserComment"] = PFUser.currentUser()!
        newComment["Comment"] = commentBoxText.text
        newComment.saveInBackgroundWithBlock { (true:Bool, error:NSError?) in
            if (true)
            {
                let successAlert = UIAlertView(title: "Post successful!", message: "Comment successful!", delegate: self, cancelButtonTitle: "OK")
                successAlert.show()
                self.commentBoxText.text = "Post.."
                self.queryForComments(self.hostuser)
                
            } else {
                let errorAlert = UIAlertView(title: "Cannot Post Comment", message: "Try again!", delegate: self, cancelButtonTitle: "OK")
                errorAlert.show()
            }
        }
        
        
    }
    
    
    
    
    @IBAction func backButton(sender: AnyObject) {
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        
        performSegueWithIdentifier("goBackSegue", sender: self)
        
    }
    
    var commentsArray = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
 
      
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let sharedPref = NSUserDefaults.standardUserDefaults()
       let userYouAreVisiting = sharedPref.valueForKey("VisitingUserProfile")
       print(userYouAreVisiting!)
       queryProfilePicture(userYouAreVisiting as! String)
      queryUserPage(userYouAreVisiting as! String)
       
        
    }
    
    func queryUserPage(userobject:String)
    {
        var query = PFUser.query()
        query?.whereKey("objectId", equalTo: userobject)
        query?.findObjectsInBackgroundWithBlock({ (object:[PFObject]?, error:NSError?) in
            if error == nil {
                self.hostuser = object![0] as! PFUser
                self.profilePageUsernameField.text = ("\(self.hostuser.username!)'s Profile")
                 self.queryForComments(self.hostuser)
                
            } else {
                
            }
        })
       
       
    }
    
    func queryForComments(host:PFUser) -> [PFObject]
    {
        print(host)
        print("PRINTED I QUERY FOR COMMENTS")
        commentss = [PFObject]()
        
        var query = PFQuery(className: "ProfileComments")
        print("Step1")
        query.whereKey("UserProfile", equalTo: host)
        print("Step2")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (comments:[PFObject]?, error:NSError?) in
            if (error == nil)
            {
                print("SUCEZZZZZ")
                if let commentsz = comments{
                    for comment in commentsz {
                        print("Step3")
                        self.commentss.append(comment)
                        
                    }
                    self.tableView.reloadData()
                    
                }
                print(self.commentss.count)
                
            } else {
                print("error getting comments")
            }
        }
        

        return commentss
        
    }
    
  
    
    func queryProfilePicture(userObject: String)
    {
       
            var userQuery = PFUser.query()
            userQuery!.whereKey("objectId", equalTo: userObject)
            userQuery!.findObjectsInBackgroundWithBlock {
                (object:[PFObject]?, error:NSError?) in
                
                if error == nil {
                    
                    
                    if let imagedisplay = object?[0]["profilePicture"] as? PFFile
                    {
                        imagedisplay.getDataInBackgroundWithBlock { (result, error) in
                            if (error == nil)
                            {
                                print("PROFILE IMAGE AVAILABLE")
                                self.profileImageView.contentMode = .ScaleAspectFit
                                self.profileImageView.image = UIImage(data: result!)
                                
                                
                            }else {
                                print("NO profile IMAGE")
                                self.profileImageView.backgroundColor = UIColor.brownColor()
                            }
                        }
                    }
                    
                    
                    
                }
                else {
                    print("Error")
                }
                
            }
            
        }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentss.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! CustomBrowsePicCell
        
       cell.commentLabelBoxProfile.text = commentss[indexPath.row]["Comment"] as! String
        
        var userWhoPosted = commentss[indexPath.row]["PosterOfUserComment"] as! PFUser
        userWhoPosted.fetchIfNeededInBackgroundWithBlock { (object:PFObject?, error:NSError?) in
              cell.usernameProfileButton.setTitle(userWhoPosted.username!, forState: UIControlState.Normal)
        }
        
        
        
        return cell
        
    }
        
        
    }

    
    
    

