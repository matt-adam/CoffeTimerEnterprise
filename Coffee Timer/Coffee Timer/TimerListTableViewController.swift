//
//  TimerListTableViewController.swift
//  Coffee Timer
//
//  Created by Ash Furrow on 2015-01-10.
//  Copyright (c) 2015 Ash Furrow. All rights reserved.
//

import UIKit
import CoreData

extension Array {
    mutating func moveFrom(_ source: Int, toDestination destination: Int) {
        let object = remove(at: source)
        insert(object, at: destination)
    }
}

class TimerListTableViewController: UITableViewController {

    var userReorderingCells = false
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TimerModel")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "displayOrder", ascending: true)
        ]

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate().coreDataStack.managedObjectContext, sectionNameKeyPath: "type", cacheName: nil)
        controller.delegate = self
        return controller
    }()

    enum TableSection: Int {
        case coffee = 0
        case tea
        case numberOfSections
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching: \(error)")
        }

        navigationItem.leftBarButtonItem = editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if presentedViewController != nil {
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section]

        return sectionInfo?.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let timerModel = timerModelForIndexPath(indexPath)
        cell.textLabel?.text = timerModel.name

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == TableSection.coffee.rawValue {
            return NSLocalizedString("Coffees", comment: "Coffee section title")
        } else { // Must be TableSection.Tea
            return NSLocalizedString("Teas", comment: "Tea section title")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }

        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "editDetail", sender: cell)
    }

    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return true
        }

        return false
    }

    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any!) {
        let timerModel = timerModelForIndexPath(indexPath)
        let pasteboard = UIPasteboard.general
        pasteboard.string = timerModel.name
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        userReorderingCells = true

        // Grab the section and the TimerModels in the section
        let sectionInfo = fetchedResultsController.sections?[sourceIndexPath.section]
        var objectsInSection = sectionInfo?.objects ?? []

        // Rearrange the order to match the user's actions
        // Note: this doesn't move anything in Core Data, just our objectsInSection array
        objectsInSection.moveFrom(sourceIndexPath.row, toDestination: destinationIndexPath.row)

        // The models are now in the correct order.
        // Update their displayOrder to match the new order.
        for i in 0..<objectsInSection.count {
            let model = objectsInSection[i] as? TimerModel
            model?.displayOrder = Int32(i)
        }

        userReorderingCells = false
        appDelegate().coreDataStack.save()
    }

    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // If the source and destination index paths are the same section,
        // then return the proposed index path
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        }

        // The sections are different, which we want to disallow.
        if sourceIndexPath.section == TableSection.coffee.rawValue {
            // This is coming from the coffee section, so return
            // the last index path in that section.

            let sectionInfo = fetchedResultsController.sections?[TableSection.coffee.rawValue]

            let numberOfCoffeTimers = sectionInfo?.numberOfObjects ?? 0

            return IndexPath(item: numberOfCoffeTimers - 1, section: 0)
        } else { // Must be TableSection.Tea
            // This is coming from the tea section, so return
            // the first index path in that section.

            return IndexPath(item: 0, section: 1)
        }
    }

    // MARK: - Utility methods

    func timerModelForIndexPath(_ indexPath: IndexPath) -> TimerModel {
        return fetchedResultsController.object(at: indexPath) as! TimerModel
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)!

            let timerModel = timerModelForIndexPath(indexPath)

            if segue.identifier == "pushDetail" {
                let detailViewController = segue.destination as! TimerDetailViewController
                detailViewController.timerModel = timerModel
            } else if segue.identifier == "editDetail" {
                let navigationController = segue.destination as! UINavigationController
                let editViewController = navigationController.topViewController as! TimerEditViewController

                editViewController.timerModel = timerModel
                editViewController.delegate = self
            }
        } else if let _ = sender as? UIBarButtonItem {
            if segue.identifier == "newTimer" {
                let navigationController = segue.destination as! UINavigationController
                let editViewController = navigationController.topViewController as! TimerEditViewController

                editViewController.creatingNewTimer = true

                editViewController.timerModel = NSEntityDescription.insertNewObject(forEntityName: "TimerModel", into: appDelegate().coreDataStack.managedObjectContext) as! TimerModel
                editViewController.delegate = self
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "pushDetail" {
            if tableView.isEditing {
                return false
            }
        }

        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let timer = timerModelForIndexPath(indexPath)
            timer.managedObjectContext?.delete(timer)
        }
    }
}

extension TimerListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        guard userReorderingCells == false else { return }

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        guard userReorderingCells == false else { return }

        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default: break
        }
    }
}

extension TimerListTableViewController: TimerEditViewControllerDelegate {
    func timerEditViewControllerDidCancel(_ viewController: TimerEditViewController) {
        if viewController.creatingNewTimer {
            appDelegate().coreDataStack.managedObjectContext.delete(viewController.timerModel)
        }
    }

    func timerEditViewControllerDidSave(_ viewController: TimerEditViewController) {
        appDelegate().coreDataStack.save()
    }
}
