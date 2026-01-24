import Foundation

class GameViewModel {
    private var gameEngine: GameEngine
    private var timer: Timer?
    
    var onStateChanged: ((GameState) -> Void)?
    var onScoreChanged: ((Int) -> Void)?
    var onTimeChanged: ((Int) -> Void)?
    var onProblemChanged: ((String?) -> Void)?
    var onGameOver: ((Int) -> Void)?
    
    init(difficulty: Difficulty) {
        self.gameEngine = GameEngine(difficulty: difficulty)
    }
    
    func startGame() {
        gameEngine.startGame()
        startTimer()
        onStateChanged?(gameEngine.gameState)
    }

    func submitAnswer(_ answer: Double) {
        let isCorrect = gameEngine.checkAnswer(answer)
        
        if isCorrect {
            print("Correct answer")
        }
        else {
            print("Wrong answer")
        }
        
        gameEngine.generateProblem()
        notifyUIOfChanges()
    }

    func restart() {
        stopTimer()
        gameEngine = GameEngine(difficulty: gameEngine.difficulty)
        gameEngine.startGame()
        startTimer()
        notifyUIOfChanges()
    }

    func stopGame() {
        stopTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateTimer() {
        gameEngine.decrementTime()
        onTimeChanged?(gameEngine.remainingTime)
        
        if gameEngine.isGameOver() {
            handleGameOver()
        }
    }

    func handleGameOver() {
        stopTimer()
        gameEngine.finishGame()
        onStateChanged?(gameEngine.gameState)
        onGameOver?(gameEngine.score)
    }

    private func notifyUIOfChanges() {
        onStateChanged?(gameEngine.gameState)
        onScoreChanged?(gameEngine.score)
        onTimeChanged?(gameEngine.remainingTime)
        onProblemChanged?(gameEngine.problemText)
    }

    var currentScore: Int {
        return gameEngine.score
    }
    
    var remainingTime: Int {
        return gameEngine.remainingTime
    }
    
    var totalTime: Int {
        return gameEngine.difficulty.remainingTime
    }
    
    var currentState: GameState {
        return gameEngine.gameState
    }
    
    var problemText: String? {
        return gameEngine.problemText
    }
    
    var difficulty: Difficulty {
        return gameEngine.difficulty
    }
    
    deinit {
        stopTimer()
    }

}
