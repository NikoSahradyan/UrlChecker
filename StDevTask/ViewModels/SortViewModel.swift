//
//  SortViewModel.swift
//  StDevTask
//
//  Created by Developer on 03/05/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

enum SortTypes: String {
    case none = "none"
    case nameAscending = "name ascending"
    case nameDescending = "name descending"
    case availability = "availability"
    case availabilityTimeAscending = "availability time ascending"
    case availabilityTimeDescending = "availability time descending"
    
    func indexPathForSortType() -> IndexPath {
        switch self {
        case .none:
            return IndexPath(row: 0, section: 0)
        case .nameAscending:
            return IndexPath(row: 1, section: 0)
        case .nameDescending:
            return IndexPath(row: 2, section: 0)
        case .availability:
            return IndexPath(row: 3, section: 0)
        case .availabilityTimeAscending:
            return IndexPath(row: 4, section: 0)
        case .availabilityTimeDescending:
            return IndexPath(row: 5, section: 0)
        }
    }
    
}

class SortViewModel: NSObject {
    var sortItems: [SortTypes] = [.none,
                                  .nameAscending,
                                  .nameDescending,
                                  .availability,
                                  .availabilityTimeAscending,
                                  .availabilityTimeDescending]
    var updateSortEntityWithType: ((SortTypes) -> ())?
    var selectedType : SortTypes
    
    init(sortType: SortTypes) {
        selectedType = sortType
        super.init()
    }
    
    func setupTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.selectRow(at: selectedType.indexPathForSortType(),
                            animated: false,
                            scrollPosition: .middle)
    }
}

extension SortViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = sortItems[indexPath.row].rawValue
        return cell
    }
}

extension SortViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isHidden = true
        let currentType = sortItems[indexPath.row]
        updateSortEntityWithType?(selectedType)
        selectedType = currentType
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}


