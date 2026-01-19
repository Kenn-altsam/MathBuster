import Foundation

struct GameEngine {
    var score: Int
    var remainingTime: Int
    let difficulty: Difficulty
    
    private(set) var problemText: String?
    private(set) var expectedResult: Double?
    private let operators: [String] = ["+", "/", "*", "-"]
    
    init(difficulty: Difficulty) { // initializer (constructor) of the parameters to get the initial values
        self.difficulty = difficulty
        self.score = 0
        self.remainingTime = difficulty.remainingTime
        self.problemText = nil
        self.expectedResult = nil
        generateProblem()
    }
    
    mutating func generateProblem() { // mutating keyword allows to modify the data of the instance of a struct or enum
        
    }
}

enum Difficulty {
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
    
    var key: String {
        switch self {
        case .easy:
            return "easyUserScore"
        case .medium:
            return "mediumUserScore"
        case .hard:
            return "hardUserScore"
        }
    }
    
    var remainingTime: Int {
        switch self {
        case .easy:
            return 30
        case .medium:
            return 45
        case .hard:
            return 60
        }
    }
}

