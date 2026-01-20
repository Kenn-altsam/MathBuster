//
//  ViewController.swift
//  Math Buster
//
//  Created by Zhangali Pernebayev on 13.10.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var timerContainerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resultField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var dataModel: ViewControllerDataModel = ViewControllerDataModel()
    var gameEngine: GameEngine!
    
    var selectedDifficulty: Difficulty = .easy
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        initializeGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataModel.navigationBarPreviousTintColor = navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !gameEngine.isGameOver(){
            scheduleTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.tintColor = dataModel.navigationBarPreviousTintColor
        
        dataModel.timer?.invalidate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        dataModel.timer?.invalidate()
    }

    func setupUI() {
//        navigationItem.title = "New Title"
        timerContainerView.layer.cornerRadius = 5
        resultField.keyboardType = .decimalPad
    }
    
    func initializeGame() {
//        let difficulty = getDifficultyFromSegmentedControl()
        gameEngine = GameEngine(difficulty: selectedDifficulty)
        gameEngine.generateProblem()
        updateUI()
    }
    
//    func getDifficultyFromSegmentedControl() -> Difficulty {
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            return .easy
//        case 1:
//            return .medium
//        case 2:
//            return .hard
//        default:
//            return .easy
//        }
//    }
    
    func updateUI() {
        scoreLabel.text = "Score: \(gameEngine.score)"
        problemLabel.text = gameEngine.problemText
        
        let seconds: String = String(format: "%02d", gameEngine.remainingTime)
        timerLabel.text = "00 : \(seconds)"
        
        let totalTime = gameEngine.difficulty.remainingTime
        progressView.progress = Float(totalTime - gameEngine.remainingTime) / Float(totalTime)
        print("progressView.progress: \(progressView.progress)")
    }
    
    func scheduleTimer() {
        dataModel.timer?.invalidate()
        dataModel.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerUI), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimerUI() {
        gameEngine.decrementTime()
        updateUI()
        
        if gameEngine.isGameOver() {
            finishTheGame()
        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        guard let text = resultField.text else {
            print("Text is nil")
            return
        }
        guard !text.isEmpty else {
            print("Text is empty")
            return
        }
        guard let newResult = Double(text) else {
            print("Couldn't convert text: \(text) to Double")
            return
        }
        
        if gameEngine.checkAnswer(newResult) {
            print("Correct answer!")
        }else{
            print("Incorrect answer!")
        }
        
        gameEngine.generateProblem()
        updateUI()
        resultField.text = nil
    }
    
    @IBAction func restartPressed(_ sender: Any) {
        restart()
    }
    
    func restart() {
        initializeGame()
        scheduleTimer()
        
        resultField.isEnabled = true
        submitButton.isEnabled = true
    }
    
//    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
//        restart()
//    }
    
    func finishTheGame() {
        dataModel.timer?.invalidate()
        resultField.isEnabled = false
        submitButton.isEnabled = false
        
        askForName()
    }
    
    func askForName() {
        let alertController = UIAlertController(title: "Game is Over!", message: "Save your score: \(gameEngine.score)", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter your name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alertController.textFields?.first else {
                print("Textfield is absent")
                return
            }
            guard let text = textField.text, !text.isEmpty else {
                print("Text is nil or empty")
                return
            }
            print("Name: \(text)")
            
            //TO DO: Save user score record permanently on device
//            self.saveUserScore(name: text)
            self.saveUserScoreAsStruct(name: text)
            
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
//        let skipAction = UIAlertAction(title: "Skip", style: .destructive)
//        alertController.addAction(skipAction)
        
        present(alertController, animated: true)
    }
    
    func saveUserScoreAsStruct(name: String) {
        let userScore: UserScore = UserScore(name: name, score: gameEngine.score)
        let difficulty = gameEngine.difficulty
        
        let userScoreArray: [UserScore] = ViewController.getAllUserScores(level: difficulty) + [userScore]
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(userScoreArray)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: difficulty.key())
        } catch {
            print("Couldn't encode given [Userscore] into data with error: \(error.localizedDescription)")
        }
    }
    
    static func getAllUserScores(level: Difficulty) -> [UserScore] {
        var result: [UserScore] = []
        
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.object(forKey: level.key()) as? Data {
            do {
                let decoder = JSONDecoder()
                result = try decoder.decode([UserScore].self, from: data)
            } catch {
                print("could'n decode given data to [Userscore] with error: \(error.localizedDescription)")
            }
        }
        return result
    }
    
//    func saveUserScore(name: String) {
//        let userScore: [String: Any] = ["name": name, "score": gameEngine.score]
//        let userScoreArray: [[String: Any]] = getUserScoreArray() + [userScore]
//        
//        let userDefaults = UserDefaults.standard
//        userDefaults.set(userScoreArray, forKey: ViewControllerDataModel.userScoreKey)
//    }
//    
//    func getUserScoreArray() -> [[String: Any]] {
//        let userDefaults = UserDefaults.standard
//        let array = userDefaults.array(forKey: ViewControllerDataModel.userScoreKey) as? [[String: Any]]
//        return array ?? []
//    }
}
