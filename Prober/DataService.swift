//
//  DataService.swift
//  Listing0
//
//  Created by Daniel Bonates on 05/03/17.
//  Copyright © 2017 Daniel Bonates. All rights reserved.
//

import Foundation

struct Resource<T> {
    var url: URL
    var parse: (Data) -> T?
}

final class DataService {
    
    var session: URLSession!
    
    func load<T>(resource: Resource<T>, completion: @escaping (T?) -> ()) {
        
        session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        
        (session.dataTask(with: resource.url, completionHandler: { data, _, error in
            guard error == nil else { return }
            guard let data = data else { completion(nil); return }
            completion(resource.parse(data))
        })).resume()
    }
    
    func stop() {
        session.invalidateAndCancel()
    }
}
