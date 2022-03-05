import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var responceDelegate: ResponceDelegate?
    var pauseDelegate: PauseDelegate?
    
    var showTutorial: Bool!
        
    var scene = GameScene()
    
    var botCount: Int = 0
    var playerCount: Int = 0
    var newBet: Int = 0
    var firstBet: Int = 0
    
    
    
    @IBOutlet weak var botTextView: UIView!
    @IBOutlet weak var botTextLabel: UILabel!
    @IBOutlet weak var tapToResponceLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        
        let shown = UserDefaults.standard.bool(forKey: "tutorial")
        if !shown {
            showTutorial = true
        } else {
            showTutorial = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.botTextView.isHidden = true
        newBet = 0
        loadGame()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scene.workItems.forEach { item in
            item.cancel()
        }
        self.scene.removeAllActions()
        self.scene.removeAllChildren()
    }
    
    @objc func responce() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: ResponceViewController.self)
        guard let responceViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? ResponceViewController else { return }
        
        var bet = ""
        if newBet == 0 {
            bet = String(describing: firstBet)
        } else {
            bet = String(describing: newBet)
        }
        responceViewController.singleGame = true
        responceViewController.tutorialDelegate = self
        responceViewController.botDelegate = self
        responceViewController.responceDelegate = self
        responceViewController.bet = bet
        responceViewController.text = "Bot: I bet there \(bet) or more on the table!"
        self.present(responceViewController, animated: true)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupGestures() {
        let responceTap = UITapGestureRecognizer(target: self, action: #selector(responce))
        responceTap.numberOfTapsRequired = 1
        self.tapToResponceLabel.isUserInteractionEnabled = true
        self.tapToResponceLabel.addGestureRecognizer(responceTap)
    }
    
    func loadGame() {
        if let view = self.view as! SKView? {
            scene = GameScene()
            scene.anchorPoint = .init(x: 0.5, y: 0.5)
            scene.scaleMode = .resizeFill
            
            scene.tutorial = showTutorial
            
            scene.tutorialDelegate = self
            scene.botDelegate = self
            scene.gameOverDelegate = self
            self.responceDelegate = scene
            self.pauseDelegate = scene
            view.presentScene(scene)
        }
    }
}

extension GameViewController: BotDelegate {
    func showCloud(_ firstBet: Bool, _ lie: Bool) {
        self.botTextView.alpha = 0
        self.botTextView.isHidden = false
        
        self.botTextLabel.adjustsFontSizeToFitWidth = true
        self.botTextLabel.minimumScaleFactor = 0.7
        
        if !lie {
            self.tapToResponceLabel.isHidden = false
            var bet = newBet
            if firstBet {
                bet = Bot.shared.setFirstBet(botCount, playerCount)
                self.firstBet = bet
            }
            self.botTextLabel.font = UIFont(name: "Copperplate Bold", size: 20)
            self.botTextLabel.text = "I bet there \(bet) or more on the table!"
        } else {
            self.tapToResponceLabel.isHidden = true
            self.botTextLabel.font = UIFont(name: "Copperplate Bold", size: 30)
            self.botTextLabel.text = "You're liying!!"
            self.responceDelegate?.lie(newBet, false, true)
        }
        UIView.animate(withDuration: 0.5) {
            self.botTextView.alpha = 1
        }
    }
}

extension GameViewController: TutorialDelegate {
    func show(_ label: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: TutorialViewController.self)
        guard let tutorialViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? TutorialViewController else { return }
        tutorialViewController.pauseDelegate = self
        
        tutorialViewController.show = label
        
        self.present(tutorialViewController, animated: true) {
            guard label == "timer" else { return }
            self.pauseGame(true, false)
        }
    }
}

extension GameViewController: PauseDelegate {
    func pauseGame(_ pause: Bool, _ beginning: Bool) {
        self.pauseDelegate?.pauseGame(pause, beginning)
    }
}

extension GameViewController: ResponceDelegate {
    func lie(_ lastBet: Int,_ playersBet: Bool,_ lie: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.botTextView.alpha = 0
        } completion: { _ in
            self.botTextView.isHidden = true
            self.responceDelegate?.lie(lastBet, playersBet, lie)
        }
    }
    
    func rised(_ botsRising: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.botTextView.alpha = 0
        } completion: { _ in
            self.responceDelegate?.rised(botsRising)
        }
    }
}

extension GameViewController: GameOverDelegate {    
    func presentScoreViewController(playerWon: Bool) {
        let storyboad = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: ScoreViewController.self)
        guard let scoreVC = storyboad.instantiateViewController(withIdentifier: identifier) as? ScoreViewController else { return }
        
        if playerWon {
            var playerScore = UserDefaults.standard.integer(forKey: "playerScore")
            playerScore += 1
            UserDefaults.standard.set(playerScore, forKey: "playerScore")
        } else {
            var botScore = UserDefaults.standard.integer(forKey: "botScore")
            botScore += 1
            UserDefaults.standard.set(botScore, forKey: "botScore")
        }
        scoreVC.won = playerWon
        self.navigationController?.pushViewController(scoreVC, animated: true)
    }
}
