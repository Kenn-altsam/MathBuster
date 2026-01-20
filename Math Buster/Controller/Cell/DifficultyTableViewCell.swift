import UIKit

class DifficultyTableViewCell: UITableViewCell {
    
    static let levelIdentifier: String = "DifficultyTableViewCellIdentifier"
    
    
    @IBOutlet weak var levelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        levelLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        levelLabel.text = nil
    }
    
}
