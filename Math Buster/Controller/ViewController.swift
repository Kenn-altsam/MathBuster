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
    
    var dataModel: ViewControllerDataModel = ViewControllerDataModel()
    var viewModel: GameViewModel!
    var selectedDifficulty: Difficulty = .easy

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.stopGame()
        dataModel.navigationBarPreviousTintColor = navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.currentState == .idle {
            viewModel.startGame()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.stopGame()
        navigationController?.navigationBar.tintColor = dataModel.navigationBarPreviousTintColor
    }
    
    func setUpViewModel() {
        viewModel = GameViewModel(difficulty: selectedDifficulty)
        
        viewModel.onStateChanged = { [weak self] state in
            self?.updateUIForGameState(state)
        }
        
        viewModel.onScoreChanged = { [weak self] score in
            self?.scoreLabel.text = "Score: \(score)"
        }
        
        viewModel.onTimeChanged = { [weak self] remainingTime in
            self?.updateTimerUI(remainingTime)
        }
        
        viewModel.onProblemChanged = { [weak self] problemText in
            self?.problemLabel.text = problemText
        }
        
        viewModel.onGameOver = { [weak self] finalScore in
            self?.showGameOverAlert(score: finalScore)
        }
    }

    func setupUI() {
        timerContainerView.layer.cornerRadius = 5
        resultField.keyboardType = .decimalPad
    }
    
    @objc
    func updateTimerUI(_ remainingTime: Int) {
        let seconds: String = String(format: "%02d", remainingTime)
        timerLabel.text = "00 : \(seconds)"
        
        let totalTime = viewModel.totalTime
        progressView.progress = Float(totalTime - remainingTime) / Float(totalTime)
        print("progressView.progress: \(progressView.progress)")
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
        
        viewModel.submitAnswer(newResult)
        
        resultField.text = nil
    }
    
    @IBAction func restartPressed(_ sender: Any) {
        viewModel.restart()
    }
    
    func showGameOverAlert(score: Int) {
        let alertController = UIAlertController(title: "Game is Over!", message: "Save your score: \(score)", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter your name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alertController.textFields?.first, let name = textField.text, !name.isEmpty else {
                print("Text is nil or empty")
                return
            }
            self.saveScore(name: name)
        }
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func saveScore(name: String) {
        let userScore: UserScore = UserScore(name: name, score: viewModel.currentScore, difficulty: viewModel.difficulty, date: Date())
        
        var userScoreArray = ViewController.getAllUserScores(level: viewModel.difficulty)
        userScoreArray.append(userScore)
        userScoreArray.sort { $0.score > $1.score }
        
        if userScoreArray.count > 10 {
            userScoreArray = Array(userScoreArray.prefix(10))
        }
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(userScoreArray)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: viewModel.difficulty.key())
            print("Successfully saved \(userScoreArray.count) scores for \(viewModel.difficulty.displayName)")
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
                print("couldn't decode given data to [Userscore] with error: \(error.localizedDescription)")
            }
        }
        return result
    }
}

extension ViewController {
    func updateUIForGameState(_ state: GameState) {
        switch state {
        case .idle:
            problemLabel.text = "Ready to start?"
            resultField.isEnabled = false
            submitButton.isEnabled = false
            restartButton.setTitle("Start Game", for: .normal)
            
        case .playing:
            resultField.isEnabled = true
            submitButton.isEnabled = true
            restartButton.setTitle("Restart", for: .normal)
            
        case .finished:
            resultField.isEnabled = false
            submitButton.isEnabled = false
            problemLabel.text = "Game Over!"
            
        }
    }
}
