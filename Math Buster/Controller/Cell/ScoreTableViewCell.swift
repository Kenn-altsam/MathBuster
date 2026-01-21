//
//  ScoreTableViewCell.swift
//  Math Buster
//
//  Created by Zhangali Pernebayev on 07.11.2022.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

    static let identifier: String = "ScoreTableViewCellIdentifier"
    @IBOutlet weak var scoreTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scoreTextLabel.text = nil
        scoreTextLabel.numberOfLines = 0 // Allow multiple lines
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Reset to inital value
        scoreTextLabel.text = nil
    }
    
    func configure(with userScore: UserScore) {
        scoreTextLabel.text = """
            Name: \(userScore.name)
            Score: \(userScore.score) | Difficulty: \(userScore.difficulty.displayName)
            Date: \(userScore.formattedDate())
            """
    }
}
