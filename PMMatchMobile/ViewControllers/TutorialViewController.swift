import UIKit

class TutorialViewController: UIViewController {
    
    var pauseDelegate: PauseDelegate?

    var show: String!
    
    @IBOutlet weak var responceLabel: UILabel!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupGestures()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.blurEffect.layer.masksToBounds = true
        self.blurEffect.layer.cornerRadius = 15
    }
    
    @objc func tapped() {
        self.dismiss(animated: true) {
            var beginning = false
            if self.show == "cup" {
                beginning = true
            }
            self.pauseDelegate?.pauseGame(false, beginning)
        }
    }
    
    func configure() {
        self.blurEffect.isHidden = true
        self.responceLabel.isHidden = true
        self.responceLabel.adjustsFontSizeToFitWidth = true
        self.responceLabel.minimumScaleFactor = 0.5
        
        switch show {
        case "info":
            blurEffect.isHidden = false
            responceLabel.textColor = UIColor(red: 220/255, green: 220/255, blue: 72/255, alpha: 1)
            responceLabel.text = "Game rules:\n\nBoth players shake cups with dice inside. The task is to place bets that the sum of the values of all cubes on the table is greater than 'X'.\n\nX - is your bet"
        case "cup":
            responceLabel.text = "You may tap on your cup to check or hide your dice"
        case "responce":
            responceLabel.text = "Tap to responce on Bots bet!"
        case "timer":
            responceLabel.text = "Don't forget about timer on in the upper right corner!"
        default:
            break
        }
        responceLabel.isHidden = false
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
    }
}
