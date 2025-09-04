//
//  GameGridModel.swift
//  GridGame040925
//
//  Created by Mohamed Bouzoualegh on 4/9/2025.
//

struct GameCardModel {
    let cardType: CardType
    let cardContent: String
    var isFlipped: Bool = false
    var hasMatched: Bool = false
    
    
    static func generateRandomCards() -> [GameCardModel]{
        var gridItems:[GameCardModel] = []
        let emojis = ["🎯", "💎", "🎲", "🌟"]
        let numbers = ["1","2","3","4", "5", "6", "7", "8", "9", "0"]
        let images = ["car.rear","airplane", "tram", "sailboat", "bicycle", "fuelpump.fill"]
        for _ in 0..<8 {
            let randomNumber = Int.random(in: 1...3)
            if randomNumber == 1 {
                let emoji = emojis.randomElement() ?? "🎯"
                gridItems.append(GameCardModel(cardType: .emoji, cardContent: emoji))
            }else if randomNumber == 2 {
                let number = numbers.randomElement() ?? "0"
                gridItems.append(
                    GameCardModel(
                        cardType: .number,
                        cardContent: number
                    )
                )
            }else if randomNumber == 3 {
                let image = images.randomElement() ?? "airplane"
                gridItems.append(
                    GameCardModel(
                        cardType: .image,
                        cardContent: image
                    )
                )
            }
        }
        gridItems.append(contentsOf: gridItems)
        gridItems.shuffle()
        return gridItems
    }
}
