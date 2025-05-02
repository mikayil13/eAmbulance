//
//  MessageUseCase.swift
//  eAmbulance
//
//  Created by Mikayil on 02.05.25.
//

import Foundation
protocol SendMessageUseCase {
    func execute(message: String) async throws -> String
}

final class DefaultSendMessageUseCase: SendMessageUseCase {
    func execute(message: String) async throws -> String {
        return try await AiManager.shared.sendMessage(message)
    }
}
