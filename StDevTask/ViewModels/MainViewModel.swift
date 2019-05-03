//
//  MainViewModel.swift
//  StDevTask
//
//  Created by Developer on 01/05/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class MainViewModel: NSObject {
    
    var urlCellModelList = [URLCellModel]()
    var alertPresentingClosure: ((String) -> ())?
    var insertModelToTableClosure: (([IndexPath]) -> ())?
    var moveModelInTableClosure: ((IndexPath) -> ())?
    var reloadTable: (() -> ())?
    
    lazy var sortViewModel: SortViewModel = {
        let currentSortType = CoreDataService.shared.currentSortType()
        let sortModel = SortViewModel(sortType: currentSortType)
        self.urlCellModelList = self.sortItemsWithSortType(type: currentSortType)
        self.reloadTable?()
        sortModel.updateSortEntityWithType = { type in
            self.urlCellModelList = self.sortItemsWithSortType(type: type)
            self.reloadTable?()
            let sortedItems = self.urlCellModelList.map { $0.url.absoluteString }
            CoreDataService.shared.updateSortEnitity(type: type,
                                                     currentSortedItems: sortedItems)
        }
        return sortModel
    } ()
    
    override init() {
        super.init()
        urlCellModelList = CoreDataService.shared.currentUrlModels()
    }
    
    func setupTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "URlCell", bundle: nil), forCellReuseIdentifier: "URlCell")
        self.insertModelToTableClosure = { indexPaths in
            tableView.insertRows(at: indexPaths, with: .none)
        }
        self.moveModelInTableClosure = { indexPath in
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
        }
        self.reloadTable = {
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }
    
    func setupSortTableView(tableView: UITableView) {
        sortViewModel.setupTableView(tableView: tableView)
    }
    
    func insertNewUrl(url: URL?) {
        guard let existingUrl = url else {
            return
        }
        let urlList = urlCellModelList.map { $0.url }
        if let oldIdx = urlList.firstIndex(of: existingUrl) {
            let cellModel = self.urlCellModelList.remove(at: oldIdx)
            self.urlCellModelList.insert(cellModel, at: 0)
            self.moveModelInTableClosure?(IndexPath(row: oldIdx, section: 0))
        }
        let cellModel = URLCellModel(url: existingUrl)
        CoreDataService.shared.addNewUrl(cellModel: cellModel)
        urlCellModelList.insert(cellModel, at: 0)
        self.insertModelToTableClosure?([IndexPath(row: 0, section: 0)])
    }
    
    func refresh() {
        urlCellModelList.forEach { $0.refresh() }
    }
    
    func sortItemsWithSortType(type: SortTypes) -> [URLCellModel] {
        var urlList = urlCellModelList.map { $0.url.absoluteString }
        switch type {
        case .none:
            break
        case .nameAscending:
            urlList.sort { $0 > $1 }
        case .nameDescending:
            urlList.sort { $0 < $1 }
        case .availability:
            urlList = urlCellModelList.filter { $0.state.availabilityTime() != 0 }.map { $0.url.absoluteString }
        case .availabilityTimeAscending:
            urlList = urlCellModelList.filter { $0.state.availabilityTime() != 0 }
                .sorted {$0.state.availabilityTime() > $1.state.availabilityTime()}
                .map { $0.url.absoluteString }
        case .availabilityTimeDescending:
            urlList = urlCellModelList.filter { $0.state.availabilityTime() != 0 }
                .sorted {$0.state.availabilityTime() < $1.state.availabilityTime()}
                .map { $0.url.absoluteString }
        }
        var sortedModels = [URLCellModel]()
        let allUrls = urlCellModelList.map { $0.url.absoluteString }
        for urlString in urlList {
            if let idx = allUrls.firstIndex(of: urlString) {
                sortedModels.append(urlCellModelList[idx])
            }
        }
        return sortedModels
    }

}

extension MainViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlCellModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "URlCell", for: indexPath) as? URlCell else {
            return UITableViewCell()
        }
        let cellModel = urlCellModelList[indexPath.row]
        cell.setupWithCellModel(cellModel: cellModel)
        return cell
    }
}

extension MainViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            guard let deletingObject = self?.urlCellModelList[indexPath.row] else {
                return
            }
            if case URLCellModelState.loading = deletingObject.state {
                self?.alertPresentingClosure?("Sorry but you cannot Delete this item because it is loading")
            } else {
                self?.urlCellModelList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                CoreDataService.shared.removeUrl(cellModel: deletingObject)
            }
        }
        
        return [delete]
    }
}
