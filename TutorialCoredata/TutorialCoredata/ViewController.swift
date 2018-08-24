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
    
    let shared = CoredataManaged.shared
    
    var persons: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func saveData(name: String) {
        let managedContext = self.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)
        guard let entities = entity else {
            return
        }
        let person = NSManagedObject(entity: entities, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            self.persons.append(person)
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func fetchData() {
        let managedContext = self.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        do {
            self.persons = try managedContext.fetch(fetchRequest)
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func deleteData(at indexPath: IndexPath) {
        guard indexPath.row < persons.count else {
            return
        }
        
        let managedContext = self.shared.persistentContainer.viewContext
        managedContext.delete(persons[indexPath.row])
        
        do {
            try managedContext.save()
        } catch let err {
            print("Error: \(err)")
        }
        
        self.fetchData()
        self.tableView.reloadData()
    }
    
    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Person", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] (action) in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            self.saveData(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = persons[indexPath.row].value(forKeyPath: "name") as? String
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.deleteData(at: indexPath)
        default:
            break
        }
    }
}

