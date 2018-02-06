//
//  CoreDataStack.swift
//  Test_app
//
//  Created by Dhaval Bhadania on 31/01/18.
//  Copyright © 2018 Dhaval Bhadania. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack {
    
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("path is :%@ ",urls)
        return urls[urls.count-1] as NSURL
    }()
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Product")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    func saveContext() {
        
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error as NSError {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    print("Ops there was an error \(error.localizedDescription)")
                    abort()
                }
            }
        }
    }
    
    //==============================
    lazy var managedObjectModel: NSManagedObjectModel = {
        // 1
        let modelURL = Bundle.main.url(forResource: "Product", withExtension: "mom")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Product.sqlite")
        do {
            // If your looking for any kind of migration then here is the time to pass it to the options
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let  error as NSError {
            print("Ops there was an error \(error.localizedDescription)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the
        // application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to
        //   fail.
        let coordinator = self.persistentStoreCoordinator
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    
    
    //fetch message From Coredata file
    func getList() -> [[String: Any]]  {
        var resultArray = [[String: Any]]()
        
        if #available(iOS 10.0, *) {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
            do{
                if let result = try self.persistentContainer.viewContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as? [Product] {
                    for res in result {
                        let result: [String: Any] = [
                            "brand": res.brand! as String ,
                            "created_at": res.created_at! as String,
                            "productid": res.productid ?? "" ,
                            "quantity": res.quantity! as String,
                            "price": res.price! as String ,
                            "name": res.name! as String ,
                            "sku": res.sku! as String ,
                            "updated_at": res.updated_at! as String
                        ]
                        
                        resultArray.append(result)
                    }
                    return resultArray
                }
            } catch {
                fatalError("Error Fetching Data")
            }
            
        } else {
            
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
           
            
            do{
                if let result = try self.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as? [Product] {
                    for res in result {
                        let result: [String: Any] = [
                            "brand": res.brand! as String ,
                            "created_at": res.created_at! as String,
                            "productid": res.productid ?? "" ,
                            "quantity": res.quantity! as String,
                            "price": res.price! as String ,
                            "name": res.name! as String ,
                            "sku": res.sku! as String ,
                            "updated_at": res.updated_at! as String,
                        ]
                        resultArray.append(result)
                    }
                    return resultArray
                }
            } catch {
                fatalError("Error Fetching Data")
            }
        }
        
        return resultArray
}
    
func getListCount() -> Int {
        
        if #available(iOS 10.0, *) {
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
        
            
            do{
                if let result = try self.persistentContainer.viewContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as? [Product] {
                    
                    return result.count
                }
            } catch {
                fatalError("Error Fetching Data")
            }
            
        } else {
            
            let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
         
            
            do{
                if let result = try self.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as? [Product] {
                    
                    return result.count
                }
            } catch {
                fatalError("Error Fetching Data")
            }
        }
        
        return 0
    }

}
