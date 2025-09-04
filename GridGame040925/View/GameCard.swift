//
//  GameCard.swift
//  GridGame040925
//
//  Created by Mohamed Bouzoualegh on 4/9/2025.
//

import SwiftUI
enum CardType {
    case emoji
    case number
    case image
}
struct GameCard: View {
    
    let cardContent: String
    let cardType: CardType
    let isFlipped: Bool
    var body: some View {
        VStack {
            if isFlipped{
                switch cardType {
                case .emoji:
                    Text(cardContent)
                        .padding(16)
                case .number:
                    Text(cardContent)
                        .font(.title)
                        .padding(16)
                case .image:
                    Image(systemName: cardContent)
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
        .background(.gray.opacity(0.5))
        .clipShape(RoundedRectangle(cornerSize: .init(width: 8, height: 8)))
    }
}

#Preview {
    GameCard(
        cardContent: "12", cardType: .number, isFlipped: false
    )
}
