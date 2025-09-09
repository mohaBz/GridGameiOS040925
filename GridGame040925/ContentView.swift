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
    @State var firstFlippedIndex: Int? = nil
    @State var secondFlippedIndex: Int? = nil
    @State var pendingResolutionTask: Task<Void, Never>? = nil
    
    private let flipDelayNanoseconds: UInt64 = 2_000_000_000
    
    init() {
        self._randomArray = .init(
            initialValue: GameCardModel.generateRandomCards()
        )
    }
    var body: some View {
        ZStack {
            VStack {
                Text("Time remaining : \(timeRemaining)")
                GameGrid(gameCards: randomArray) { index, card in
                    handleCardTap(at: index, card: card)
                }
            }
            if gameResult != .ongoing {
                overlayView()
            }
        }
        .onAppear{
            startTimer()
        }
    }
    
    // MARK: - Game Actions (kept close to GameGrid for readability)
    private func handleCardTap(at index: Int, card: GameCardModel) {
        guard gameResult == .ongoing else { return }
        guard !card.hasMatched else { return }

        // If two cards are already flipped and waiting, resolve them immediately first
        if let firstIndex = firstFlippedIndex, let secondIndex = secondFlippedIndex {
            pendingResolutionTask?.cancel()
            pendingResolutionTask = nil
            finalizePair(firstIndex: firstIndex, secondIndex: secondIndex)
        }

        isChecking = true
        if let firstIndex = firstFlippedIndex {
            if firstIndex == index {
                // Same card tapped; ignore
                isChecking = false
                return
            }
            let newlyFlippedCard = updated(card, isFlipped: true)
            applyCardUpdates([(index, newlyFlippedCard)])
            secondFlippedIndex = index
            schedulePairResolution(firstIndex: firstIndex, secondIndex: index)
        } else {
            let firstFlip = updated(card, isFlipped: true)
            applyCardUpdates([(index, firstFlip)])
            firstFlippedIndex = index
            isChecking = false
        }
    }

    private func schedulePairResolution(firstIndex: Int, secondIndex: Int) {
        pendingResolutionTask?.cancel()
        pendingResolutionTask = Task { [flipDelayNanoseconds] in
            try? await Task.sleep(nanoseconds: flipDelayNanoseconds)
            if Task.isCancelled { return }
            await MainActor.run {
                finalizePair(firstIndex: firstIndex, secondIndex: secondIndex)
            }
        }
    }

    private func finalizePair(firstIndex: Int, secondIndex: Int) {
        let firstCard = randomArray[firstIndex]
        let secondCard = randomArray[secondIndex]
        let isMatch = firstCard.content == secondCard.content

        let newFirst = updated(firstCard, isFlipped: false, hasMatched: isMatch ? true : nil)
        let newSecond = updated(secondCard, isFlipped: false, hasMatched: isMatch ? true : nil)

        applyCardUpdates([
            (firstIndex, newFirst),
            (secondIndex, newSecond)
        ])
        isChecking = false
        firstFlippedIndex = nil
        secondFlippedIndex = nil
        checkGameStatus(timerIsOver: timeRemaining < 0)
    }
    
    // MARK: - Overlay and Reset
    @ViewBuilder
    private func overlayView() -> some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 16) {
                Text(gameResult == .success ? "Bravo" : "Game Over")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(gameResult == .success ? .green : .red)
                Button(action: {
                    resetGame()
                }) {
                    Text("Play Again")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.horizontal)
            }
            .padding()
            .background(.ultraThickMaterial)
            .cornerRadius(16)
            .padding()
        }
        .transition(.opacity)
    }

    private func resetGame() {
        timer?.invalidate()
        isTimerActive = false
        timeRemaining = 60
        isChecking = false
        firstFlippedIndex = nil
        randomArray = GameCardModel.generateRandomCards()
        gameResult = .ongoing
        startTimer()
    }

    // MARK: - Small helpers to reduce side effects
    private func updated(_ card: GameCardModel, isFlipped: Bool? = nil, hasMatched: Bool? = nil) -> GameCardModel {
        var copy = card
        if let isFlipped = isFlipped { copy.isFlipped = isFlipped }
        if let hasMatched = hasMatched { copy.hasMatched = hasMatched }
        return copy
    }

    private func applyCardUpdates(_ updates: [(Int, GameCardModel)]) {
        for (index, card) in updates {
            randomArray[index] = card
        }
    }
    
    
    private func startTimer(){
        if isTimerActive{
            timer?.invalidate()
            isTimerActive = false
        } else {
            isTimerActive = true
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
        guard gameResult == .ongoing else { return }
        let allMatched = randomArray.allSatisfy { $0.hasMatched }
        if allMatched {
            timer?.invalidate()
            isTimerActive = false
            gameResult = .success
        } else if timerIsOver {
            gameResult = .failed
        }
    }
    
}

#Preview {
    ContentView()
}
