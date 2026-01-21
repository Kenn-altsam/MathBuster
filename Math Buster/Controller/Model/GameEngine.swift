import Foundation
import UIKit

struct GameEngine {
    var score: Int
    var remainingTime: Int
    let difficulty: Difficulty
    var gameState: GameState
    
    private(set) var problemText: String?
    private(set) var expectedResult: Double?
    private let operators: [String] = ["+", "/", "*", "-"]
    
    init(difficulty: Difficulty) { // initializer (constructor) of the parameters to get the initial values
        self.difficulty = difficulty
        self.score = 0
        self.remainingTime = difficulty.remainingTime
        self.problemText = nil
        self.expectedResult = nil
        self.gameState = .idle
        generateProblem()
    }
    
    mutating func startGame() {
        gameState = .playing
    }
    
    mutating func finishGame() {
        gameState = .finished
    }
    
    mutating func generateProblem() { // mutating keyword allows to modify the data of the instance of a struct or enum
        let range = difficulty.range
        
        let firstDigit = Int.random(in: range)
        let arithmeticOperator: String = ["+", "-", "x", "/"].randomElement()!
        
        var startingInteger: Int = range.lowerBound
        var endingInteger: Int = range.upperBound
        
        if arithmeticOperator == "/" && startingInteger == 0 {
            startingInteger = 1
        }else if arithmeticOperator == "-" {
            endingInteger = firstDigit
        }
        
        let secondDigit = Int.random(in: startingInteger...endingInteger)
        
        self.problemText = "\(firstDigit) \(arithmeticOperator) \(secondDigit) ="
        
        switch arithmeticOperator {
        case "+":
            self.expectedResult = Double(firstDigit + secondDigit)
        case "-":
            self.expectedResult = Double(firstDigit - secondDigit)
        case "x":
            self.expectedResult = Double(firstDigit * secondDigit)
        case "/":
            self.expectedResult = Double(firstDigit) / Double(secondDigit)
        default:
            self.expectedResult = nil
        }
    }
    
    mutating func checkAnswer(_ answer: Double) -> Bool {
        guard let expectedResult = expectedResult else { return false }
        
        if answer == expectedResult {
            score += difficulty.scores
            return true
        }
        return false
    }
    
    mutating func decrementTime() {
        remainingTime -= 1
    }
    
    func isGameOver() -> Bool {
        return remainingTime <= 0
    }
}

struct ViewControllerDataModel {
    var timer: Timer?
    var navigationBarPreviousTintColor: UIColor?
}

struct UserScore: Codable {
    let name: String
    let score: Int
    let difficulty: Difficulty
    let date: Date
    
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    static func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
}

enum Difficulty: String, Codable {
    case easy
    case medium
    case hard
    
    var range: ClosedRange<Int> {
        switch self {
        case .easy:
            return 0...9
        case .medium:
            return 10...99
        case .hard:
            return 100...999
        }
    }
    
    var scores: Int {
        switch self {
        case .easy:
            return 1
        case .medium:
            return 2
        case .hard:
            return 3
        }
    }
    
    var remainingTime: Int {
        switch self {
        case .easy:
            return 2
        case .medium:
            return 2
        case .hard:
            return 2
        }
    }
    
    func key() -> String {
        switch self {
        case .easy:
            return "easyUserScore"
        case .medium:
            return "mediumUserScore"
        case .hard:
            return "hardUserScore"
        }
    }
    
    var displayName: String {
        switch self{
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard" 
        }
    }
}

enum GameState {
    case idle
    case playing
    case finished
}
