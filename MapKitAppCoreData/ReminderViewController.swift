//
//  ReminderViewController.swift
//  MapKitAppCoreData
//
//  Created by Jeff Gayle on 8/20/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

import UIKit
import CoreData

class ReminderViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    var fetchedResultsController : NSFetchedResultsController!
    var myContext : NSManagedObjectContext!
    
    @IBOutlet weak var tableView : UITableView!
    
    var indexPath : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Core Data
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.myContext = appDelegate.managedObjectContext
        
        //Setup Fetched Results Controller
        var request = NSFetchRequest(entityName: "Reminder")
        let sort = NSSortDescriptor(key: "message", ascending: true)
        
        //Add sort to request
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        //Initialize Fetched Results Controller
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.myContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        //perform fetch on appearance
        var error : NSError?
        self.fetchedResultsController.performFetch(&error)
        if error != nil {
            println(error?.localizedDescription)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: UITableView Methods
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("reminderCell", forIndexPath: indexPath) as ReminderTableViewCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: ReminderTableViewCell, forIndexPath indexPath: NSIndexPath) {
        var reminder = self.fetchedResultsController.fetchedObjects[indexPath.row] as Reminder
        var nf = NSNumberFormatter()
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        
        cell.messageLabel.adjustsFontSizeToFitWidth = true
        
        cell.messageLabel.text = reminder.message
        cell.latLabel.text = nf.stringFromNumber(reminder.lat)
        cell.longLabel.text = nf.stringFromNumber(reminder.long)
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections[section].numberOfObjects
    }
    
    //MARK: Tableview options (Delete/More)
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        //Just to make it work
    }
    
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            if let reminderForRow = self.fetchedResultsController.fetchedObjects[indexPath.row] as? Reminder {
                self.myContext.deleteObject(reminderForRow)
                self.myContext.save(nil)
            }
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            if let reminderForRow = self.fetchedResultsController.fetchedObjects[indexPath.row] as? Reminder {
                self.indexPath = indexPath
                self.performSegueWithIdentifier("editReminder", sender: self)
            }
            
        }
        
        deleteAction.backgroundColor = UIColor.redColor()
        editAction.backgroundColor = UIColor.grayColor()
        
        return [deleteAction, editAction]
    }
    
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "editReminder" {
            let editVC = segue.destinationViewController as EditReminderViewController
            var reminder = self.fetchedResultsController.fetchedObjects[self.indexPath!.row] as Reminder
            editVC.reminder = reminder
            self.tableView.deselectRowAtIndexPath(self.indexPath!, animated: true)
        }
    }

    
    //MARK: Fetched Results Controller Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController!) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
        
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Update:
//            self.configureCell(self.cellForRowAtIndexPath(indexPath), forIndexPath: indexPath)
            var cell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath) as ReminderTableViewCell
            self.configureCell(cell, forIndexPath: indexPath)
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
