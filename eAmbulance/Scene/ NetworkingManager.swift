//
//   NetworkingManager.swift
//  eAmbulance
//
//  Created by Mikayil on 02.05.25.
//

import Foundation
import Alamofire

final class NetworkingManager {
    static let shared = NetworkingManager()
    private init() {}

    func postRequest(
        url: String,
        headers: [String: String],
        parameters: [String: Any],
        completion: @escaping (Result<Any, Error>) -> Void
    ) {
        let afHeaders = HTTPHeaders(headers)
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: afHeaders)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    completion(.success(json))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func getRequest(url: String,headers: [String: String] = [:],completion: @escaping (Result<Data, Error>) -> Void) {
           let afHeaders = HTTPHeaders(headers)
           AF.request(url, method: .get, headers: afHeaders)
               .validate()
               .responseData { response in
                   switch response.result {
                   case .success(let data):
                       completion(.success(data))
                   case .failure(let error):
                       
                       completion(.failure(error))
            }
        }
    }
}
