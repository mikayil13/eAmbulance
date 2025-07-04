//
//  AiManager.swift


import Foundation
import Alamofire

final class AiManager {
    static let shared = AiManager()
    private init() {}

    private let apiKey = "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"
    private let chatModelUrl = "https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta"

    func sendMessage(_ text: String) async throws -> String {
        let headers: [String: String] = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        let parameters: [String: Any] = [
            "inputs": "Istifadəçi: \(text)\nAssistant:",
            "parameters": [
                "temperature": 0.7,
                "max_length": 300,
                "top_p": 0.9
            ],
            "options": [
                "wait_for_model": true
            ]
        ]
        return try await withCheckedThrowingContinuation { continuation in
            NetworkingManager.shared.postRequest(url: chatModelUrl, headers: headers, parameters: parameters) { result in
                switch result {
                case .success(let json):
                    if let resultArray = json as? [[String: Any]],
                       let firstResult = resultArray.first,
                       let generatedText = firstResult["generated_text"] as? String {
                        continuation.resume(returning: generatedText.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cavab parse olunmadı."]))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
