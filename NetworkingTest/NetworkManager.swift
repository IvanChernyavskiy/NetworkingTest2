//
//  NetworkManager.swift
//  NetworkingTest
//
//  Created by Иван Чернявский on 21.04.2021.
//

import Foundation

class NetworkManager {
    func getAllPosts(_ complitionHandler: @escaping ([Post]) -> Void) {
    if let url = URL (string: "http://jsonplaceholder.typicode.com/posts") {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("error in request")
            } else {
                if let resp = response as? HTTPURLResponse,
                resp.statusCode == 200, let responseData = data {
                    let posts = try?
                        JSONDecoder().decode([Post].self, from: responseData)
                   
                    complitionHandler(posts ?? [])
                   
            }
            }
        } .resume()
}

}
}
