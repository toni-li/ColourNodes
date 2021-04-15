//
//  ViewController.swift
//  ColourNodes
//
//  Created by Toni Li on 2021-04-13.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/blank.scn")!
    
        // Set the scene to the view
        sceneView.scene = scene
        
        // CLEAR button
        let rect1 = CGRect(x:20, y:650, width: 100, height:50)
        let clearButton = UIButton(frame: rect1)
        clearButton.layer.cornerRadius = 5
        clearButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        
        self.view.addSubview(clearButton)
    }
    
    @objc func clear(sender: UIButton!) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    var tempX = 0.0
    var tempY = 0.0
    
    @IBOutlet weak var hexCodeLabel: UILabel!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first {
            // getting the location of the touch
            let loc:CGPoint = touch.location(in: sceneView)
            // Compute near & far points
                let nearVector = SCNVector3(x: Float(loc.x), y: Float(loc.y), z: 0)
                let nearScenePoint = sceneView.unprojectPoint(nearVector)
                let farVector = SCNVector3(x: Float(loc.x), y: Float(loc.y), z: 1)
                let farScenePoint = sceneView.unprojectPoint(farVector)

                // Compute view vector
                let viewVector = SCNVector3(x: Float(farScenePoint.x - nearScenePoint.x), y: Float(farScenePoint.y - nearScenePoint.y), z: Float(farScenePoint.z - nearScenePoint.z))

                // Normalize view vector
                let vectorLength = sqrt(viewVector.x*viewVector.x + viewVector.y*viewVector.y + viewVector.z*viewVector.z)
                let normalizedViewVector = SCNVector3(x: viewVector.x/vectorLength, y: viewVector.y/vectorLength, z: viewVector.z/vectorLength)

                // Scale normalized vector to find scene point
                let scale = Float(5)
                let scenePoint = SCNVector3(x: normalizedViewVector.x*scale, y: normalizedViewVector.y*scale, z: normalizedViewVector.z*scale)

                print("2D point: \(loc). 3D point: \(nearScenePoint). Far point: \(farScenePoint). scene point: \(scenePoint)")

            
            // getting the hex value of the node
            let image = sceneView.snapshot()
            let x = image.size.width / sceneView.frame.size.width
            let y = image.size.height / sceneView.frame.size.height
            guard let color = image[Int(x * loc.x), Int(y * loc.y)] else{
               return
            }
            
            let rgbRedValue = color[0]
            let rgbGreenValue = color[1]
            let rgbBlueValue = color[2]
            
            let hexValue = String(format:"%02X", Int(rgbRedValue)) + String(format:"%02X", Int(rgbGreenValue)) + String(format:"%02X", Int(rgbBlueValue))
            //print(color)
            print(hexValue)
            
            let nodeImg = SCNNode(geometry: SCNSphere(radius: 0.05))
            nodeImg.physicsBody? = .static()
            //nodeImg.name = name
            //nodeImg.physicsBody?.categoryBitMask = MaskNum.barrier.rawValue
            //nodeImg.geometry?.materials.first?.diffuse.contents = UIImage(named: "nodeImg")
            nodeImg.geometry?.materials.first?.diffuse.contents = UIColor(red: 0.96, green: 0.84, blue: 0.45, alpha: 1.00)
            nodeImg.position = SCNVector3(scenePoint.x, scenePoint.y, scenePoint.z)
            print(nodeImg.position)

            sceneView.scene.rootNode.addChildNode(nodeImg)
        
            
            let text = SCNText(string: hexValue, extrusionDepth: 0.0)
            text.firstMaterial?.diffuse.contents = UIColor.black
            let nodeText = SCNNode(geometry: text)
            let fontScale: Float = 0.01
            nodeText.scale = SCNVector3(fontScale, fontScale, fontScale)
            
            nodeText.position.x = 0.05
            nodeText.position.y = 0.05

            nodeImg.addChildNode(nodeText)
            
            let minVec = nodeText.boundingBox.min
            let maxVec = nodeText.boundingBox.max
            let bound = SCNVector3Make(maxVec.x - minVec.x,
                                       maxVec.y - minVec.y,
                                       maxVec.z - minVec.z);

            let plane = SCNPlane(width: CGFloat(bound.x + 1.5),
                                 height: CGFloat(bound.y + 1.5))
            plane.cornerRadius = 0.2
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)

            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3(CGFloat( minVec.x) + CGFloat(bound.x) / 2 ,
                                            CGFloat( minVec.y) + CGFloat(bound.y) / 2,CGFloat(minVec.z - 0.01))

            nodeText.addChildNode(planeNode)
            planeNode.name = "text"
            
        
            
            
            
            
            
            
            

        }
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension UIImage {

subscript (x: Int, y: Int) -> [UInt8]? {
    if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
        return nil
    }
    let provider = self.cgImage!.dataProvider
    let providerData = provider!.data
    let data = CFDataGetBytePtr(providerData)

    let numberOfComponents = 4
    let pixelData = ((Int(size.width) * y) + x) * numberOfComponents

    let b = data![pixelData]
    let g = data![pixelData + 1]
    let r = data![pixelData + 2]
    
    return [r, g, b]

}
}
