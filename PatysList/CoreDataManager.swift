//
//  CoreDataManager.swift
//  PatysList
//
//  Created by So C on 10/09/2024.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PatysList")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func fetchTempItems() -> [item] {
        let fetchRequest: NSFetchRequest<TempItem> = TempItem.fetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            var newItem:[item] = []
            
            for i in items {
                newItem.append(item(id:i.id!, timestamp: i.timestamp!, name: i.name!, quantity: String(i.quantity), checked: i.checked, indexVal: Int(i.indexVal)))
            }
            
            return newItem
            
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
        
    }
    
    func fetchItems() -> [item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            var newItem:[item] = []
            
            for i in items {
                newItem.append(item(id:i.id!, timestamp: i.timestamp!, name: i.name!, quantity: String(i.quantity), checked: i.checked, indexVal:newItem.count))
            }
            
            return newItem
            
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }
    
    func fetchPurchaseHistory()-> [item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            var newItems:[item] = []
            
            for i in items {
                 for n in newItems {
                        if n.name == i.name {
                            var qyt = String(Int(n.quantity)! + Int(i.quantity))
                            //qyt = String(Int(n.quantity)! + Int(i.quantity))
                            n.quantity = qyt
                        }else{
                            newItems.append(item(id:i.id!, timestamp: i.timestamp!, name: i.name!, quantity: String(i.quantity), checked: i.checked, indexVal:newItems.count))
                        }
                    }
            }
            
            return newItem
            
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }

    func saveItems(items: [item]) {
        for item in items {
            _ = shoppintItemToItem(item: item)
            do {
                try context.save()
               // print("\(newItem.name) saved")
            } catch {
                print("Failed to save item: \(error)")
            }
        }
    }
  
    func saveItem(item:item) {
        let newItem = shoppintItemToItem(item: item)
        do {
            try context.save()
            print("\(String(describing: newItem.name)) saved")
        } catch {
            print("Failed to save item: \(error)")
        }
    }


    func saveTempItem(i: item) {
            let newItem = shoppintItemToTempItem(item: i)
            
            do {
                try context.save()
                print("\(String(describing: newItem.name)) saved to TempItem")
            } catch {
                print("Failed to save TempItem: \(error)")
            }
        
    }
    func deleteItemsWithName(as: item){
        
    }
    
    func deleteItem(i: item) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", i.id as CVarArg)

        do {
            let items = try context.fetch(fetchRequest)
            if let item = items.first {
                context.delete(item)
                try context.save()
            }
        } catch {
            print("Error deleting item: \(error)")
        }
    }
    
    func deleteTempItem(i: item) {
        let fetchRequest: NSFetchRequest<TempItem> = TempItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", i.id as CVarArg)

        do {
            let items = try context.fetch(fetchRequest)
            if let item = items.first {
                context.delete(item)
                try context.save()
            }
        } catch {
            print("Error deleting item: \(error)")
        }
    }

    func updateTempItem(item: item) {
        let fetchRequest: NSFetchRequest<TempItem> = TempItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
            let items = try context.fetch(fetchRequest)
            
            if let tempItem = items.first {
                tempItem.name = item.name
                tempItem.quantity = Int32(item.quantity) ?? 1
                tempItem.indexVal = Int16(item.indexVal)
                tempItem.checked = item.checked
                tempItem.timestamp = item.timestamp
                
                do {
                    try context.save()
                } catch {
                    print("Failed to update TempItem: \(error)")
                }
            }
        } catch {
            print("Failed to fetch temp item: \(error)")
        }
    }
    
    
    func shoppintItemToTempItem(item: item)-> TempItem {
        let newItem = TempItem(context: context)
        newItem.name = item.name
        newItem.quantity = Int32(item.quantity) ?? 1
        newItem.checked = item.checked
        newItem.id = item.id
        newItem.timestamp = item.timestamp
        
        return newItem
    }
    
    func shoppintItemToItem(item: item)-> Item {
        let newItem = Item(context: context)
        newItem.name = item.name
        newItem.quantity = Int32(item.quantity) ?? 1
        newItem.checked = item.checked
        newItem.id = item.id
        newItem.timestamp = item.timestamp
        
        return newItem
    }
}
