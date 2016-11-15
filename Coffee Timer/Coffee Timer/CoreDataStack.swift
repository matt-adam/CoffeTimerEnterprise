//
//  AppDelegate+CoreData.swift
//  Coffee Timer
//
//  Created by Ash Furrow on 2015-06-06.
//  Copyright (c) 2015 Ash Furrow. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext()
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let storeURL = self.applicationDocumentsDirectory().appendingPathComponent("CoffeeTimer.sqlite")

        let errorPointer: NSErrorPointer = nil

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            print("Unresolved error adding persistent store: \(error)")
        }

        return coordinator
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "CoffeeTimer", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    func loadDefaultDataIfFirstLaunch() {
        let key = "hasLaunchedBefore"
        let launchedBefore = UserDefaults.standard.bool(forKey: key)

        defer {
            save()
        }

        if launchedBefore == false {
            UserDefaults.standard.set(true, forKey: key)

            for i in 0..<5 {
                let model = NSEntityDescription.insertNewObject(forEntityName: "TimerModel", into: managedObjectContext) as! TimerModel

                switch i {
                case 0:
                    model.name = NSLocalizedString("Colombian", comment: "Columbian coffee name")
                    model.duration = 240
                    model.type = .coffee
                case 1:
                    model.name = NSLocalizedString("Mexican", comment: "Mexian coffee name")
                    model.duration = 200
                    model.type = .coffee
                case 2:
                    model.name = NSLocalizedString("Green Tea", comment: "Green tea name")
                    model.duration = 400
                    model.type = .tea
                case 3:
                    model.name = NSLocalizedString("Oolong", comment: "Oolong tea name")
                    model.duration = 400
                    model.type = .tea
                default: // case 4:
                    model.name = NSLocalizedString("Rooibos", comment: "Rooibos tea name")
                    model.duration = 480
                    model.type = .tea
                }

                model.displayOrder = Int32(i)
            }
        }
    }

    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    fileprivate func applicationDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
    }
}
