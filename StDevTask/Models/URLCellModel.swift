//
//  URLCellModel.swift
//  StDevTask
//
//  Created by Developer on 01/05/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

enum URLCellModelState {
    case loading
    case available(duration: Double)
    case unavailable
    
    func availabilityTime() -> Double {
        switch self {
        case .loading, .unavailable:
            return 0
        case .available(let duration):
            return duration
        }
    }
}

class URLCellModel: NSObject {
    
    var url: URL
    var state = URLCellModelState.loading {
        didSet {
            self.updateCellWithStateClosure?(state)
            CoreDataService.shared.changeStateForCurrentItem(cellModel:self)
        }
    }
    var updateCellWithStateClosure: ((URLCellModelState) -> Void)?
    
    convenience init(url: URL) {
        self.init(url: url, state: .loading)
    }
    
    init(url: URL, state: URLCellModelState) {
        self.url = url
        self.state = state
        super.init()
        if case URLCellModelState.loading = state {
            self.checkAvailability()
        }
    }
    
    func refresh() {
        state = .loading
        self.checkAvailability()
    }
    
    func checkAvailability() {
        URLcheckerService.shared.checkUrl(url: url) { state in
            self.state = state
        }
    }

}
