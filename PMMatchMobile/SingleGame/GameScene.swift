import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var botDelegate: BotDelegate?
    var gameOverDelegate: GameOverDelegate?
    var tutorialDelegate: TutorialDelegate?
    
    var workItems: [DispatchWorkItem] = []
    
    var aspectRatio: CGFloat!
    
    var tutorial: Bool!
    
    var gameStarted: Bool = false
    
    var timer: SKLabelNode!
    var whosTurnLabel: SKLabelNode!
    
    var timerCountdown: Int! {
        didSet {
            guard let time = timerCountdown else { return }
            timer.text = String(describing: time)
        
            let timerSound = SKAction.playSoundFileNamed("timerSound", waitForCompletion: false)
            self.run(timerSound)
        }
    }
    
    var background: SKSpriteNode!
    
    var playerCup: SKSpriteNode!
    var botCup: SKSpriteNode!
    
    var playerCubes: [SKSpriteNode] = []
    var botCubes: [SKSpriteNode] = []
    
    var playerCount: Int = 0
    var botCount: Int = 0
    
    var initialSize: CGSize!
    var initialPosition: CGPoint!
    
    var cupIsOpened: Bool = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        startGame {
            guard !self.tutorial else { return }
            
            let randomTime = DispatchTime.now() + Double.random(in: 7...12)
            let workItem = DispatchWorkItem {
                self.whosTurnLabel.removeFromParent()
                self.timerCountdown = 20
                self.startTimer()
                self.botDelegate?.botCount = self.botCount
                self.botDelegate?.playerCount = self.playerCount
                self.botDelegate?.showCloud(true, false)
                
                guard self.tutorial else { return }
                self.isPaused = true
                self.tutorialDelegate?.show("responce")
            }
            self.workItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: randomTime, execute: workItem)
        }
    }
   
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameStarted else { return }
        
        let positionInScene = touches.first!.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        guard touchedNode.name == "playerCup" else { return }
        
        if cupIsOpened {
            openCup(false, playerCup)
        } else {
            openCup(true, playerCup)
        }
    }
    
    func showWhosTurn() {
        whosTurnLabel = SKLabelNode()
        whosTurnLabel.alpha = 0
        whosTurnLabel.text = "Bots turn.."
        whosTurnLabel.fontName = "Krungthep"
        let positionY = (self.frame.height / 3) + whosTurnLabel.frame.size.height
        whosTurnLabel.position = CGPoint(x: 0, y: positionY)
        whosTurnLabel.zPosition = 25
        whosTurnLabel.fontSize = (self.frame.width / 10.5)
        whosTurnLabel.fontColor = .white
        addChild(whosTurnLabel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        let wait = SKAction.wait(forDuration: 0.7)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut])
        let repeatAction = SKAction.repeatForever(sequence)
        let action = SKAction.sequence([fadeIn, repeatAction])
        whosTurnLabel.run(action, withKey: "fade")
    }
    
    func startGame(_ completion: @escaping(() -> ())) {
        self.aspectRatio = self.frame.width / self.frame.height
        createBackground()
        createCups()
        createTimer()
        shakeCups()
        
        completion()
    }
    
    func createBackground() {
        background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.zPosition = 0
        
        addChild(background)
    }
    
    func createCups() {
        let width = self.frame.width / 2.3
        
        // MARK: PLAYERS CUP
        let playerY = self.frame.height / 3.5
        playerCup = SKSpriteNode(imageNamed: "cup")
        playerCup.size = CGSize(width: width, height: width)
        playerCup.position = CGPoint(x: 0, y: -playerY)
        playerCup.zPosition = 10
        playerCup.name = "playerCup"
        
        initialSize = playerCup.size
        initialPosition = playerCup.position
        
        addChild(playerCup)
        
        //MARK: BOTS CUP
        let botY = self.frame.height / 5
        botCup = SKSpriteNode(imageNamed: "cup")
        botCup.size = CGSize(width: width, height: width)
        botCup.position = CGPoint(x: 0, y: botY)
        botCup.zPosition = 10
        
        addChild(botCup)
    }
    
    func shakeCups() {
        self.botCup.run(.shake(initialPosition: botCup.position, duration: 5)) {
            self.createCubes()
            self.playerCup.run(.shake(initialPosition: self.playerCup.position, duration: 5)) {
                self.openCup(true, self.playerCup)
                self.gameStarted = true
                self.showWhosTurn()
                
                guard self.tutorial else { return }
                self.isPaused = true
                self.tutorialDelegate?.show("cup")
            }
        }
    }
    
    func openCup(_ open: Bool, _ cup: SKSpriteNode) {
        var position = CGPoint()
        var angle: CGFloat = 0
        
        position = cup.position
        if open {
            position.x -= 50
            position.y += 125
            angle = 0.5
        } else {
            position = initialPosition
        }
        let rotateAction = SKAction.rotate(toAngle: angle, duration: 0.2)
        let moveAciton = SKAction.move(to: position, duration: 0.2)
        let group = SKAction.group([moveAciton, rotateAction])
        
        var owner: [SKSpriteNode] = []
        
        if cup == playerCup {
            owner = playerCubes
            self.cupIsOpened = !self.cupIsOpened
        } else {
            owner = botCubes
        }
        
        if open {
            cup.run(group) {
                self.showCubes(owner)
            }
        } else {
            self.hidePlayersCubes()
            cup.run(group) {
                let soundAction = SKAction.playSoundFileNamed("hideSound", waitForCompletion: false)
                self.run(soundAction)
            }
        }
    }
    
    func createCubes() {
        for _ in 1...5 {
            let randomValue = Int.random(in: 1...6)
            let cube = SKSpriteNode(imageNamed: String(describing: randomValue))
            let width = initialSize.width / 3.5
            let x = initialPosition.x
            let y = initialPosition.y
            cube.size = CGSize(width: width, height: width)
            cube.position = CGPoint(x: x, y: y)
            cube.zPosition = 5
            cube.isHidden = true
            
            playerCount += randomValue
            playerCubes.append(cube)
            addChild(cube)
        }
        
        for _ in 1...5 {
            let randomValue = Int.random(in: 1...6)
            let cube = SKSpriteNode(imageNamed: String(describing: randomValue))
            let width = initialSize.width / 3.5
            let x = botCup.position.x
            let y = botCup.position.y
            cube.size = CGSize(width: width, height: width)
            cube.position = CGPoint(x: x, y: y)
            cube.zPosition = 5
            cube.isHidden = true
            
            botCount += randomValue
            botCubes.append(cube)
            addChild(cube)
        }
    }
    
    func openAllCups(_ completion: @escaping(() -> ())) {
        if !cupIsOpened {
            self.openCup(true, playerCup)
        }
        self.openCup(true, botCup)
        completion()
    }
    
    func showCubes(_ owner: [SKSpriteNode]) {
        let soundAction = SKAction.playSoundFileNamed("showSound", waitForCompletion: false)
        self.run(soundAction)
        
        var horizontalSpacing = -50.0
        var verticalSpacing = 0.0
        var index = 0
        for cube in owner {
            if index < 3 {
                verticalSpacing = cube.position.y
                horizontalSpacing += (cube.size.width + 20)
            } else {
                horizontalSpacing -= (cube.size.width + 20)
                verticalSpacing = cube.position.y
                verticalSpacing -= (cube.size.width + 20)
            }
            let angle = CGFloat.random(in: -0.85...0.85)
            
            let point = CGPoint(x: horizontalSpacing, y: verticalSpacing)
            let moveAction = SKAction.move(to: point, duration: 0.1)
            let rotateAction = SKAction.rotate(toAngle: angle, duration: 0.1)
            
            let group = SKAction.group([moveAction, rotateAction])
            cube.isHidden = false
            cube.run(group)
            
            index += 1
        }
    }
    
    func hidePlayersCubes() {
        guard gameStarted else { return}
        
        for cube in playerCubes {
            let moveAction = SKAction.move(to: initialPosition, duration: 0.2)
            let rotateAction = SKAction.rotate(toAngle: 0, duration: 0.2)
            let group = SKAction.group([moveAction, rotateAction])
            
            cube.run(group) {
                cube.isHidden = true
            }
        }
    }
    
    func createTimer() {
        self.timer = SKLabelNode(fontNamed: "Arial Rounded MT Bold")
        var y:CGFloat = 100
        if self.aspectRatio > 0.5 { y = 60 }
        
        let position = CGPoint(x: (self.frame.width / 2) - 60,
                               y: (self.frame.height / 2) - y)
        self.timer.zPosition = 30
        self.timer.fontSize = (self.frame.width / 10.35)
        self.timer.position = position
        self.timer.isHidden = true
        
        self.addChild(timer)
    }
    
    func startTimer() {
        timer.isHidden = false
        timer.alpha = 1
        let timerAction = SKAction.wait(forDuration: 1)
        let block = SKAction.run {
            if self.timerCountdown > 0 {
                self.timerCountdown -= 1
            } else {
                self.stopTimer(completion: nil)
                self.won(false)
            }
        }
        let sequence = SKAction.sequence([timerAction, block])
        let repeatAction = SKAction.repeatForever(sequence)
        run(repeatAction, withKey: "countdown")
    }
    
    func stopTimer(completion: (()->())?) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        self.timer.run(fadeOut) {
            self.timer.isHidden = true
            self.removeAction(forKey: "countdown")
            if let completion = completion {
                completion()
            }
        }
    }
    
    func clearScene() {
        self.gameStarted = false
        self.removeAllChildren()
        self.removeAllActions()
        self.workItems.forEach { item in
            item.cancel()
        }
    }
    
    func won(_ won: Bool) {
        var soundName = "wonSound"
        if !won {
            soundName = "loseSound"
        }
        let sound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        self.run(sound) {
            self.clearScene()
            self.gameOverDelegate?.presentScoreViewController(playerWon: won)
            
        }
    }
        
        
    func checkForWinner(_ lastBet: Int,_ playersBet: Bool) {
        self.gameStarted = false
        let realCount = playerCount + botCount
        let betWasTrue = (lastBet >= realCount)
        
        if (playersBet && betWasTrue) || (!playersBet && !betWasTrue) {
            self.won(true)
        } else {
            self.won(false)
        }
    }
}


