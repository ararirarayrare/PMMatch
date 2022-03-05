import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity

class MPGameViewController: UIViewController {
    
    var gameDelegate: GameDelegate?
        
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var mcBrowser: MCBrowserViewController!
    
    var scene = MPGameScene()
    
    var bet = 0
    
    var secondPlayerCubesNames: [String]!
    
    var myCount: Int!
    var realCount: Int!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var playerTextLabel: UILabel!
    @IBOutlet weak var playerTextView: UIView!
    @IBOutlet weak var betImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupGestures()

        setupConnectivity()
        setupHostSession()
        presentMCBrowser()
    }
    
    
    @objc func betTapped() {
        self.pushResponceViewController()
        if self.bet == 0 {
            self.showWhosTurn()
        }
    }
    
    func configure() {
        self.betImageView.image = UIImage(named: "bet")
        self.betImageView.isHidden = true
        self.playerTextView.isHidden = true
        self.playerTextView.alpha = 0
    }
    
    func setupGestures() {
        let betTap = UITapGestureRecognizer(target: self, action: #selector(betTapped))
        betTap.numberOfTapsRequired = 1
        self.betImageView.isUserInteractionEnabled = true
        self.betImageView.addGestureRecognizer(betTap)
    }
    
    func loadGame() {
        if let view = self.view as! SKView? {
            scene.anchorPoint = .init(x: 0.5, y: 0.5)
            scene.scaleMode = .resizeFill
            
            self.gameDelegate = scene
            scene.sendDelegate = self
            scene.gameOverDelegate = self
            
            view.presentScene(scene)
        }
    }
    
    func pushResponceViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: ResponceViewController.self)
        guard let responceViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? ResponceViewController else { return }
        
        responceViewController.bet = String(describing: self.bet)
        responceViewController.singleGame = false
        
        responceViewController.betDelegate = self
        
        self.present(responceViewController, animated: true)
    }
    
    func showCloud(_ bool: Bool, lie: Bool) {
        self.playerTextLabel.adjustsFontSizeToFitWidth = true
        self.playerTextLabel.minimumScaleFactor = 0.7
        if lie {
            self.playerTextLabel.text = "Player: I think you're lying!"
        } else {
            self.playerTextLabel.text = "Player: I bet there " + String(describing: self.bet) + " or more on the table!"
        }
        var alpha: CGFloat = 0
        if bool {
            self.playerTextView.isHidden = false
            alpha = 1
        }
        UIView.animate(withDuration: 0.5) {
            self.playerTextView.alpha = alpha
        }
    }
        
}

extension MPGameViewController: MCSessionDelegate, MCBrowserViewControllerDelegate {
    func presentMCBrowser() {
        let browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "game")
        
        mcBrowser = MCBrowserViewController(browser: browser, session: self.mcSession)
        mcBrowser.delegate = self
        mcBrowser.minimumNumberOfPeers = 2
        mcBrowser.maximumNumberOfPeers = 2
        
        mcBrowser.modalTransitionStyle = .flipHorizontal
        mcBrowser.modalPresentationStyle = .overFullScreen
        present(mcBrowser, animated: true)
    }
    
    func setupConnectivity() {
        peerID = MCPeerID(displayName:  UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    func setupHostSession() {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "game", discoveryInfo: nil, session: self.mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func send(_ message: MPMessage) {
        do {
            guard let data = try? JSONEncoder().encode(message) else { return }
            try self.mcSession.send(data, toPeers: self.mcSession.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func send(_ dictionary: [MPMessage: Int]) {
        do {
            guard let data = try? JSONEncoder().encode(dictionary) else { return }
            try self.mcSession.send(data, toPeers: self.mcSession.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func send(_ array: [String]) {
        do {
            guard let data = try? JSONEncoder().encode(array) else { return }
            try self.mcSession.send(data, toPeers: self.mcSession.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: - MC
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            print("notConnected")
        case .connecting:
            print("connecting")
        case .connected:
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.backgroundImageView.isHidden = true
                self.activityIndicator.stopAnimating()
                self.loadGame()
                self.betImageView.isHidden = false
                guard self.mcBrowser != nil else { return }
                self.browserViewControllerDidFinish(self.mcBrowser)
                self.mcAdvertiserAssistant.stop()
            }
            print("CONNECTED")
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        do {
            let string = try decoder.decode(MPMessage.self, from: data)
            
            switch string {
            case .turn:
                DispatchQueue.main.async {
                    if self.bet == 0 {
                        self.betImageView.isHidden = true
                    }
                }
                gameDelegate?.showWhosTurn()
                
            case .cancel:
                DispatchQueue.main.async {
                    if self.bet == 0 {
                        self.betImageView.isHidden = false
                    }
                }
                gameDelegate?.stopShowingWhosTurn()
                
            case .lie:
                self.gameDelegate?.stopShowingWhosTurn()
                DispatchQueue.main.async {
                    self.showCloud(true, lie: true)
                }
                self.gameDelegate?.openAllCups(secondPlayerCubesNames: self.secondPlayerCubesNames, lastBet: self.bet, myBet: true)
            default:
                break
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let dictionary = try decoder.decode(Dictionary<MPMessage, Int>.self, from: data)
            guard let item = dictionary.first else { return }
            
            switch item.key {
            case .newBet:
                self.bet = item.value
                self.gameDelegate?.stopShowingWhosTurn()
                
                DispatchQueue.main.async {
                    self.betImageView.isHidden = false
                    self.showCloud(true, lie: false)
                }
                
            case .playerCount:
                self.realCount = self.myCount + item.value
                
            default:
                break
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let array = try decoder.decode([String].self, from: data)
            
            self.secondPlayerCubesNames = array
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension MPGameViewController: BetDelegate {
    func lie() {
        self.betImageView.isHidden = true
        self.showCloud(false, lie: true)
        self.gameDelegate?.stopShowingWhosTurn()
        self.send(.lie)
        self.gameDelegate?.openAllCups(secondPlayerCubesNames: self.secondPlayerCubesNames, lastBet: self.bet, myBet: false)
    }
    
    func cancel() {
        self.send(.cancel)
    }
    
    func rise(newBet: Int) {
        self.showCloud(false, lie: false)
        self.bet = newBet
        let dictionary: [MPMessage : Int] = [.newBet : newBet]
        self.send(dictionary)
        DispatchQueue.main.async {
            self.betImageView.isHidden = true
        }
        self.gameDelegate?.showWhosTurn()
    }
}


extension  MPGameViewController: SendDelegate {
    func showWhosTurn() {
        self.send(.turn)
    }
    
    func setMyCount(_ myCount: Int) {
        self.myCount = myCount
    }
    
    func setRealCount(_ myCubesNames: [String]) {
        guard let count = self.myCount else {
            print("ERROR")
            return
        }
        let dictionary: [MPMessage : Int]  = [.playerCount: count]
        self.send(dictionary)
        self.send(myCubesNames)
    }
}


extension MPGameViewController: GameOverDelegate {
    func presentScoreViewController(playerWon: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: GameOverViewController.self)
        guard let gameOverViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? GameOverViewController else { return }
        if playerWon {
            gameOverViewController.won = "win"
        } else {
            gameOverViewController.won = "lose"
        }
        
        self.navigationController?.pushViewController(gameOverViewController, animated: true)
    }
}

