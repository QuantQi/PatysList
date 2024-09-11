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

    func fetchTempItems() -> [ItemType] {
        let fetchRequest: NSFetchRequest<TempItem> = TempItem.fetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            var newItem:[ItemType] = []
            
            for i in items {
                newItem.append(ItemType(id:i.id!, timestamp: i.timestamp!, name: i.name!, quantity: String(i.quantity), checked: i.checked, indexVal: Int(i.indexVal)))
            }
            
            return newItem
            
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
        
    }
    
    func fetchItems() -> [ItemType] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            var newItem:[ItemType] = []
            
            for i in items {
                newItem.append(ItemType(id:i.id!, timestamp: i.timestamp!, name: i.name!, quantity: String(i.quantity), checked: i.checked, indexVal:newItem.count))
            }
            
            return newItem
            
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }
    
    func fetchPurchaseHistory() -> [ItemType] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        do {
            let items = try context.fetch(fetchRequest)
            var newItems: [ItemType] = []

            for i in items {
                var itemExists = false

                // Manually loop through newItems to find if an item with the same name exists
                for j in 0..<newItems.count {
                    if newItems[j].name == i.name {
                        // If the item exists, update its quantity by summing the old and new quantities
                        let existingItem = newItems[j]
                        let updatedQuantity = String((Int(existingItem.quantity) ?? 0) + Int(i.quantity))
                        newItems[j].quantity = updatedQuantity
                        itemExists = true
                        break // Exit the loop once the item is found and updated
                    }
                }

                // If the item doesn't exist, append it to newItems
                if !itemExists {
                    let newItem = ItemType(
                        id: i.id!,
                        timestamp: i.timestamp!,
                        name: i.name!,
                        quantity: String(i.quantity),
                        checked: i.checked,
                        indexVal: newItems.count
                    )
                    newItems.append(newItem)
                }
            }

            return newItems

        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }


    func saveItems(items: [ItemType]) {
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
  
    func saveItem(item:ItemType) {
        let newItem = shoppintItemToItem(item: item)
        do {
            try context.save()
            //print("\(String(describing: newItem.name)) saved")
        } catch {
            print("Failed to save item: \(error)")
        }
    }


    func saveTempItem(i: ItemType) {
            let newItem = shoppintItemToTempItem(item: i)
            
            do {
                try context.save()
               // print("\(String(describing: newItem.name)) saved to TempItem")
            } catch {
                print("Failed to save TempItem: \(error)")
            }
        
    }
 
    func deleteItemsWithName(as name: String) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        do {
            let items = try context.fetch(fetchRequest)  // Fetch all items with the same name
            for i in items {
                context.delete(i)
                try context.save()
            }
        } catch {
            print("Error fetching items with name \(name): \(error)")
        }
    }

    
    func deleteItem(item: ItemType) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)

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
    
    func deleteTempItem(i: ItemType) {
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

    func updateTempItem(item: ItemType) {
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
    
    
    func shoppintItemToTempItem(item: ItemType)-> TempItem {
        let newItem = TempItem(context: context)
        newItem.name = item.name
        newItem.quantity = Int32(item.quantity) ?? 1
        newItem.checked = item.checked
        newItem.id = item.id
        newItem.timestamp = item.timestamp
        
        return newItem
    }
    
    func shoppintItemToItem(item: ItemType)-> Item {
        let newItem = Item(context: context)
        newItem.name = item.name
        newItem.quantity = Int32(item.quantity) ?? 1
        newItem.checked = item.checked
        newItem.id = item.id
        newItem.timestamp = item.timestamp
        
        return newItem
    }
}
