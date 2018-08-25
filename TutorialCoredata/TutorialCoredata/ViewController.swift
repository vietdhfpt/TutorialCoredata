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
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var managedContext: NSManagedObjectContext!
    var currentDog: Dog?
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        
        let dogName = "Figo"
        let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
        dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName)
        
        do {
            let results = try self.managedContext.fetch(dogFetch)
            if results.count > 0 {
                // Figo found, use figo
                currentDog = results.first
            } else {
                // Figo not found, create figo
                currentDog = Dog(context: self.managedContext)
                currentDog?.name = dogName
                try self.managedContext.save()
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addWalk(_ sender: UIBarButtonItem) {
        // Insert a new Walk entity into Coredata
        let walk = Walk(context: self.managedContext)
        walk.date = Date()
        
        // Insert the new Walk into the Dog's walks set
        if let dog = currentDog, let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
            walks.add(walk)
            dog.walks = walks
        }
        
        // Save the managed object context
        do {
            try self.managedContext.save()
        } catch let error as NSError {
            print("Save error: \(error), description: \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let walks = self.currentDog?.walks else {
            return 1
        }
        return walks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let walk = self.currentDog?.walks?[indexPath.row] as? Walk,
            let walkDate = walk.date else {
            return cell
        }
        
        cell.textLabel?.text = self.dateFormatter.string(from: walkDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of walks"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let walkToRemove = self.currentDog?.walks?[indexPath.row] as? Walk else {
                return
            }
            
            managedContext.delete(walkToRemove)
            
            do {
                try managedContext.save()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch let error as NSError {
                print("Saving error: \(error), description: \(error.userInfo)")
            }
        default:
            break
        }
    }
}

