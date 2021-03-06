//
//  NewLabel.swift
//  AR3DTest
//
//  Created by 钟炜 on 2018/11/29.
//  Copyright © 2018 WEI ZHONG. All rights reserved.
//

import SceneKit
import ARKit

extension SCNNode{
    func addLabel(text: String) -> SCNNode {
        
        let node = SCNNode()
        
        let str = SKLabelNode(text: text)
        str.color = UIColor.white
        str.fontColor = UIColor.white
        str.verticalAlignmentMode = .center
        str.fontSize = 50
        str.numberOfLines = 0
        str.lineBreakMode = .byCharWrapping
        str.preferredMaxLayoutWidth = 600
        
        let testPlane = SCNPlane(width: str.frame.width/300, height: str.frame.height/300)
        testPlane.cornerRadius = testPlane.height / 10
        
        let testScene = SKScene(size: CGSize(width: str.frame.width + 50, height: str.frame.height))
        testScene.backgroundColor = UIColor(red: 1/123, green: 1/23, blue: 1/123, alpha: 0.7)
        
        str.position = CGPoint(x: testScene.size.width/2, y: testScene.size.height/2)
        testScene.addChild(str)
        
        testPlane.firstMaterial?.diffuse.contents = testScene
        testPlane.firstMaterial?.isDoubleSided = true
        testPlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        
        let testNode = SCNNode(geometry: testPlane)
        
        testNode.eulerAngles.z = .pi / 2
        testNode.position = SCNVector3Make(0.0, 0.0, -1.0)
        
        node.addChildNode(testNode)
        return node
    }
}
