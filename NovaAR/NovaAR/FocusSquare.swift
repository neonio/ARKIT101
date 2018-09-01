//
//  FocusSquare.swift
//  NovaAR
//
//  Created by amoyio on 2018/8/30.
//  Copyright © 2018年 amoyio. All rights reserved.
//

import ARKit
import SceneKit
class FocusSquare: SCNNode{
    var isDetect : Bool = true{
        didSet{
            geometry?.firstMaterial?.diffuse.contents = isDetect ? UIImage(named: "close") : UIImage(named: "open")
        }
    }
    
    func setHidden(to hidden: Bool) {
        var fadeTo: SCNAction
        
        if hidden {
            fadeTo = .fadeOut(duration: 0.5)
        } else {
            fadeTo = .fadeIn(duration: 0.5)
        }
        
        let actions = [fadeTo, .run({ (focusSquare: SCNNode) in
            focusSquare.isHidden = hidden
        })]
        runAction(.sequence(actions))
    }
    
    override init() {
        super.init()
        let plane = SCNPlane(width: 0.1, height: 0.1)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        plane.firstMaterial?.isDoubleSided = true
        geometry = plane
        eulerAngles.x = GLKMathDegreesToRadians(-90)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
