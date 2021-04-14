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
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
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

    @IBOutlet weak var hexCodeLabel: UILabel!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first {
            let loc:CGPoint = touch.location(in: sceneView)
            
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
            print(color)
            print(hexValue)

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
