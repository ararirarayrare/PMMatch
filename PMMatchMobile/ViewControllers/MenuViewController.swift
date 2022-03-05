import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var bluetoothImageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.removeObject(forKey: "playerScore")
        UserDefaults.standard.removeObject(forKey: "botScore")
    }
    
    @objc func infoTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: TutorialViewController.self)
        guard let tutorialViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? TutorialViewController else { return }
        tutorialViewController.show = "info"
        self.present(tutorialViewController, animated: true)
    }
    
    
    @objc func bluetoothTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: MPConnectionViewController.self)
        guard let mpConnectionViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? MPConnectionViewController else { return }
                
        sound("click")
        self.navigationController?.pushViewController(mpConnectionViewController, animated: true)
    }
    
    
    @objc func playTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: SettingsViewController.self)
        guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? SettingsViewController else { return }
        
        sound("click")
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    func configure() {
        self.navigationController?.navigationBar.isHidden = true
        self.infoImageView.image = UIImage(named: "info")
        self.playImageView.image = UIImage(named: "single")
        self.bluetoothImageView.image = UIImage(named: "multiplayer")
    }
    
    func setupGestures() {
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playTapped))
        playTap.numberOfTapsRequired = 1
        self.playImageView.isUserInteractionEnabled = true
        self.playImageView.addGestureRecognizer(playTap)
        
        let infoTap = UITapGestureRecognizer(target: self, action: #selector(infoTapped))
        infoTap.numberOfTapsRequired = 1
        self.infoImageView.isUserInteractionEnabled = true
        self.infoImageView.addGestureRecognizer(infoTap)
        
        let bluetoothTap = UITapGestureRecognizer(target: self, action: #selector(bluetoothTapped))
        bluetoothTap.numberOfTapsRequired = 1
        self.bluetoothImageView.isUserInteractionEnabled = true
        self.bluetoothImageView.addGestureRecognizer(bluetoothTap)
    }
}
