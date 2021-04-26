//
//  NetworkManager.swift
//  NetworkingTest
//
//  Created by Иван Чернявский on 21.04.2021.
//

import Foundation

class NetworkManager {

   let provider = APIProvider<PostsEndPoint>()
//   func getAllPosts(_ complitionHandler: @escaping ([Post]) -> Void) {
//      if let url = URL (string: "http://jsonplaceholder.typicode.com/posts") {
//         URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if error != nil {
//               print("error in request")
//            } else {
//               if let resp = response as? HTTPURLResponse,
//                  resp.statusCode == 200, let responseData = data {
//                  let posts = try?
//                     JSONDecoder().decode([Post].self, from: responseData)
//
//                  complitionHandler(posts ?? [])
//
//               }
//            }
//         } .resume()
//      }
//   }


   func getAllPosts(completion: @escaping ((Result<[Post]?, APIProviderError>) -> Void)) {
      provider.performRequest(.all, completion: completion)
   }


}

enum PostsEndPoint {
   case all
   case some
}

extension PostsEndPoint: EndPoint {
   var host: String {
      return "http://jsonplaceholder.typicode.com/"
   }

   var path: String {
      switch self {
      case .all:
         return "posts"
      case .some:
         return "some"
      }
   }

   var httpMethod: HTTPMethod {
      switch self {
      case .all, .some:
         return .GET
      }
   }

   var task: HTTPTask {
      .request(url: nil, body: nil, additionalHeaders: nil)
   }

   var headers: HTTPHeaders? {
      nil
   }

}



enum APIProviderError: Error {
   case internalError
   case serverError
   case decodeError
}

struct APIProvider<Source: EndPoint> {

   private let session: URLSession
   private let urlBuilder: URLRequestBuilder

   init(
      session: URLSession = URLSession.shared,
      urlBuilder: URLRequestBuilder = URLRequestBuilderImpl()
   ) {
      self.urlBuilder = urlBuilder
      self.session = session
   }

   func performRequest<T: Decodable>(_ source: Source, completion: @escaping ((Result<T?, APIProviderError>) -> Void)) {
      do {
         let request = try urlBuilder.build(with: source)
         session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
               completion(.failure(.serverError))
               return
            }
            guard let data = data else {
               completion(.success(nil))
               return
            }

            let result = try? JSONDecoder().decode(T.self, from: data)
            completion(.success(result))
         }
         .resume()
      } catch {
         completion(.failure(APIProviderError.internalError))
      }
   }
}

protocol URLRequestBuilder {
   func build(with endPoint: EndPoint) throws -> URLRequest
}

enum BuildRequestError: Error {
   case generateURL
}


class URLRequestBuilderImpl: URLRequestBuilder {
   func build(with endPoint: EndPoint) throws -> URLRequest {

      guard var url = URL(string: endPoint.host) else { throw BuildRequestError.generateURL }
      url.appendPathComponent(endPoint.path)

      var request = URLRequest(url: url)

      request.httpMethod = endPoint.httpMethod.rawValue

      // some additional logic

      return request
   }


}

protocol EndPoint {
   var host: String { get }
   var path: String { get }
   var httpMethod: HTTPMethod { get }
   var task: HTTPTask { get }
   var headers: HTTPHeaders? { get }
}



enum HTTPMethod: String {
   case GET
   case POST
   case PUT
   case DELETE
}

enum HTTPTask {
   case request(url: Parameters? = nil, body: Parameters? = nil, additionalHeaders: HTTPHeaders? = nil)
}

typealias HTTPHeaders = [String: String]
typealias Parameters = [String: Any]
