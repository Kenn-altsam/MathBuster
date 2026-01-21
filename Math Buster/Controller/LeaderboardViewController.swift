import UIKit

class LeaderboardViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var allScores: [UserScoreSection] = []
    var filteredScores: [UserScoreSection] = [] {
        didSet {
            print("Filtered data updated")
            tableView.reloadData()
        }
    }
//    var dataSource: [UserScoreSection] = [] {
//        didSet {
//            print("Value of variable 'dataSource' was changed")
//            tableView.reloadData()
//        }
//    }
    
    enum FilterOption: Int {
        case all = 0
        case easy = 1
        case medium = 2
        case hard = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: ScoreTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(getUserScore), for: .valueChanged)
        
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getUserScore()
    }
    
    @objc
    func filterChanged(_ sender: UISegmentedControl) {
        applyFilter()
    }
    
    func applyFilter() {
        guard let filterOption = FilterOption(rawValue: filterSegmentedControl.selectedSegmentIndex) else {
            return
        }
        
        switch filterOption {
        case .all:
            filteredScores = allScores
        case .easy:
            filteredScores = allScores.filter { $0.title == "Easy" }
        case .medium:
            filteredScores = allScores.filter { $0.title == "Medium" }
        case .hard:
            filteredScores = allScores.filter { $0.title == "Hard" }
        }
    }

    @objc
    func getUserScore() {
        tableView.refreshControl?.endRefreshing()
    
        let easySection = createScoreSection(for: .easy)
        let mediumSection = createScoreSection(for: .medium)
        let hardSection = createScoreSection(for: .hard)
        
        self.allScores = [easySection, mediumSection, hardSection]
        
        applyFilter()
    }
    
    private func createScoreSection(for difficulty: Difficulty) -> UserScoreSection {
        var scoreList: [UserScore] = ViewController.getAllUserScores(level: difficulty)
        scoreList.sort { $0.score > $1.score }
        return UserScoreSection(list: scoreList, title: difficulty.displayName)
    }
    
//    func getSingleUserText(indexPath: IndexPath) -> String? {
//        let userScore: UserScore = filteredScores[indexPath.section].list[indexPath.row]
//        
//        let text = "Name: \(userScore.name), Score: \(userScore.score), Difficulty: \(userScore.difficulty.displayName), Date: \(String(describing: userScore.formattedDate))"
//        return text
//    }
}

//MARK: UITableViewDatasource & UITableViewDelegate
extension LeaderboardViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredScores.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredScores[section].list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.identifier, for: indexPath) as! ScoreTableViewCell
        let userScore = filteredScores[indexPath.section].list[indexPath.row]
        cell.configure(with: userScore)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let viewController = ScoreDetailViewController()
//        viewController.text = getSingleUserText(indexPath: indexPath)
//        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredScores[section].title
    }
}


struct UserScoreSection {
    let list: [UserScore]
    let title: String
}
