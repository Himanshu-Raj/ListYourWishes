//
//  MainVC.swift
//  ListYourWishes
//
//  Created by Chaudhary Himanshu Raj on 02/02/18.
//  Copyright © 2018 Chaudhary Himanshu Raj. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    // Telling what kind of data we will be working with, here <Item>
    var controller : NSFetchedResultsController<Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        // generateTestData()
        attemptFetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
// MARK: Confirming to Table View Protocol
extension MainVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func configureCell(cell: ItemCell, indexPath: NSIndexPath) {
        let item = controller.object(at: indexPath as IndexPath)
        cell.configureCell(item: item)
    }

}

    // This is a boiler plate stuff, so putting in an separate extension, so that it can be reused.
    extension MainVC : NSFetchedResultsControllerDelegate  {
    
        // This function will attempt to make a fetch request on persisted data.
        func attemptFetch() {
        
        //MARK: Steps for create a fetch request
        // Step-1 : We want to select Entity on which the fetch operation has to be performed, hence create a fetch Request. Here, Item is an entity in our .xcmdataodeled file.
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        // Step-2 : We want to specify the fetch criteria, i.e. based on what parmaeter, type entity has to be fetched. Here, Item entity has an attribute called "created" which will be our first search parameter.
        let dateSort = NSSortDescriptor(key: "created", ascending: false)
        
        // Step-3 : Now we pass in this parameter to fetchRequest, it accepts an array as there could be many search parameters.
        fetchRequest.sortDescriptors = [dateSort]
        
        // Step-4 : Now we want to instantiate our NSFetchedResultsController. It asks for following things to instantiate.
        //            a.) fetchRequest - created in step-1 to Step-3    b.)   managedObjectContext(the ScratchPad) : It should be created one per project, app because it's resource consuming[Refer to vary last comments in the app delegate.] hence, "context" from app delegate
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
            self.controller = controller
            
        // Step-5 : Now all the settings have been done to make a fetch request, hence we thus make an actual request in step-5. As it can throw error, hence we add a do try catch block to take care of that.
        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print("Error Description from catch block in performing a fetch request : \(error)")
        }
    }
    
    //MARK: Now we need to keep track on our database for any kind of insertions, deletions, updation. For this we have a method from NSFetchedRequestControllerDelegate, that listens for such changes.
    //****** To start above mentioned changes.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    //****** When done with the above mentioned changes.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
        // This method tracks what kind of change took place or being done. It has a variable, NSFetchedResultsChangeType
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            switch(type) {
                
            case.insert:
                if let indexPath = newIndexPath {
                    tableView.insertRows(at: [indexPath], with: .fade)
                }
                break
            case.delete:
                if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                break
            case.update:
                if let indexPath = indexPath {
                    let cell = tableView.cellForRow(at: indexPath) as! ItemCell
                    configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
                }
                break
            case.move:
                if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                if let indexPath = newIndexPath {
                    tableView.insertRows(at: [indexPath], with: .fade)
                }
                break
                
            }
        }
        
        
        func generateTestData() {
                let item = Item(context: context)
                item.title = "MacBook Pro"
                item.price = 1800
                item.details = "I just can't believe, i want to buy this piece of tech which i don't know why is so costly."
                
                let item2 = Item(context: context)
                item2.title = "Bose Headphones"
                item2.price = 300
                item2.details = "But man, its so nice to be able to block out everyone with the noise canceling tech. Again out of my Reach."
                
                let item3 = Item(context: context)
                item3.title = "Tesla Model S"
                item3.price = 110000
                item3.details = "This car is accident proof and can fly for maximum of 35 minutes. I can't afford to buy it even in my dreams."
                
                appDelegate.saveContext()
            }
}
