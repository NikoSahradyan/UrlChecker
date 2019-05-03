//
//  URLcheckerService.swift
//  StDevTask
//
//  Created by Developer on 03/05/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class URLcheckerService: NSObject {
    
    static var shared = URLcheckerService()
    
    func checkUrl(url: URL, completion: @escaping (URLCellModelState) -> Void) {
        let startDate = Date().timeIntervalSince1970
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(.unavailable)
            } else {
                let timeOfRequest = Date().timeIntervalSince1970 - startDate
                completion(.available(duration: timeOfRequest))
            }
        }.resume()
    }

}
