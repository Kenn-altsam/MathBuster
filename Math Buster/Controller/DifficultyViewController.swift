//
//  DifficultyViewController.swift
//  Math Buster
//
//  Created by Altynbek Kenzhe on 20.01.2026.
//

import UIKit

class DifficultyViewController: UIViewController {
    
    @IBOutlet weak var levelTableView: UITableView!
    
    let difficulties: [Difficulty] = [.easy, .medium, .hard]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        levelTableView.register(UINib(nibName: "DifficultyTableViewCell", bundle: nil), forCellReuseIdentifier: DifficultyTableViewCell.levelIdentifier)
        levelTableView.dataSource = self
        levelTableView.delegate = self
        levelTableView.rowHeight = 100

        // Do any additional setup after loading the view.
    }
}

extension DifficultyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = levelTableView.dequeueReusableCell(withIdentifier: DifficultyTableViewCell.levelIdentifier, for: indexPath) as! DifficultyTableViewCell
        
        let difficulty = difficulties[indexPath.row]
        
        switch difficulty {
        case .easy:
            cell.levelLabel.text = "Easy"
        case .medium:
            cell.levelLabel.text = "Medium"
        case .hard:
            cell.levelLabel.text = "Hard"
        }
        
        return cell
    }
}

extension DifficultyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        levelTableView.deselectRow(at: indexPath, animated: true)
    
        let selectedDifficulty = difficulties[indexPath.row]
        
        performSegue(withIdentifier: "startGameScreen", sender: selectedDifficulty)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGameScreen",
           let gameVC = segue.destination as? ViewController,
           let difficulty = sender as? Difficulty {
            gameVC.selectedDifficulty = difficulty
        }
    }
}
