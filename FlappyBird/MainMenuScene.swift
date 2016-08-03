//
//  MainMenuScene.swift
//  FlappyBirdClone
//
//  Created by Jorge Rebollo J on 01/08/16.
//  Copyright © 2016 RGStudio. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    var bird: SKSpriteNode!
    let birdTexture1: SKTexture
    let birdTexture2: SKTexture
    let birdTexture3: SKTexture
    var playButton: SKSpriteNode!
    let playButtonTexture: SKTexture
    var tutorial: SKSpriteNode!
    let tutorialTexture: SKTexture
    
    override init(size:CGSize) {
        birdTexture1 = SKTexture(imageNamed: "pajaro1")
        birdTexture2 = SKTexture(imageNamed: "pajaro2")
        birdTexture3 = SKTexture(imageNamed: "pajaro3")
        playButtonTexture = SKTexture(imageNamed: "playButton")
        tutorialTexture = SKTexture(imageNamed: "tutorial")
        
        super.init(size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        var background: SKSpriteNode
        
        background = SKSpriteNode(imageNamed: "MainMenu")
        
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        background.size = self.frame.size;
        addChild(background)
        
        birdTexture1.filteringMode = .Nearest
        birdTexture2.filteringMode = .Nearest
        birdTexture3.filteringMode = .Nearest
        
        let flappyBirdAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures([birdTexture1, birdTexture2, birdTexture3, birdTexture2], timePerFrame: 0.2))
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.zPosition = 100
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 130)
        bird.runAction(flappyBirdAnimation, withKey: "flappyBirdAnimation")
        
        addChild(bird)
        
        // setup our playButton and tutorial
        playButtonTexture.filteringMode = .Nearest
        tutorialTexture.filteringMode = .Nearest
        
        playButton = SKSpriteNode(texture: playButtonTexture)
        tutorial = SKSpriteNode(texture: tutorialTexture)
        
        playButton.zPosition = 100
        tutorial.zPosition = 100
        
        tutorial.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 70)
        playButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 130)
        
        addChild(playButton)
        addChild(tutorial)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        let transition = SKTransition.doorsOpenHorizontalWithDuration(2.0)
        self.view?.presentScene(gameScene, transition: transition)
    }
}
