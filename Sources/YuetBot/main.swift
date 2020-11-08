import Foundation
import ZEGBot
import Logging

enum BotError: Swift.Error {
        case noToken
}

let logger: Logger = Logger(label: "io.ososo.yuetbot")

guard let botToken: String = ProcessInfo.processInfo.environment["TELEGRAM_YUET_BOT_TOKEN"] else {
        logger.error("No Telegram bot token found on environments.")
        throw BotError.noToken
}

let bot: ZEGBot = ZEGBot(token: botToken)

do {
        try bot.run { (updates, _) in
                _ = updates.map { newUpdate in
                        guard let messageDate: Int = newUpdate.message?.date else { return }
                        let distance: Double = Date().timeIntervalSince1970.distance(to: Double(messageDate))
                        guard abs(distance) < 60 else {
                                bot.handleTimeout(update: newUpdate)
                                return
                        }
                        
                        if let newChatMember: User = newUpdate.message?.newChatMember {
                                bot.greet(user: newChatMember, update: newUpdate)
                        } else {
                                bot.handle(update: newUpdate)
                        }
                }
        }
} catch {
        logger.error("\(error.localizedDescription)")
}
