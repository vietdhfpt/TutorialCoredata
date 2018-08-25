//
//  ViewController.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/24/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//

import UIKit
import CoreData

private extension UIColor {
    static func color(dict: [String: AnyObject]) -> UIColor? {
        guard let red = dict["red"] as? NSNumber,
            let green = dict["green"] as? NSNumber,
            let blue = dict["blue"] as? NSNumber else {
                return nil
        }
        
        return UIColor(red: CGFloat(truncating: red) / 255.0,
                       green: CGFloat(truncating: green) / 255.0,
                       blue: CGFloat(truncating: blue) / 255.0,
                       alpha: 1)
    }
}


class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    let shared = CoredataManaged.shared
    
    var currentBowtie: Bowtie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertSampleData()
        self.firstTime()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func firstTime() {
        let managedContext = self.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Bowtie>(entityName: "Bowtie")
        if let firstTitle = self.segmented.titleForSegment(at: 0) {
            fetchRequest.predicate = NSPredicate(format: "searchKey = %@", firstTitle)
        }
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            currentBowtie = result.first
            self.populate(result.first)
        } catch let error {
            print("Could not fetch \(error)")
        }
    }
    
    func populate(_ bowtie: Bowtie?) {
        guard let bowtie = bowtie else {
            return
        }
        guard let imageData = bowtie.photoData,
            let lastWorn = bowtie.lastWorn,
            let tinColor = bowtie.tinColor as? UIColor else {
            return
        }
        
        self.imageView.image = UIImage(data: imageData)
        self.nameLabel.text = bowtie.name
        self.ratingLabel.text = "Rating: \(bowtie.rating)/5"
        self.timesWornLabel.text = "Times worn: \(bowtie.timesWorn)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        self.lastWornLabel.text = "Last worn: " + dateFormatter.string(from: lastWorn)
        self.favoriteLabel.isHidden = !bowtie.isFavorite
        view.tintColor = tinColor
    }
    
    func update(rating: String?) {
        let managedContext = self.shared.persistentContainer.viewContext
        guard let ratingString = rating,
            let rating = Double(ratingString) else {
                return
        }
        
        do {
            self.currentBowtie.rating = rating
            try managedContext.save()
            populate(self.currentBowtie)
        } catch let error as NSError {
            
            if error.domain == NSCocoaErrorDomain &&
                (error.code == NSValidationNumberTooLargeError ||
                    error.code == NSValidationNumberTooSmallError) {
                self.pressRate(currentBowtie)
            } else {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func insertSampleData() {
        let managedContext = self.shared.persistentContainer.viewContext
        let fetch = NSFetchRequest<Bowtie>(entityName: "Bowtie")
        fetch.predicate = NSPredicate(format: "searchKey != nil")
        
        let count = try! managedContext.count(for: fetch)
        
        if count > 0 {
            // SampleData.plist data already in Core Data
            return
        }
        
        let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Bowtie",
                                                    in: managedContext)!
            let bowtie = Bowtie(entity: entity, insertInto: managedContext)
            let btDict = dict as! [String: AnyObject]
            
            bowtie.name = btDict["name"] as? String
            bowtie.searchKey = btDict["searchKey"] as? String
            bowtie.rating = btDict["rating"] as! Double
            
            let colorDict = btDict["tintColor"] as! [String: AnyObject]
            bowtie.tinColor = UIColor.color(dict: colorDict)
            
            let imageName = btDict["imageName"] as? String
            let image = UIImage(named: imageName!)
            let photoData = UIImagePNGRepresentation(image!)!
            bowtie.photoData = photoData
            
            bowtie.lastWorn = btDict["lastWorn"] as? Date
            let timesNumber = btDict["timesWorn"] as! NSNumber
            bowtie.timesWorn = timesNumber.int32Value
            bowtie.isFavorite = btDict["isFavorite"] as! Bool
        }
        
        try! managedContext.save()
    }

    // MARK: - Action
    @IBAction func segmentDidChanged(_ sender: UISegmentedControl) {
        let managedContext = self.shared.persistentContainer.viewContext
    
        let selectedValue = sender.titleForSegment(at: sender.selectedSegmentIndex)
        let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
        request.predicate = NSPredicate(format: "searchKey == %@", selectedValue!)
        
        do {
            let results =  try managedContext.fetch(request)
            currentBowtie =  results.first
            populate(currentBowtie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func pressWear(_ sender: AnyObject) {
        let managedContext = self.shared.persistentContainer.viewContext
        
        let times = currentBowtie.timesWorn
        currentBowtie.timesWorn = times + 1
        
        currentBowtie.lastWorn = Date()
        
        do {
            try managedContext.save()
            populate(currentBowtie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func pressRate(_ sender: AnyObject) {
        let alert = UIAlertController(title: "New Rating",
                                      message: "Rate this bow tie",
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first else {
                return
            }
            
            self.update(rating: textField.text)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
}

