//
//  ViewController.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/24/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    var asyncFetchRequest: NSAsynchronousFetchRequest<Venue>!
    var fetchRequest: NSFetchRequest<Venue>!
    var venues: [Venue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Setup data
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setupData() {
        let batchUpdate = NSBatchUpdateRequest(entityName: "Venue")
        batchUpdate.propertiesToUpdate = [#keyPath(Venue.favorite) : true]
        batchUpdate.affectedStores = self.coreDataStack.managedContext.persistentStoreCoordinator?.persistentStores
        batchUpdate.resultType = .updatedObjectsCountResultType
        
        do {
            let batchResult = try self.coreDataStack.managedContext.execute(batchUpdate) as! NSBatchUpdateResult
            print("Records updated \(batchResult.result!)")
        } catch let error as NSError {
            print("Could not update \(error), \(error.userInfo)")
        }
        
        self.fetchRequest = Venue.fetchRequest()
        self.asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: self.fetchRequest, completionBlock: { [unowned self] (result: NSAsynchronousFetchResult) in
            guard let venues = result.finalResult else {
                return
            }
            
            self.venues = venues
            self.tableView.reloadData()
        })
        
        do {
            try self.coreDataStack.managedContext.execute(asyncFetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func fetchAndReload() {
        do {
            self.venues = try self.coreDataStack.managedContext.fetch(self.fetchRequest)
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        <#code#>
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let venue = self.venues[indexPath.row]
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
}

