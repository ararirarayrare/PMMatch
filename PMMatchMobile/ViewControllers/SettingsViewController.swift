import UIKit

class SettingsViewController: UIViewController {
        
    var formatSelectedIndex: Int! {
        didSet {
                        
            switch formatSelectedIndex {
            case 0:
                self.selected0ImageView.isHidden = false
            case 1:
                self.selected1ImageView.isHidden = false
            case 2:
                self.selected2ImageView.isHidden = false
            default:
                break
            }
            
            guard oldValue != nil else { return }
            guard oldValue != formatSelectedIndex else { return }
            
            sound("selection")
            
            switch oldValue {
            case 0:
                self.selected0ImageView.isHidden = true
            case 1:
                self.selected1ImageView.isHidden = true
            case 2:
                self.selected2ImageView.isHidden = true
            default:
                break
            }
            
        }
    }
    
    var difficultySelectedIndex: Int! {
        didSet {
            
            switch difficultySelectedIndex {
            case 0:
                self.selected0.isHidden = false
            case 1:
                self.selected1.isHidden = false
            case 2:
                self.selected2.isHidden = false
            default:
                break
            }
            
            guard oldValue != nil else { return }
            guard oldValue != difficultySelectedIndex else { return }
            
            sound("selection")
            
            switch oldValue {
            case 0:
                self.selected0.isHidden = true
            case 1:
                self.selected1.isHidden = true
            case 2:
                self.selected2.isHidden = true
            default:
                break
            }
            
        }
    }

            // FORMAT SEGMENT
    @IBOutlet weak var formatSegmentImageView: UIImageView!
    
    @IBOutlet weak var selected0ImageView: UIImageView!
    @IBOutlet weak var bo3Label: UILabel!
    
    @IBOutlet weak var selected1ImageView: UIImageView!
    @IBOutlet weak var bo5Label: UILabel!
    
    @IBOutlet weak var selected2ImageView: UIImageView!
    @IBOutlet weak var bo7Label: UILabel!
    
    
            //DIFFICULTY SEGMENT
    @IBOutlet weak var difficultySegmentImageView: UIImageView!
    
    @IBOutlet weak var selected0: UIImageView!
    @IBOutlet weak var easyLabel: UILabel!
    
    @IBOutlet weak var selected1: UIImageView!
    @IBOutlet weak var mediumLabel: UILabel!
    
    @IBOutlet weak var selected2: UIImageView!
    @IBOutlet weak var hardLabel: UILabel!
    
    
    
    
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupGestures()
    }
    
    @objc func playTapped() {
        UserDefaults.standard.set(formatSelectedIndex, forKey: "format")
        UserDefaults.standard.set(difficultySelectedIndex, forKey: "difficulty")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: GameViewController.self)
        guard let gameViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? GameViewController else { return }
        
        sound("click")
        self.navigationController?.pushViewController(gameViewController, animated: true)
    }
    
    @objc func backTapped() {
        sound("click")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapped0() {
        self.formatSelectedIndex = 0
    }
    
    @objc func tapped1() {
        self.formatSelectedIndex = 1
    }
    
    @objc func tapped2() {
        self.formatSelectedIndex = 2
    }
    
    @objc func difficulty0() {
        self.difficultySelectedIndex = 0
    }
    
    @objc func difficulty1() {
        self.difficultySelectedIndex = 1
    }
    
    @objc func difficulty2() {
        self.difficultySelectedIndex = 2
    }
    
    
    func configure() {
        self.playImageView.image = UIImage(named: "START")
        
        self.selected0ImageView.isHidden = true
        self.bo3Label.isUserInteractionEnabled = true
        
        self.selected1ImageView.isHidden = true
        self.bo5Label.isUserInteractionEnabled = true
        
        self.selected2ImageView.isHidden = true
        self.bo7Label.isUserInteractionEnabled = true
        
        self.selected0.isHidden = true
        self.easyLabel.isUserInteractionEnabled = true
        
        self.selected1.isHidden = true
        self.mediumLabel.isUserInteractionEnabled = true
        
        self.selected2.isHidden = true
        self.hardLabel.isUserInteractionEnabled = true
        
        self.formatSelectedIndex = 0
        self.difficultySelectedIndex = 0
    }
    
    func setupGestures() {
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playTapped))
        playTap.numberOfTapsRequired = 1
        self.playImageView.isUserInteractionEnabled = true
        self.playImageView.addGestureRecognizer(playTap)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTapped))
        backTap.numberOfTapsRequired = 1
        self.backImageView.isUserInteractionEnabled = true
        self.backImageView.addGestureRecognizer(backTap)
        
        setupFormatGestures()
        setupDifficultyGestures()
    }
    
    func setupFormatGestures() {
        let tap0 = UITapGestureRecognizer(target: self, action: #selector(tapped0))
        tap0.numberOfTapsRequired = 1
        self.bo3Label.addGestureRecognizer(tap0)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapped1))
        tap1.numberOfTapsRequired = 1
        self.bo5Label.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tapped2))
        tap2.numberOfTapsRequired = 1
        self.bo7Label.addGestureRecognizer(tap2)
    }
    
    func setupDifficultyGestures() {
        let tap0 = UITapGestureRecognizer(target: self, action: #selector(difficulty0))
        tap0.numberOfTapsRequired = 1
        self.easyLabel.addGestureRecognizer(tap0)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(difficulty1))
        tap1.numberOfTapsRequired = 1
        self.mediumLabel.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(difficulty2))
        tap2.numberOfTapsRequired = 1
        self.hardLabel.addGestureRecognizer(tap2)
    }
    
}
