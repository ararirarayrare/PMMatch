import SpriteKit

extension SKAction {
    class func shake(initialPosition: CGPoint, duration: Float) -> SKAction {
        let amplitudeX: Int = 8
        let amplitudeY: Int = 8
        let startingX = initialPosition.x
        let startingY = initialPosition.y
        let numberOfShakes = duration / 0.1
        var actionsArray: [SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let newXPos = startingX + CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let newYPos = startingY + CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            actionsArray.append(SKAction.move(to: CGPoint(x: newXPos, y: newYPos), duration: 0.015))
        }
        actionsArray.append(SKAction.move(to: initialPosition, duration: 0.015))
        
        let sound = SKAction.playSoundFileNamed("shakingSound", waitForCompletion: false)
        
        let actionSequence = SKAction.sequence(actionsArray)
        let group = SKAction.group([actionSequence, sound])
        return group
    }
}

enum MPMessage: Codable {
    case cancel
    case lie
    case turn
    case newBet
    case playerCount
}
