//
//  GameScene.swift
//  FlappyBirdClone
//
//  Created by Jorge Rebollo J on 28/07/16.
//  Copyright (c) 2016 RGStudio. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var pajaro = SKSpriteNode()
    var colorCielo = SKColor()
    var texturaTubo1 = SKTexture()
    var texturaTubo2 = SKTexture()
    var separacionTubos = 180.0
    var controlTubo = SKAction()
    
    let categoriaPajaro: UInt32 = 1 << 0
    let categoriaSuelo: UInt32 = 1 << 1
    let categoriaTubos: UInt32 = 1 << 2
    let categoriaAvance: UInt32 = 1 << 3
    
    let movimiento = SKNode()
    
    var reset = false
    
    let adminTubos = SKNode()
    
    var puntuacion = NSInteger()
    var mejorPuntuacion = NSInteger()
    let puntuacionLabel = SKLabelNode()
    let mejorPuntuacionLabel = SKLabelNode()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        
        self.addChild(movimiento)
        
        movimiento.addChild(adminTubos)
        
        let texturaPajaro1 = SKTexture(imageNamed: "pajaro1")
        let texturaPajaro2 = SKTexture(imageNamed: "pajaro2")
        
        let aleteo = SKAction.animateWithTextures([texturaPajaro1, texturaPajaro2], timePerFrame: NSTimeInterval(0.2))
        let vuelo = SKAction.repeatActionForever(aleteo)
        
        pajaro = SKSpriteNode(texture: texturaPajaro1)
        pajaro.position = CGPoint(x: self.frame.size.width/2.75, y: CGRectGetMidY(self.frame))
        pajaro.physicsBody = SKPhysicsBody(circleOfRadius: pajaro.size.height/2.0)
        pajaro.physicsBody?.dynamic = true
        pajaro.physicsBody?.allowsRotation = false
        
        pajaro.runAction(vuelo)
        
        pajaro.physicsBody!.categoryBitMask = categoriaPajaro
        pajaro.physicsBody!.collisionBitMask = categoriaSuelo |
        categoriaTubos
        pajaro.physicsBody!.contactTestBitMask = categoriaSuelo |
        categoriaTubos
        
        self.addChild(pajaro)
        
        let texturaCielo = SKTexture(imageNamed:"Cielo")
        //calculamos el tamaño total de la pantalla y lo dividimos por el tamaño total de la imagen. Para garantizar que tanto el primero como el último cubren totalmente el fondo al desplazarse lateralmente, lo añadimos una vez más (de ahí que le sumemos 2).
        let fondosCielo = 2 + self.frame.size.width / (texturaCielo.size().width)
        let movimientoCielo = SKAction.moveByX(-texturaCielo.size().width, y: 0, duration: NSTimeInterval(0.05 * texturaCielo.size().width))
        let resetCielo = SKAction.moveByX(texturaCielo.size().width, y: 0, duration: 0.0)
        let movimientoCieloConstante = SKAction.repeatActionForever(SKAction.sequence([movimientoCielo, resetCielo]))
        for i in (0 as CGFloat).stride (through: fondosCielo, by: +1) {
            let fraccion = SKSpriteNode(texture: texturaCielo)
            fraccion.zPosition = -99
            fraccion.position = CGPointMake(i * fraccion.size.width, fraccion.size.height - 100)
            fraccion.runAction(movimientoCieloConstante)
            movimiento.addChild(fraccion)
        }
        
        let texturaSuelo = SKTexture(imageNamed:"Suelo")
        let movimientoSuelo = SKAction.moveByX(-texturaSuelo.size().width,y: 0,duration: NSTimeInterval(0.01 * texturaSuelo.size().width))
        let resetSuelo = SKAction.moveByX(texturaSuelo.size().width, y: 0, duration: 0.0)
        let movimientoSueloConstante = SKAction.repeatActionForever(SKAction.sequence([movimientoSuelo, resetSuelo]))
        let fondosSuelo = 2 + self.frame.size.width / (texturaSuelo.size().width)
        for i in (0 as CGFloat).stride (through: fondosSuelo, by: +1) {
            let fraccion = SKSpriteNode(texture: texturaSuelo)
            fraccion.zPosition = -97
            fraccion.position = CGPointMake(i * fraccion.size.width, fraccion.size.height/2)
            fraccion.runAction(movimientoSueloConstante)
            movimiento.addChild(fraccion)
        }
        
        let topeSuelo = SKNode()
        topeSuelo.position = CGPointMake(0, texturaSuelo.size().height/2.0)
        topeSuelo.physicsBody = SKPhysicsBody( rectangleOfSize: CGSizeMake(self.frame.size.width, texturaSuelo.size().height))
        topeSuelo.physicsBody?.dynamic = false
        
        topeSuelo.physicsBody!.categoryBitMask = categoriaSuelo
        topeSuelo.physicsBody!.contactTestBitMask = categoriaPajaro
        
        self.addChild(topeSuelo)
        
        colorCielo = SKColor(red: 113/255, green: 197/255, blue: 207/255, alpha: 1.0)
        self.backgroundColor = colorCielo
        
        texturaTubo1 = SKTexture(imageNamed: "tubo1")
        texturaTubo2 = SKTexture(imageNamed: "tubo2")
        
        let crearTubo = SKAction.runBlock({ ()
            in self.gestionTubos()
        })
        let retardo = SKAction.waitForDuration(NSTimeInterval(2.0))
        let crearTuboSiguiente = SKAction.sequence([crearTubo, retardo])
        let crearTuboSiguienteForever = SKAction.repeatActionForever(crearTuboSiguiente)
        self.runAction(crearTuboSiguienteForever)
        
        puntuacion = 0
        puntuacionLabel.fontName = "Arial"
        puntuacionLabel.fontSize = 100
        puntuacionLabel.alpha = 0.5
        puntuacionLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height-150)
        puntuacionLabel.zPosition = 0
        puntuacionLabel.text = "\(puntuacion)"
        self.addChild(puntuacionLabel)
        
        
        mejorPuntuacionLabel.fontName = "Arial"
        mejorPuntuacionLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height-150)//CGPointMake(CGRectGetMaxX(self.frame)-mejorPuntuacionLabel.frame.size.width, CGRectGetMaxY(self.frame)-mejorPuntuacionLabel.frame.size.height)
        mejorPuntuacionLabel.fontSize = 12
        mejorPuntuacionLabel.alpha = 0.5
        mejorPuntuacionLabel.verticalAlignmentMode = .Top
        mejorPuntuacionLabel.horizontalAlignmentMode = .Right
        mejorPuntuacionLabel.zPosition = 1
        mejorPuntuacionLabel.text = "Mejor puntuación:\n\(mejorPuntuacion)"
        self.addChild(mejorPuntuacionLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if(movimiento.speed>0) {
            pajaro.physicsBody!.velocity = CGVectorMake(0,0)
            pajaro.physicsBody!.applyImpulse(CGVectorMake(0,6))
        } else if reset {
            self.reiniciarEscena()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        pajaro.zRotation = self.rotacion(-1, max:0.5, valor: pajaro.physicsBody!.velocity.dy * (pajaro.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001))
    }
    
    func rotacion (min: CGFloat, max: CGFloat, valor: CGFloat) -> CGFloat {
        if (valor > max) {
            return max
        } else if(valor < min) {
            return min
        } else {
            return valor
        }
    }
    
    func gestionTubos(){
        let conjuntoTubo = SKNode()
        conjuntoTubo.position = CGPointMake(self.frame.size.width + texturaTubo1.size().width, 0)
        conjuntoTubo.zPosition = -10
        let altura = UInt(self.frame.size.height / 3)
        let y = UInt(arc4random()) % altura
        
        let tubo1 = SKSpriteNode(texture:texturaTubo1)
        tubo1.position  = CGPointMake(0.0,  CGFloat(y))
        tubo1.physicsBody = SKPhysicsBody(rectangleOfSize: tubo1.size)
        tubo1.physicsBody!.dynamic = false
        
        tubo1.physicsBody!.categoryBitMask = categoriaTubos
        tubo1.physicsBody!.contactTestBitMask = categoriaPajaro
        
        conjuntoTubo.addChild(tubo1)
        
        let tubo2 = SKSpriteNode(texture:texturaTubo2)
        tubo2.position = CGPointMake(0.0, CGFloat(y) + tubo1.size.height + CGFloat(separacionTubos))
        tubo2.physicsBody = SKPhysicsBody(rectangleOfSize: tubo2.size)
        tubo2.physicsBody!.dynamic = false
        
        tubo2.physicsBody!.categoryBitMask = categoriaTubos
        tubo2.physicsBody!.contactTestBitMask = categoriaPajaro
        
        conjuntoTubo.addChild(tubo2)
        
        let avanceNodo = SKNode()
        avanceNodo.position = CGPointMake(tubo1.size.width + pajaro.size.width/2.0, CGRectGetMidY(self.frame))
        avanceNodo.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(tubo1.size.width, self.frame.size.height))
        avanceNodo.physicsBody?.dynamic = false
        avanceNodo.physicsBody?.categoryBitMask = categoriaAvance
        avanceNodo.physicsBody?.contactTestBitMask = categoriaPajaro
        
        conjuntoTubo.addChild(avanceNodo)
        
        adminTubos.addChild(conjuntoTubo)
        
        let distanciaMovimiento = CGFloat( self.frame.size.width + texturaTubo1.size().width*2.0)
        let movimientoTubo = SKAction.moveByX(-distanciaMovimiento, y:0.0, duration: NSTimeInterval(0.008*distanciaMovimiento))
        let eliminarTubo = SKAction.removeFromParent()
        controlTubo = SKAction.sequence([movimientoTubo, eliminarTubo])
        conjuntoTubo.runAction(controlTubo)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if((contact.bodyA.categoryBitMask & categoriaAvance == categoriaAvance) || (contact.bodyB.categoryBitMask & categoriaAvance) == categoriaAvance ) {
            puntuacion += 1
            puntuacionLabel.text = "\(puntuacion)"
            if (separacionTubos>120) {
                separacionTubos -= 5
            }
        } else {
            if(movimiento.speed > 0) {
                let resetJuego = SKAction.runBlock({()
                    in self.resetGame()
                })
                movimiento.speed = 0
                let cambiarCieloRojo = SKAction.runBlock({()
                    in self.ponerCieloRojo()
                })
                let conjuntoGameOver = SKAction.group([cambiarCieloRojo, resetJuego])
                self.runAction(conjuntoGameOver)
            }
        }
    }
    
    func ponerCieloRojo() {
        self.backgroundColor = UIColor.redColor()
    }
    
    func resetGame() {
        reset = true
    }
    
    func reiniciarEscena(){
        let colorCielo = SKColor(red: 113/255, green: 197/255, blue: 207/255, alpha: 1)
        self.backgroundColor = colorCielo
        pajaro.position = CGPoint(x:self.frame.size.width / 2.8, y:CGRectGetMidY(self.frame))
        pajaro.physicsBody!.velocity = CGVectorMake (0,0)
        pajaro.speed = 0
        pajaro.zRotation = 0
        reset = false
        movimiento.speed = 1
        adminTubos.removeAllChildren()
        separacionTubos = 200
        mejorPuntuacion = puntuacion
        puntuacion = 0
        puntuacionLabel.text = "\(puntuacion)"
    }
}
