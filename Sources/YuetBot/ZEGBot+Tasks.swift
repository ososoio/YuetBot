import Foundation
import ZEGBot
import Logging

extension ZEGBot {
        func greet(user: User, update: Update) {
                guard let message: Message = update.message else { return }
                
                logger.info("\(user.bestName) joined chat. chat_id: \(message.chat.id)")
                if let chatTitle: String = message.chat.title {
                        logger.info("Chat title: \(chatTitle)")
                }
                
                guard !user.isBot else {
                        logger.info("The new member is a bot.")
                        return
                }
                
                let greeting: String = """
                歡迎 \(user.firstName)！
                💕🎊🎉👋😃
                發送 /help
                我就會即時出現
                """
                
                do {
                        try self.send(message: greeting, to: message.chat)
                        logger.info("Sent greeting.")
                } catch {
                        logger.error("\(error.localizedDescription)")
                }
        }
        
        func handle(update: Update) {
                guard let message: Message = update.message else { return }
                
                if let _ = message.groupChatCreated {
                        logger.info("Group Chat created. chat_id: \(message.chat.id)")
                        if let chatTitle: String = message.chat.title {
                                logger.info("Chat title: \(chatTitle)")
                        }
                }
                
                if let leftChatMember: User = message.leftChatMember {
                        logger.info("\(leftChatMember.bestName) left chat. chat_id: \(message.chat.id)")
                        if let chatTitle: String = message.chat.title {
                                logger.info("Chat title: \(chatTitle)")
                        }
                }
                
                guard let text: String = message.text, !text.isEmpty else { return }
                
                if text.contains("/start") || text.contains("/help")
                {
                        handleStartHelp(message: message)
                }
                else if text.contains("/yam") || text.contains("/ping")
                {
                        handleYam(message: message, text: text)
                }
                else if text.hasPrefix("/test") || text.hasPrefix("/hey") || text.hasPrefix("/hi") || text.hasPrefix("/hello") || text.hasPrefix("/bonjour") {
                        handleTest(message: message)
                }
                else
                {
                        fallback(message: message, text: text)
                }
        }
        
        private func handleStartHelp(message: Message) {
                guard let from: User = message.from else { return }
                
                let response: String = """
                你好， \(from.firstName)！
                我係 YuetYam bot，
                有咩可以幫到你？😃
                
                發送「/yam +粵語字詞」，
                我就會回覆字詞相應嘅 YuetYam
                """
                
                do {
                        try self.send(message: response, to: message.chat)
                        logger.info("Sent help content. chat_id: \(message.chat.id), from: \(message.userBestName)")
                        if let chatTitle: String = message.chat.title {
                                logger.info("Chat title: \(chatTitle)")
                        }
                } catch {
                        logger.error("\(error.localizedDescription)")
                }
                
        }
        
        private func handleYam(message: Message, text: String) {
                let specials: String = #"abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ_0123456789-:;.,?~!@#$%^&*/\<>{}[]()+='"•。，；？！、：～（）《》「」【】"#
                let text: String = text.filter { !specials.contains($0) }
                guard !text.isEmpty else {
                        logger.notice("Called yam() with no Cantonese. chat_id: \(message.chat.id), from: \(message.userBestName)")
                        if let chatTitle: String = message.chat.title {
                                logger.info("Chat title: \(chatTitle)")
                        }
                        do {
                                try self.send(message: "/yam +粵語字詞", to: message.chat)
                        } catch {
                                logger.error("\(error.localizedDescription)")
                        }
                        return
                }
                var responseText: String = "\(text)："
                let matchedYuetYams: [String] = YuetYamProvider.match(for: text)
                if matchedYuetYams.count > 0 {
                        let yuetyamEntries: String = matchedYuetYams.reduce("") { $0 + "\n" + $1 }
                        responseText += yuetyamEntries
                } else {
                        var chars: String = text
                        var suggestion: String = "\n"
                        while !chars.isEmpty {
                                let leadingMatch = fetchLeadingYuetYam(for: chars)
                                suggestion += leadingMatch.yuetyam + " "
                                chars = String(chars.dropFirst(leadingMatch.charCount))
                        }
                        suggestion = String(suggestion.dropLast())
                        responseText += (suggestion.isEmpty ? "__NULL__" : suggestion)
                }
                
                do {
                        try self.send(message: responseText, to: message.chat)
                        logger.info("Responsed YuetYam. words: \(text), chat_id: \(message.chat.id), from: \(message.userBestName)")
                        if let chatTitle: String = message.chat.title {
                                logger.info("Chat title: \(chatTitle)")
                        }
                } catch {
                        logger.error("\(error.localizedDescription)")
                }
        }
        private func fetchLeadingYuetYam(for words: String) -> (yuetyam: String, charCount: Int) {
                var chars: String = words
                var yuetyams: [String] = []
                var matchedCount: Int = 0
                while !chars.isEmpty && yuetyams.isEmpty {
                        yuetyams = YuetYamProvider.match(for: chars)
                        matchedCount = chars.count
                        chars = String(chars.dropLast())
                }
                return (yuetyams.first ?? "?", matchedCount)
        }
        
        private func handleTest(message: Message) {
                do {
                        try self.send(message: "Bonjour", to: message.chat)
                        logger.info("Bonjour. chat_id: \(message.chat.id), from: \(message.userBestName)")
                        if let chatTitle: String = message.chat.title {
                                logger.info("Chat title: \(chatTitle)")
                        }
                } catch {
                        logger.error("\(error.localizedDescription)")
                }
        }
        
        private func fallback(message: Message, text: String) {
                do {
                        try self.send(message: "我聽唔明😔", to: message.chat)
                        logger.info("Called fallback(). chat_id: \(message.chat.id), from: \(message.userBestName), received text: \(text)")
                        if let chatTitle: String = message.chat.title {
                                logger.info("Chat title: \(chatTitle)")
                        }
                } catch {
                        logger.error("\(error.localizedDescription)")
                }
        }
        
        func handleTimeout(update: Update) {
                guard let message: Message = update.message else { return }
                logger.info("Message timeout. chat_id: \(message.chat.id), from: \(message.userBestName)")
                let text: String = message.text ?? "__EMPTY__"
                logger.info("Received text: \(text)")
                logger.info("Message date: \(message.date)")
                if let chatTitle: String = message.chat.title {
                        logger.info("Chat title: \(chatTitle)")
                }
        }
}


private extension Message {
        var userBestName: String {
                guard let fromUser: User = self.from else { return "__UNKNOWN__" }
                return fromUser.bestName
        }
}

private extension User {
        var bestName: String {
                if let username = self.username {
                        return "@" + username
                }
                if let lastName = self.lastName {
                        return self.firstName + " " + lastName
                }
                return self.firstName
        }
}
