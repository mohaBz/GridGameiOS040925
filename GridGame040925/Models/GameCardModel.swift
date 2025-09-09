//
//  GameGridModel.swift
//  GridGame040925
//
//  Created by Mohamed Bouzoualegh on 4/9/2025.
//
enum CardType: Equatable {
    case emoji
    case number
    case image
}

enum CardContent: Equatable {
    case emoji(String)
    case number(Int)
    case image(String) // SF Symbol name
}

struct GameCardModel: Equatable {
    let content: CardContent
    var isFlipped: Bool = false
    var hasMatched: Bool = false
    
    var type: CardType {
        switch content {
        case .emoji: return .emoji
        case .number: return .number
        case .image: return .image
        }
    }
    
    init(content: CardContent, isFlipped: Bool = false, hasMatched: Bool = false) {
        self.content = content
        self.isFlipped = isFlipped
        self.hasMatched = hasMatched
    }
    
    init?(type: CardType, rawValue: String) {
        switch type {
        case .emoji:
            guard GameCardModel.isSingleEmoji(rawValue) else { return nil }
            self.content = .emoji(rawValue)
        case .number:
            guard let value = Int(rawValue) else { return nil }
            self.content = .number(value)
        case .image:
            guard !rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            self.content = .image(rawValue)
        }
    }
    
    static func isSingleEmoji(_ string: String) -> Bool {
        // Basic check: one extended grapheme cluster and contains an emoji presentation
        if string.count != 1 { return false }
        return string.unicodeScalars.first?.properties.isEmojiPresentation == true
    }
    
    static func generateRandomCards() -> [GameCardModel] {
        var gridItems:[GameCardModel] = []
        let emojis = ["🎯", "💎", "🎲", "🌟"]
        let numbers = [1,2,3,4,5,6,7,8,9,0]
        let images = ["car.rear","airplane", "tram", "sailboat", "bicycle", "fuelpump.fill"]
        for _ in 0..<8 {
            let randomNumber = Int.random(in: 1...3)
            if randomNumber == 1 {
                let emoji = emojis.randomElement() ?? "🎯"
                gridItems.append(GameCardModel(content: .emoji(emoji)))
            } else if randomNumber == 2 {
                let number = numbers.randomElement() ?? 0
                gridItems.append(GameCardModel(content: .number(number)))
            } else {
                let image = images.randomElement() ?? "airplane"
                gridItems.append(GameCardModel(content: .image(image)))
            }
        }
        gridItems.append(contentsOf: gridItems)
        gridItems.shuffle()
        return gridItems
    }
    
    static func == (lhs: GameCardModel, rhs: GameCardModel) -> Bool {
        return lhs.content == rhs.content && lhs.isFlipped == rhs.isFlipped && lhs.hasMatched == rhs.hasMatched
    }
}
