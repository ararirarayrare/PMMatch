import UIKit

class ScoreViewController: UIViewController {

    
    @IBOutlet weak var wonImageView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var won: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        if won {
            self.wonImageView.image = UIImage(named: "win")
        } else {
            self.wonImageView.image = UIImage(named: "lose")
        }
        let playerScore = UserDefaults.standard.integer(forKey: "playerScore")
        let botScore = UserDefaults.standard.integer(forKey: "botScore")
        
        var winsRequired = 0
        
        switch UserDefaults.standard.integer(forKey: "format") {
        case 0:
            winsRequired = 2
        case 1:
            winsRequired = 3
        case 2:
            winsRequired = 4
        default:
            break
        }
        
        let gameOver = playerScore == winsRequired || botScore == winsRequired
        
        let score = String(describing: playerScore) + " : " + String(describing: botScore)
        self.scoreLabel.text = "Score: \(score)"
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if gameOver {
                if botScore == winsRequired {
                    self.pushGameOverViewController(false)
                }
                if playerScore == winsRequired {
                    self.pushGameOverViewController(true)
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func pushGameOverViewController(_ won: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: GameOverViewController.self)
        guard let gameOverViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? GameOverViewController else { return }
        if won {
            gameOverViewController.won = "win"
        } else {
            gameOverViewController.won = "lose"
        }
        
        self.navigationController?.pushViewController(gameOverViewController, animated: false)
    }
    
}
