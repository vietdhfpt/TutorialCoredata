//
//  FilterViewController.swift
//  TutorialCoredata
//
//  Created by Do Hoang Viet on 8/26/18.
//  Copyright © 2018 Do Hoang Viet. All rights reserved.
//

import UIKit
import CoreData

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
    
}

class FilterViewController: UITableViewController {

    @IBOutlet weak var firstPriceCategoryLabel: UILabel!
    @IBOutlet weak var secondPriceCategoryLabel: UILabel!
    @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
    @IBOutlet weak var numDealsLabel: UILabel!
    
    // MARK: - Price section
    @IBOutlet weak var cheapVenueCell: UITableViewCell!
    @IBOutlet weak var moderateVenueCell: UITableViewCell!
    @IBOutlet weak var expensiveVenueCell: UITableViewCell!
    
    // MARK: - Most popular section
    @IBOutlet weak var offeringDealCell: UITableViewCell!
    @IBOutlet weak var walkingDistanceCell: UITableViewCell!
    @IBOutlet weak var userTipsCell: UITableViewCell!
    
    // MARK: - Sort section
    @IBOutlet weak var nameAZSortCell: UITableViewCell!
    @IBOutlet weak var nameZASortCell: UITableViewCell!
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    @IBOutlet weak var priceSortCell: UITableViewCell!
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    weak var delegate: FilterViewControllerDelegate?
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?
    
    lazy var cheapVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$")
    }()
    
    lazy var moderateVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$")
    }()
    
    lazy var expensiveVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
    }()
    
    lazy var offeringDealPredicate: NSPredicate = {
        return NSPredicate(format: "%K > 0", #keyPath(Venue.specialCount))
    }()
    
    lazy var walkingDistancePredicate: NSPredicate = {
        return NSPredicate(format: "%K < 500", #keyPath(Venue.location.distance))
    }()
    
    lazy var hasUserTipsPredicate: NSPredicate = {
        return NSPredicate(format: "%K > 0", #keyPath(Venue.stats.tipCount))
    }()
    
    lazy var nameSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Venue.name),
                                ascending: true,
                                selector: compareSelector)
    }()
    
    lazy var distanceSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Venue.location.distance),
                                ascending: true)
    }()
    
    lazy var priceSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Venue.priceInfo.priceCategory),
                                ascending: true)
    }()

    // MARK: - Life cycles.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateCheapVenueCountLabel()
        self.populateModerateVenueCountLabel()
        self.populateExpensiveVenueCountLabel()
        self.populateDealsCountLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func pressSearch(_ sender: UIBarButtonItem) {
        self.passedData()
    }
    
    func passedData() {
        self.delegate?.filterViewController(filter: self, didSelectPredicate: self.selectedPredicate, sortDescriptor: self.selectedSortDescriptor)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper.
    func populateCheapVenueCountLabel() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = cheapVenuePredicate
        
        do {
            let countResult = try self.coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            
            firstPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
    func populateModerateVenueCountLabel() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = moderateVenuePredicate
        
        do {
            let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            secondPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
    func populateExpensiveVenueCountLabel() {
        let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
        fetchRequest.predicate = expensiveVenuePredicate
        do {
            let count = try coreDataStack.managedContext.count(for: fetchRequest)
            thirdPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
    func populateDealsCountLabel() {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
        fetchRequest.resultType = .dictionaryResultType
        
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumDeals"
        
        let specialCountExp = NSExpression(forKeyPath: #keyPath(Venue.specialCount))
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExp])
        sumExpressionDesc.expressionResultType = .integer32AttributeType
        
        fetchRequest.propertiesToFetch = [sumExpressionDesc]
        
        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            let resultDict = results.first!
            let numDeals = resultDict["sumDeals"]!
            numDealsLabel.text = "\(numDeals) total deals"
            
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
}

// MARK: - UITableViewDelegate
extension FilterViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellType = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        switch cellType {
        // Price section
        case cheapVenueCell:
            selectedPredicate = cheapVenuePredicate
        case moderateVenueCell:
            selectedPredicate = moderateVenuePredicate
        case expensiveVenueCell:
            selectedPredicate = expensiveVenuePredicate
            
        // Most Popular section
        case offeringDealCell:
            selectedPredicate = offeringDealPredicate
        case walkingDistanceCell:
            selectedPredicate = walkingDistancePredicate
        case userTipsCell:
            selectedPredicate = hasUserTipsPredicate
            
        // Sort By section
        case nameAZSortCell:
            selectedSortDescriptor = nameSortDescriptor
        case nameZASortCell:
            selectedSortDescriptor = nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
        case distanceSortCell:
            selectedSortDescriptor = distanceSortDescriptor
        case priceSortCell:
            selectedSortDescriptor = priceSortDescriptor
            
        default:
            break
        }
        
        cellType.accessoryType = .checkmark
        self.passedData()
    }
}
