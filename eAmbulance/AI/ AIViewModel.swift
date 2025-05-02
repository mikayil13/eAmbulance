//
//   AIViewModel.swift
//  eAmbulance
//
//  Created by Mikayil on 02.05.25.
//

import Foundation

protocol AIViewModelDelegate: AnyObject {
    func didUpdateMessages()
    func didStartLoading()
    func didFinishLoading()
}

final class AIViewModel {
    private(set) var messages: [String] = []
    private let sendMessageUseCase: SendMessageUseCase
    weak var delegate: AIViewModelDelegate?

    init(sendMessageUseCase: SendMessageUseCase = DefaultSendMessageUseCase()) {
        self.sendMessageUseCase = sendMessageUseCase
    }

    func numberOfMessages() -> Int {
        return messages.count
    }

    func message(at index: Int) -> (text: String, sender: String) {
        let message = messages[index]
        let sender = index % 2 == 0 ? "Me" : "HelpMe"
        return (message, sender)
    }

    func sendMessage(_ userMessage: String) {
        guard !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        messages.append(userMessage)
        delegate?.didUpdateMessages()

        delegate?.didStartLoading()

        Task {
            let aiResponse = await sendMessageToAI(userMessage)
            messages.append(aiResponse)
            delegate?.didUpdateMessages()
            delegate?.didFinishLoading()
        }
    }

    private func sendMessageToAI(_ text: String) async -> String {
        do {
            return try await sendMessageUseCase.execute(message: text)
        } catch {
            print("Xəta baş verdi: \(error)")
            return "Üzr istəyirəm, bir xəta baş verdi."
        }
    }
}
