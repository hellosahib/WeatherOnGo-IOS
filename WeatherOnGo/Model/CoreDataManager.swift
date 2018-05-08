//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Copyright © 2018 Aryan. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager{
    let persistentContainer : NSPersistentContainer
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName : String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func loadPersistentContainer(completitionHandler : (() -> Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                print((error?.localizedDescription)!)
                return
            }
            completitionHandler?()
        }
    }
}
