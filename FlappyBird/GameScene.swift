//
//  GameScene.swift
//  FlappyBirdClone
//
//  Created by Jorge Rebollo J on 28/07/16.
//  Copyright (c) 2016 RGStudio. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var verticalPipeGap = 150
    
    var bird: SKSpriteNode!
    let birdTexture1: SKTexture
    let birdTexture2: SKTexture
    let birdTexture3: SKTexture
    var skyColor: SKColor
    let skyTexture: SKTexture
    let groundTexture: SKTexture
    let pipeTextureUp: SKTexture
    let pipeTextureDown: SKTexture
    
    var movePipesAndRemove: SKAction!
    var movingBackgroundLayer: SKNode!
    var pipesManager: SKNode!
    
    var canRestart = Bool()
    
    var scoreLabelNode: SKLabelNode
    var score = NSInteger()
    
    var isGameOver = Bool()
    var getReady = Bool()
    
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let skyCategory: UInt32 = 1 << 2
    let pipeCategory: UInt32 = 1 << 3
    let scoreCategory: UInt32 = 1 << 4
    
    var getReadySprite: SKSpriteNode!
    let getReadyTexture: SKTexture
    var spawnPipesThenDelayForever: SKAction!
    
    override init(size:CGSize) {
        birdTexture1 = SKTexture(imageNamed: "pajaro1")
        birdTexture2 = SKTexture(imageNamed: "pajaro2")
        birdTexture3 = SKTexture(imageNamed: "pajaro3")
        skyColor = SKColor(red: 113/255, green: 197/255, blue: 207/255, alpha: 1.0)
        skyTexture = SKTexture(imageNamed: "cielo")
        groundTexture = SKTexture(imageNamed: "suelo")
        pipeTextureUp = SKTexture(imageNamed: "tubo2")
        pipeTextureDown = SKTexture(imageNamed: "tubo1")
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        score = 0
        getReadyTexture = SKTexture(imageNamed: "getReady")
        
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        canRestart = false
        getReady = false
        
        // setup physics
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
        
        // setup background color
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        backgroundColor = skyColor
        
        //initialize background Layer
        movingBackgroundLayer = SKNode()
        addChild(movingBackgroundLayer)
        
        // ground
        groundTexture.filteringMode = .Nearest // shorter form for SKTextureFilteringMode.Nearest
        
        //let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.02 * groundTexture.size().width * 2.0))
        let groundSpriteMove = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * groundTexture.size().width))
        //let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let groundSpriteReset = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
        let groundSpritesAnimation = SKAction.repeatActionForever(SKAction.sequence([groundSpriteMove, groundSpriteReset]))
        
        //calculamos el tamaño total de la pantalla y lo dividimos por el tamaño total de la imagen. Para garantizar que tanto el primero como el último cubren totalmente el fondo al desplazarse lateralmente, lo añadimos una vez más (de ahí que le sumemos 2).
        //let groundBackgrounds = 2.0 + self.frame.size.width / (groundTexture.size().width * 2.0)
        let groundBackgrounds = 2 + self.frame.size.width / (groundTexture.size().width)
        
        for i in (0 as CGFloat).stride (through: groundBackgrounds, by: +1) {
            let groundBackgroundSprite = SKSpriteNode(texture: groundTexture)
            groundBackgroundSprite.zPosition = -1
            //sprite.setScale(2.0)
            //sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0)
            groundBackgroundSprite.position = CGPoint(x: i * groundBackgroundSprite.size.width, y: groundBackgroundSprite.size.height / 2)
            groundBackgroundSprite.runAction(groundSpritesAnimation)
            movingBackgroundLayer.addChild(groundBackgroundSprite)
        }
        
        // create the ground limit
        let groundLimit = SKNode()
        //ground.position = CGPoint(x: 0, y: groundTexture.size().height)
        groundLimit.position = CGPoint(x: 0, y: groundTexture.size().height / 2)
        //ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        groundLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width * 2, height: groundTexture.size().height))
        groundLimit.physicsBody?.dynamic = false
        
        groundLimit.physicsBody!.categoryBitMask = worldCategory
        groundLimit.physicsBody!.contactTestBitMask = birdCategory
        addChild(groundLimit)
        
        // skyline
        skyTexture.filteringMode = .Nearest
        
        //let moveSkySprite = SKAction.moveByX(-skyTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.1 * skyTexture.size().width * 2.0))
        let skySpriteMove = SKAction.moveByX(-skyTexture.size().width, y: 0, duration: NSTimeInterval(0.05 * skyTexture.size().width))
        //let resetSkySprite = SKAction.moveByX(skyTexture.size().width * 2.0, y: 0, duration: 0.0)
        let skySpriteReset = SKAction.moveByX(skyTexture.size().width, y: 0, duration: 0)
        //let moveSkySpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        let skySpritesAnimation = SKAction.repeatActionForever(SKAction.sequence([skySpriteMove, skySpriteReset]))
        
        //let skyBackgrounds = 2.0 + self.frame.size.width / ( skyTexture.size().width * 2.0 )
        let skyBackgrounds = 2 + self.frame.size.width / (skyTexture.size().width)
        
        for i in (0 as CGFloat).stride (through: skyBackgrounds, by: +1) {
            let skyBackgroundSprite = SKSpriteNode(texture: skyTexture)
            //sprite.zPosition = -20
            skyBackgroundSprite.zPosition = -3
            //sprite.setScale(2.0)
            //sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2.0 + groundTexture.size().height * 2.0)
            skyBackgroundSprite.position = CGPoint(x: i * skyBackgroundSprite.size.width, y: skyBackgroundSprite.size.height - 100)
            skyBackgroundSprite.runAction(skySpritesAnimation)
            movingBackgroundLayer.addChild(skyBackgroundSprite)
        }
        
        // create the sky limit
        let skyLimit = SKNode()
        //ground.position = CGPoint(x: 0, y: groundTexture.size().height)
        skyLimit.position = CGPoint(x: 0, y: self.frame.maxY + 3 * groundTexture.size().height)
        //ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        skyLimit.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width * 2, height: groundTexture.size().height))
        skyLimit.physicsBody?.dynamic = false
        
        skyLimit.physicsBody!.categoryBitMask = skyCategory
        skyLimit.physicsBody!.contactTestBitMask = birdCategory
        addChild(skyLimit)
        
        // setup our bird
        birdTexture1.filteringMode = .Nearest
        birdTexture2.filteringMode = .Nearest
        birdTexture3.filteringMode = .Nearest
        
        //let anim = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2)
        //let flap = SKAction.repeatActionForever(anim)
        let flappyBirdAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures([birdTexture1, birdTexture2, birdTexture3, birdTexture2], timePerFrame: 0.2))
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.zPosition = 100
        //bird.setScale(2.0)
        //bird.position = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.6)
        bird.position = CGPoint(x: self.frame.size.width / 2.8, y: self.frame.size.height * 0.6)
        //bird.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.midY)
        bird.runAction(flappyBirdAnimation, withKey: "flappyBirdAnimation")
        
        addChild(bird)
        
        // create the pipes textures
        pipeTextureUp.filteringMode = .Nearest
        pipeTextureDown.filteringMode = .Nearest
        
        // create the pipes movement actions
        //let distanceToMove = CGFloat(self.frame.size.width + 2 * pipeTextureUp.size().width)
        let distanceToMove = CGFloat(self.frame.size.width + pipeTextureUp.size().width * 2)
        //let movePipes = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0, duration: NSTimeInterval(0.008 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        pipesManager = SKNode()
        movingBackgroundLayer.addChild(pipesManager)
        
        // spawn the pipes
        let spawnPipes = SKAction.runBlock({() in self.spawnPipes()})
        
        let delay = SKAction.waitForDuration(NSTimeInterval(2))
        let spawnPipesThenDelay = SKAction.sequence([spawnPipes, delay])
        spawnPipesThenDelayForever = SKAction.repeatActionForever(spawnPipesThenDelay)
        
        // Create a label which holds the score
        scoreLabelNode.position = CGPoint(x: self.frame.midX, y: 3 * self.frame.size.height / 4)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        scoreLabelNode.hidden = !getReady
        addChild(scoreLabelNode)
        
        // setup our getReady
        getReadyTexture.filteringMode = .Nearest
        getReadySprite = SKSpriteNode(texture: getReadyTexture)
        getReadySprite.zPosition = 100
        getReadySprite.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 130)
        getReadySprite.hidden = getReady
        addChild(getReadySprite)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if !getReady {
            getReady = true
            
            // set getReady label
            getReadySprite.hidden = getReady
            
            // set physics to bird
            bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
            bird.physicsBody?.dynamic = true
            bird.physicsBody?.allowsRotation = false
            bird.physicsBody?.categoryBitMask = birdCategory
            bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory | skyCategory
            bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory | skyCategory
            
            // add pipes
            self.runAction(spawnPipesThenDelayForever, withKey: "spawnPipesThenDelayForever")
            
            // set visible scoreLabelNode
            scoreLabelNode.hidden = !getReady
        }
        if movingBackgroundLayer.speed > 0  {
            for touch: AnyObject in touches {
                _ = touch.locationInNode(self)
                
                bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                //bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 30))
                bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 6))
            }
        } else if canRestart {
            self.resetScene()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if getReady {
            bird.zRotation = clamp(-1, max: 0.5, value: bird.physicsBody!.velocity.dy * (bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001))
        }
    }
    
    func spawnPipes() {
        let pipePair = SKNode()
        //pipePair.position = CGPoint( x: self.frame.size.width + pipeTextureUp.size().width * 2, y: 0 )
        pipePair.position = CGPointMake(self.frame.size.width + pipeTextureUp.size().width, 0)
        //pipePair.zPosition = -10
        pipePair.zPosition = -2
        
        //let height = UInt32( self.frame.size.height / 4)
        let height = UInt32(self.frame.size.height / 3)
        //let y = Double(arc4random_uniform(height) + height);
        let y = UInt32(arc4random()) % height
        
        let pipeDown = SKSpriteNode(texture: pipeTextureDown)
        //pipeDown.setScale(2.0)
        //pipeDown.position = CGPoint(x: 0.0, y: y + Double(pipeDown.size.height) + verticalPipeGap)
        pipeDown.position  = CGPoint(x: 0,  y: CGFloat(y))
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
        pipeDown.physicsBody?.categoryBitMask = pipeCategory
        pipeDown.physicsBody?.contactTestBitMask = birdCategory
        
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeTextureUp)
        //pipeUp.setScale(2.0)
        //pipeUp.position = CGPoint(x: 0.0, y: y)
        pipeUp.position = CGPoint(x: 0, y: CGFloat(y) + pipeDown.size.height + CGFloat(verticalPipeGap))
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipeUp.physicsBody?.categoryBitMask = pipeCategory
        pipeUp.physicsBody?.contactTestBitMask = birdCategory
        
        pipePair.addChild(pipeUp)
        
        let contactZoneNode = SKNode()
        //contactNode.position = CGPoint( x: pipeDown.size.width + bird.size.width / 2, y: self.frame.midY )
        contactZoneNode.position = CGPoint(x: pipeDown.size.width + bird.size.width / 2, y: self.frame.midY)
        contactZoneNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: pipeUp.size.width, height: self.frame.size.height ))
        contactZoneNode.physicsBody?.dynamic = false
        contactZoneNode.physicsBody?.categoryBitMask = scoreCategory
        contactZoneNode.physicsBody?.contactTestBitMask = birdCategory
        
        pipePair.addChild(contactZoneNode)
        
        pipePair.runAction(movePipesAndRemove)
        
        pipesManager.addChild(pipePair)
    }
    
    func resetScene (){
        // Move bird to original position and reset velocity
        bird.position = CGPoint(x: self.frame.size.width / 2.8, y: self.frame.size.height * 0.6)
        //bird.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.midY)
        bird.physicsBody?.velocity = CGVector( dx: 0, dy: 0 )
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory | skyCategory
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory | skyCategory
        bird.speed = 1
        bird.paused = false
        bird.zRotation = 0
        
        // Remove all existing pipes
        pipesManager.removeAllChildren()
        self.removeActionForKey("spawnPipesThenDelayForever")
        verticalPipeGap = 150
        
        // Reset _canRestart
        canRestart = false
        
        // Reset score
        score = 0
        scoreLabelNode.text = String(score)
        
        // Restart animation
        movingBackgroundLayer.speed = 1
        
        // Reset _getReady
        getReady = false
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if movingBackgroundLayer.speed > 0 {
            if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
                // Bird has contact with score entity
                score += 1
                scoreLabelNode.text = String(score)
                if verticalPipeGap > 100 {
                    verticalPipeGap -= 5
                }
                
                // Add a little visual feedback for the score increment
                scoreLabelNode.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration:NSTimeInterval(0.1)), SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))]))
            } else {
                if movingBackgroundLayer.speed > 0 {
                    movingBackgroundLayer.speed = 0
                    self.bird.paused = true
                    self.bird.speed = 0
                    
                    // Flash background if contact is detected
                    self.removeActionForKey("flash")
                    self.runAction(SKAction.sequence([SKAction.repeatAction(SKAction.sequence([SKAction.runBlock({
                        self.backgroundColor = UIColor.redColor()
                    }),SKAction.waitForDuration(NSTimeInterval(0.05)), SKAction.runBlock({
                        self.backgroundColor = self.skyColor
                    }), SKAction.waitForDuration(NSTimeInterval(0.05))]), count:4), SKAction.runBlock({
                        self.canRestart = true
                    })]), withKey: "flash")
                }
            }
        }
    }
}
