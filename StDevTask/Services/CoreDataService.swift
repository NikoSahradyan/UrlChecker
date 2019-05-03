//
//  CoreDataService.swift
//  StDevTask
//
//  Created by Developer on 03/05/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit
import CoreData

class CoreDataService: NSObject {
    
    static var shared = CoreDataService()
    
    lazy var workingContext = {
        return self.persistentContainer.viewContext
    } ()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StDevTask")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        if workingContext.hasChanges {
            do {
                try workingContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addNewUrl(cellModel: URLCellModel) {
        let newUrl = URLEntity(context: workingContext)
        newUrl.url = cellModel.url.absoluteString
        switch cellModel.state {
        case .loading:
            newUrl.availableTime = 0
            newUrl.state = "loading"
        case .available(let duration):
            newUrl.availableTime = duration
            newUrl.state = "available"
        case .unavailable:
            newUrl.availableTime = 0
            newUrl.state = "unavailable"
        }
        saveContext()
    }
    
    func removeUrl(cellModel: URLCellModel) {
        let temp = self.currentUrlEnitites()
            .filter{ $0.url == cellModel.url.absoluteString }
        guard let item = temp.first else {
            return
        }
        workingContext.delete(item)
        saveContext()
    }
    
    func changeStateForCurrentItem(cellModel: URLCellModel) {
        let request = NSFetchRequest<URLEntity>(entityName: "URLEntity")
        request.predicate = NSPredicate(format: "url == %@", cellModel.url.absoluteString)
        request.returnsObjectsAsFaults = false
        guard let items = try? workingContext.fetch(request),
            items.count != 0 else {
            return
        }
        var stateString = ""
        var availableTime = 0.0
        switch cellModel.state {
        case .loading:
            stateString = "loading"
        case .available(let duration):
            availableTime = duration
            stateString = "available"
        case .unavailable:
            availableTime = 0
            stateString = "unavailable"
        }
        items.first?.state = stateString
        items.first?.availableTime = availableTime
        saveContext()
    }
    
    func currentUrlEnitites() -> [URLEntity] {
        let request = NSFetchRequest<URLEntity>(entityName: "URLEntity")
        request.returnsObjectsAsFaults = false
        guard let items = try? workingContext.fetch(request) else {
            return []
        }
        return items
    }
    
    func currentUrlModels() -> [URLCellModel] {
        let items = currentUrlEnitites()
        var cellModels = [URLCellModel]()
        for item in items {
            if let urlString = item.url {
                var currentState = URLCellModelState.loading
                if item.state == "available" {
                    currentState = URLCellModelState.available(duration: item.availableTime )
                } else if item.state == "unavailable" {
                    currentState = URLCellModelState.unavailable
                }
                if let url = URL(string: urlString) {
                    cellModels.append(URLCellModel(url: url, state: currentState))
                }
            }
        }
        return cellModels
    }
    
    func currentSortType() -> SortTypes {
        let request = NSFetchRequest<SortEntity>(entityName: "SortEntity")
        request.returnsObjectsAsFaults = false
        guard let items = try? workingContext.fetch(request),
            let currentSortType = items.first?.sortType else {
                self.createSortEntity(type: .none, currentItems: [])
                saveContext()
                return .none
        }
        return SortTypes(rawValue: currentSortType) ?? .none
        
    }
    
    func updateSortEnitity(type: SortTypes, currentSortedItems: [String]) {
        let request = NSFetchRequest<SortEntity>(entityName: "SortEntity")
        request.returnsObjectsAsFaults = false
        guard let items = try? workingContext.fetch(request),
            let currentSort = items.first else {
            self.createSortEntity(type: type, currentItems: currentSortedItems)
            return
        }
        currentSort.sortType = type.rawValue
        currentSort.urlArray = currentSortedItems
        saveContext()
        
    }
    
    func createSortEntity(type: SortTypes, currentItems: [String]) {
        let newSort = SortEntity(context: workingContext)
        newSort.sortType = type.rawValue
        newSort.urlArray = currentItems
    }

}
