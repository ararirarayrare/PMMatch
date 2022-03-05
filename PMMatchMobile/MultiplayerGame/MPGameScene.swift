import SpriteKit
import GameplayKit

class MPGameScene: SKScene {
    
    var gameOverDelegate: GameOverDelegate?
    var sendDelegate: SendDelegate?
    
    var playerCubesNames: [String] = []
    
    var playerCubes: [SKSpriteNode] = []
    var playerCount: Int = 0
    
    var secondPlayerCubes: [SKSpriteNode] = []
    var secondPlayerCount: Int = 0
    
    var whosTurnLabel: SKLabelNode!
    
    
    var gameStarted: Bool = false
    var cupIsOpened: Bool = false
    
    var background: SKSpriteNode!
    
    var playerCup: SKSpriteNode!
    var secondPlayerCup: SKSpriteNode!
    
    var initialSize: CGSize!
    var initialPosition: CGPoint!
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        createBackground()
        createCups()
        shakeCups()
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
        
        //MARK: SECOND PLAYER CUP
        let botY = self.frame.height / 5
        secondPlayerCup = SKSpriteNode(imageNamed: "cup")
        secondPlayerCup.size = CGSize(width: width, height: width)
        secondPlayerCup.position = CGPoint(x: 0, y: botY)
        secondPlayerCup.zPosition = 10
        
        addChild(secondPlayerCup)
    }
    
    func createBackground() {
        background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.zPosition = 0
        
        addChild(background)
    }
    
    func shakeCups() {
        self.secondPlayerCup.run(.shake(initialPosition: secondPlayerCup.position, duration: 5)) {
            self.createCubes()
            self.playerCup.run(.shake(initialPosition: self.playerCup.position, duration: 5)) {
                
                self.gameStarted = true
                self.openCup(true, self.playerCup)
                self.showBetHint()
                self.sendDelegate?.setRealCount(self.playerCubesNames)
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
            owner = secondPlayerCubes
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
    
    func openAllCups(_ completion: @escaping(() -> ())) {
        if !cupIsOpened {
            self.openCup(true, playerCup)
        }
        self.openCup(true, secondPlayerCup)
        
        let wait = SKAction.wait(forDuration: 1.5)
        self.run(wait) {
            completion()
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
            playerCubesNames.append(String(describing: randomValue))
            addChild(cube)
        }
        self.sendDelegate?.setMyCount(playerCount)
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
        for cube in playerCubes {
            let moveAction = SKAction.move(to: initialPosition, duration: 0.2)
            let rotateAction = SKAction.rotate(toAngle: 0, duration: 0.2)
            let group = SKAction.group([moveAction, rotateAction])
            
            cube.run(group) {
                cube.isHidden = true
            }
        }
    }
    
    func showBetHint() {
        let label = SKLabelNode()
        label.fontSize = (self.frame.width / 10.5)
        label.fontColor = .white
        label.fontName = "Krungthep"
        label.zPosition = 25
        let positionY = (self.frame.height / 2.7) + label.frame.size.height
        label.position = CGPoint(x: 0, y: positionY)
        label.text = "Set first bet!"
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 0.7)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut])
        let repeatTwice = SKAction.repeat(sequence, count: 2)
        
        addChild(label)
        label.run(repeatTwice) {
            label.removeFromParent()
        }
    }
    
    func createSecondPlayerCubes(_ cubesNames: [String]) {
        for name in cubesNames {
            let cube = SKSpriteNode(imageNamed: name)
            let width = initialSize.width / 3.5
            let x = secondPlayerCup.position.x
            let y = secondPlayerCup.position.y
            cube.size = CGSize(width: width, height: width)
            cube.position = CGPoint(x: x, y: y)
            cube.zPosition = 5
            cube.isHidden = true
            
            guard let number = Int(name) else { return }
            
            secondPlayerCubes.append(cube)
            secondPlayerCount += number
            addChild(cube)
        }
    }
    
    func won(_ won: Bool) {
        var soundName = "wonSound"
        if !won {
            soundName = "loseSound"
        }
        
        let sound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        self.run(sound) {
            self.gameOverDelegate?.presentScoreViewController(playerWon: won)
        }
    }
    
    func checkForWinner(lastBet: Int, myBet: Bool) {
        let realCount = self.playerCount + self.secondPlayerCount
        let betWasTrue = realCount >= lastBet
        
        if (myBet && betWasTrue) || (!myBet && !betWasTrue) {
            self.won(true)
        } else {
            self.won(false)
        }
        
    }
}



extension MPGameScene: GameDelegate {
    func showWhosTurn() {
        whosTurnLabel = SKLabelNode()
        whosTurnLabel.alpha = 0
        whosTurnLabel.text = "Players turn.."
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
    
    func stopShowingWhosTurn() {
        self.whosTurnLabel.removeFromParent()
    }
    
    func openAllCups(secondPlayerCubesNames: [String], lastBet: Int, myBet: Bool) {
        self.createSecondPlayerCubes(secondPlayerCubesNames)
        self.openAllCups {
            self.checkForWinner(lastBet: lastBet, myBet: myBet)
        }
    }
}
