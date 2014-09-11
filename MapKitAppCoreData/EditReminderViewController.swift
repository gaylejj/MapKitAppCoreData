//
//  EditReminderViewController.swift
//  MapKitAppCoreData
//
//  Created by Jeff Gayle on 8/20/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import CoreData

class EditReminderViewController: UIViewController {

    @IBOutlet weak var messageTextField: UITextField!
    var reminder : Reminder!
    
    var myContext : NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.myContext = appDelegate.managedObjectContext
        
        self.messageTextField.text = self.reminder.message

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveReminderPressed(sender: AnyObject) {
        
        reminder.message = self.messageTextField.text
        reminder.managedObjectContext.save(nil)
        self.navigationController!.popViewControllerAnimated(true)
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
