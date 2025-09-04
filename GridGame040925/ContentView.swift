//
//  ContentView.swift
//  GridGame040925
//
//  Created by Mohamed Bouzoualegh on 4/9/2025.
//

import SwiftUI

enum GameResult {
    case success
    case failed
    case ongoing
}
struct ContentView: View {
    
    @State var timer: Timer?
    @State var randomArray: [GameCardModel]
    @State var isChecking: Bool = false
    @State var timeRemaining: Int = 60
    @State var isTimerActive: Bool = false
    @State var gameResult: GameResult = .ongoing
    
    init() {
        self._randomArray = .init(
            initialValue: GameCardModel.generateRandomCards()
        )
    }
    var body: some View {
        ZStack {
            switch gameResult {
            case .success:
                Text("Bravo")
                    .foregroundStyle(.green)
                    .font(.title)
            case .failed:
                Text("Game Over")
                    .foregroundStyle(.red)
                    .font(.title)
            case .ongoing:
                VStack {
                    Text("Time remaining : \(timeRemaining)")
                    GameGrid(gameCards: randomArray) { index, card in
                        guard !card.hasMatched && !isChecking else {
                            return
                        }
                        isChecking = true
                        let indexOfLastFlipped = randomArray.firstIndex { card in
                            card.isFlipped
                        }
                        if let indexOfLastFlipped = indexOfLastFlipped {
                            
                            var updatedCard = card
                            updatedCard.isFlipped = true
                            randomArray[index] = updatedCard
                            // compare the selected one with the other
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 2
                            ){
                                var otherCard = randomArray[indexOfLastFlipped]
                                if card.cardContent == otherCard.cardContent {
                                    var updatedCard = card
                                    updatedCard.isFlipped = false
                                    updatedCard.hasMatched = true
                                    randomArray[index] = updatedCard
                                    otherCard.isFlipped = false
                                    otherCard.hasMatched = true
                                    randomArray[indexOfLastFlipped] = otherCard
                                }
                                else {
                                    var updatedCard = card
                                    updatedCard.isFlipped = false
                                    randomArray[index] = updatedCard
                                    otherCard.isFlipped = false
                                    randomArray[indexOfLastFlipped] = otherCard
                                }
                                isChecking = false
                                checkGameStatus(timerIsOver: timeRemaining < 0)
                            }
                            
                        } else {
                            var updatedCard = card
                            updatedCard.isFlipped = true
                            randomArray[index] = updatedCard
                            isChecking = false
                        }
                        
                        
                    }
                }
            }
            
        }
        .padding()
        .onAppear{
            startTimer()
        }
    }
    
    
    private func startTimer(){
        if isTimerActive{
            timer?.invalidate()
            isTimerActive = false
        }else {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    isTimerActive = false
                    checkGameStatus(timerIsOver: true)
                }
            })
        }
    }
    
    private func checkGameStatus(
        timerIsOver: Bool
    ) {
        let numberOfMatched = randomArray.filter(
            { card in
            card.hasMatched
            }
        ).count
        if gameResult == .failed {
            return
        }else if (numberOfMatched == 16) {
            //Game Won
            gameResult = .success
        }else if timerIsOver{
            // Game Still not won
            gameResult = .failed
        }
    }
    
}

#Preview {
    ContentView()
}