extension GameScene: PauseDelegate {
    func pauseGame(_ pause: Bool, _ beginning: Bool) {
        self.isPaused = pause
        if beginning {
            let randomTime = DispatchTime.now() + Double.random(in: 7...12)
            let workItem = DispatchWorkItem {
                self.whosTurnLabel.removeFromParent()
                self.timerCountdown = 20
                self.startTimer()
                self.botDelegate?.botCount = self.botCount
                self.botDelegate?.playerCount = self.playerCount
                self.botDelegate?.showCloud(true, false)
                
                guard self.tutorial else { return }
                self.isPaused = true
                self.tutorialDelegate?.show("responce")
            }
            self.workItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: randomTime, execute: workItem)
        }
    }
}

extension GameScene: ResponceDelegate {
    func lie(_ lastBet: Int,_ playersBet: Bool,_ lie: Bool) {
        self.stopTimer(completion: nil)
            self.openAllCups() {
                self.checkForWinner(lastBet, playersBet)
            }
    }
    
    func rised(_ botsRising: Bool) {
        self.stopTimer {
            self.showWhosTurn()
        }
        
        var range: Double = 0
        
        switch UserDefaults.standard.integer(forKey: "difficulty") {
        case 0:
            range = 8
        case 1:
            range = 6
        case 2:
            range = 4
        default:
            break
        }
        
        let randomTime = DispatchTime.now() + Double.random(in: (range / 1.5)...range)
        let workItem = DispatchWorkItem {
            self.timerCountdown = 20
            self.startTimer()
            self.botDelegate?.showCloud(false, !botsRising)
            self.whosTurnLabel.removeFromParent()
        }
        self.workItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: randomTime, execute: workItem)
    }
}

