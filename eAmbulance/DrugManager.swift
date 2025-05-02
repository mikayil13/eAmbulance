//
//  DrugManager.swift
//  eAmbulance
//
//  Created by Mikayil on 02.05.25.
//

import Foundation
import Alamofire

final class DrugManager {
    static let shared = DrugManager()
    private init() {}

    /// API vasitəsilə dərman haqqında məlumat alır.
    func fetchDrugInfo(for name: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let url = "https://api.fda.gov/drug/label.json?search=openfda.brand_name:\"\(safeName)\"&limit=1"

        NetworkingManager.shared.getRequest(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    // Data tipində gələn JSON-u obyektə çevir
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let results = json["results"] as? [[String: Any]],
                          let first = results.first else {
                        let err = NSError(domain: "", code: 404,
                                           userInfo: [NSLocalizedDescriptionKey: "Məlumat tapılmadı"])
                        completion(.failure(err))
                        return
                    }
                    // Cavabı formatla
                    var message = ""
                    if let ing = first["active_ingredient"] as? [String] {
                        message += "🤖 Tərkib: \(ing.joined(separator: ", "))\n\n"
                    }
                    if let usage = first["indications_and_usage"] as? [String] {
                        message += "🔍 İstifadə: \(usage.joined(separator: "\n"))\n"
                    }
                    completion(.success(message))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
