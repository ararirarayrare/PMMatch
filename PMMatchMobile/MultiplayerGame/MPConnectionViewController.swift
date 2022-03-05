import UIKit

class MPConnectionViewController: UIViewController {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var connectImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupGestures()
    }
    
    @objc func backTapped() {
        sound("click")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func connectTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: MPGameViewController.self)
        guard let mpGameViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? MPGameViewController else { return }
                
        sound("click")
        self.navigationController?.pushViewController(mpGameViewController, animated: true)
    }
    
    func configure() {
        self.connectImageView.image = UIImage(named: "connect")
        self.label.adjustsFontSizeToFitWidth = true
        self.label.minimumScaleFactor = 0.6
        self.label.text = "Greetings!\n\nYou can play one to one with another player near you. Connect to the same local network or turn on Bluetooth!"
    }
    
    func setupGestures() {
        let connectTap = UITapGestureRecognizer(target: self, action: #selector(connectTapped))
        connectTap.numberOfTapsRequired = 1
        self.connectImageView.isUserInteractionEnabled = true
        self.connectImageView.addGestureRecognizer(connectTap)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTapped))
        backTap.numberOfTapsRequired = 1
        self.backImageView.isUserInteractionEnabled = true
        self.backImageView.addGestureRecognizer(backTap)
    }
    
    
}
