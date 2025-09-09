//
//  GameCard.swift
//  GridGame040925
//
//  Created by Mohamed Bouzoualegh on 4/9/2025.
//

import SwiftUI

struct GameCard: View {
    
    let card: GameCardModel
    var body: some View {
        VStack {
            if card.hasMatched || card.isFlipped{
                switch card.content {
                case .emoji(let value):
                    Text(value)
                        .padding(16)
                case .number(let value):
                    Text(String(value))
                        .font(.title)
                        .padding(16)
                case .image(let systemName):
                    Image(systemName: systemName)
                        .resizable()
                        .scaledToFit()
                }
            }
            else {
                Text("G")
                    .font(.subheadline)
            }
        }
        .frame(width: 64, height: 64)
        .background( (card.hasMatched || card.isFlipped) ? .teal.opacity(0.5) : .gray.opacity(0.5))
        .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
    }
}

#Preview {
    GameCard(card: GameCardModel(content: .number(12)))
}
