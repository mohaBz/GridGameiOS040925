//
//  GameGrid.swift
//  GridGame040925
//
//  Created by Mohamed Bouzoualegh on 4/9/2025.
//

import SwiftUI

struct GameGrid: View {
    let gameCards: [GameCardModel]
    let onFlipCard: (Int, GameCardModel) -> ()
    var body: some View {
        if gameCards.count == 16{
            Grid {
                
                ForEach(0..<4){ row in
                    GridRow {
                        ForEach(
                            0..<4
                        ) { col in
                            let index = row * 4 + col
                            let card = gameCards[index]
                            Button(
                                action:{
                                    onFlipCard(
                                        index,
                                        card
                                    )
                                }) {
                                    GameCard(
                                        cardContent: card.cardContent,
                                        cardType: card.cardType,
                                        isFlipped: card.hasMatched || card.isFlipped
                                    )
                                }
                                .buttonStyle(.plain)
                        }
                    }
                }
            }
            
        }
        else {
            Text("No cards available")
        }
    }
}

