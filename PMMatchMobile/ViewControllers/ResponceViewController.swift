import UIKit

class ResponceViewController: UIViewController {
    
    var singleGame: Bool!
    
    var responceDelegate: ResponceDelegate?
    var botDelegate: BotDelegate?
    var tutorialDelegate: TutorialDelegate?
    
    var betDelegate: BetDelegate?
    
    var bet: String!
    var text: String?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var botTextLabel: UILabel!
    @IBOutlet weak var currentBetLabel: UILabel!
    @IBOutlet weak var lieButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var riseButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        configure()
    }
    
    @IBAction func lieButtonPressed(_ sender: UIButton) {
        if singleGame {
            self.dismiss(animated: true) {
                guard let bet = Int(self.bet) else { return }
                self.responceDelegate?.lie(bet, true, false)
            }
            
            if !UserDefaults.standard.bool(forKey: "tutorial") {
                UserDefaults.standard.set(true, forKey: "tutorial")
            }
        } else {
            
            self.dismiss(animated: true) {
                self.betDelegate?.lie()
            }
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        if singleGame {
            self.dismiss(animated: true) {
                if !UserDefaults.standard.bool(forKey: "tutorial") {
                    self.tutorialDelegate?.show("timer")
                    UserDefaults.standard.set(true, forKey: "tutorial")
                }
            }
        } else {
            
            self.dismiss(animated: true)
            
            if self.bet == "0" {
                self.betDelegate?.cancel()
            }
            
        }
    }
    
    @IBAction func riseButtonPressed(_ sender: UIButton) {
        if singleGame {
            guard let bet = Int(self.bet) else { return }
            let newBet = bet + pickerView.selectedRow(inComponent: 0)
            let rising = Bot.shared.betRised(newBet, bet)
            
            self.dismiss(animated: true) {
                if rising {
                    self.botDelegate?.newBet = Bot.shared.riseBet(newBet, bet)
                } else {
                    self.botDelegate?.newBet = newBet
                }
                self.responceDelegate?.rised(rising)
            }
            
            if !UserDefaults.standard.bool(forKey: "tutorial") {
                UserDefaults.standard.set(true, forKey: "tutorial")
            }
        } else {
            guard let bet = Int(self.bet) else { return }
            let newBet = bet + pickerView.selectedRow(inComponent: 0)
            
            self.dismiss(animated: true) {
                self.betDelegate?.rise(newBet: newBet)
            }
        }
    }
    
    func configure() {
        self.currentBetLabel.adjustsFontSizeToFitWidth = true
        self.currentBetLabel.minimumScaleFactor = 0.7
        
        self.containerView.layer.cornerRadius = 15
        self.lieButton.layer.cornerRadius = 5
        self.cancelButton.layer.cornerRadius = 5
        self.riseButton.layer.cornerRadius = 5
        
        self.text = "Player: I bet there " + self.bet + " or more on the table!"
        
        if self.bet == "0" {
            self.text = "Set first bet!"
            self.riseButton.setTitle("BET", for: .normal)
            self.lieButton.backgroundColor = .systemGray4
            self.lieButton.titleLabel?.textColor = .systemGray6
            self.lieButton.isUserInteractionEnabled = false
        } else if self.bet == "60" {
            self.riseButton.backgroundColor = .systemGray4
            self.riseButton.titleLabel?.textColor = .systemGray6
            self.riseButton.isUserInteractionEnabled = false
        }
        
        self.botTextLabel.text = text
    }
}

extension ResponceViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let bet = Int(self.bet) else { return 0 }
        return (61 - bet)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let bet = Int(self.bet) else { return "no title" }
        let integerTitle = bet + row
        let title = String(describing: integerTitle)
        
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            self.currentBetLabel.text = "New bet:"
            self.riseButton.backgroundColor = .systemGreen
            self.riseButton.titleLabel?.textColor = .white
            self.riseButton.isUserInteractionEnabled = true
        } else {
            self.currentBetLabel.text = "Current bet:"
            self.riseButton.backgroundColor = .systemGray4
            self.riseButton.titleLabel?.textColor = .systemGray6
            self.riseButton.isUserInteractionEnabled = false
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let bet = Int(self.bet) else { return nil }
        let integerTitle = bet + row
        let title = String(describing: integerTitle)
        
        let attributedString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return attributedString
    }
}
