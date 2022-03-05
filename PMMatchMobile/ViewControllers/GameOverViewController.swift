import UIKit

class GameOverViewController: UIViewController {
    
    var won: String!
    var singleGame: Bool = false

    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var wonImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupGestures()
    }
    
    @objc func playTapped() {
        sound("click")
        if singleGame {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.viewControllers.forEach { vc in
                if let connectionVC = vc as? MPConnectionViewController {
                    self.navigationController?.popToViewController(connectionVC, animated: true)
                }
            }
        }
    }

    @objc func menuTapped() {
        sound("click")
        self.navigationController?.popToRootViewController(animated: true)
    }

    func configure() {
        self.wonImageView.image = UIImage(named: won)
        self.menuImageView.image = UIImage(named: "menu")
        self.playImageView.image = UIImage(named: "again")

        guard let viewControllers = self.navigationController?.viewControllers else { return }
                
        var index = 0
        viewControllers.forEach { vc in
            if let _ = vc as? ScoreViewController {
                self.navigationController?.viewControllers.remove(at: index)
            }
            index += 1
        }
        
        UserDefaults.standard.removeObject(forKey: "playerScore")
        UserDefaults.standard.removeObject(forKey: "botScore")
    }
    
    func setupGestures() {
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(menuTapped))
        menuTap.numberOfTapsRequired = 1
        self.menuImageView.isUserInteractionEnabled = true
        self.menuImageView.addGestureRecognizer(menuTap)
        
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playTapped))
        playTap.numberOfTapsRequired = 1
        self.playImageView.isUserInteractionEnabled = true
        self.playImageView.addGestureRecognizer(playTap)
    }
    
}
