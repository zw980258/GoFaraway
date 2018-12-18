//
//  ARViewController.swift
//  GoFaraway
//
//  Created by 钟炜 on 2018/12/14.
//  Copyright © 2018 WEI ZHONG. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreLocation

class ARViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate{
    
    var height = 0.0
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var temp = ""
    
    @IBOutlet weak var arscnView: ARSCNView!
    
    @IBOutlet weak var keyBoardView: UIView!
    
    @IBOutlet weak var myTextField: UITextField!
    
    @IBAction func didTapScreen(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.arscnView)
        let arr = arscnView.hitTest(point, options: nil)
        if arr.count > 0{
            let hit = arr.first
            let node = hit?.node
            node?.removeFromParentNode()
        }else{
            if sender.location(in: self.view).y < self.view.bounds.height - 250{
                self.myTextField.resignFirstResponder()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myTextField.delegate = self
        myTextField.returnKeyType = UIReturnKeyType.send
        myTextField.enablesReturnKeyAutomatically = true
        myTextField.placeholder = "在这里输入内容吧"
        myTextField.autocorrectionType = .default
        
        arscnView.delegate = self
        
        let scence = SCNScene()
        
        arscnView.showsStatistics = true
        arscnView.scene = scence
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardWillHide(note:)), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.requestAlwaysAuthorization()
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.worldAlignment = .gravityAndHeading
        // Run the view's session
        arscnView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //停止使用定位
        locationManager.stopUpdatingHeading()
        // Pause the view's session
        arscnView.session.pause()
    }
    
    
    //MARK: -- LOCATIONMANAGERDELEGATE
    
    //判断定位是否开启
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.notDetermined || status == CLAuthorizationStatus.denied{
            print("请前往设置界面，开启应用的定位功能")
            locationManager.requestWhenInUseAuthorization()
        }else{
            //允许使用定位服务的话，开启定位服务更新
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.last!
        print("定位开始")
        
        //let targetLoction = CLLocation(latitude: 30.00428, longitude: 120.59846)
        //let objects = AVOSCloud().getDataFromCloud()
        //下面这个云端获取方法待优化
        let query =  AVQuery(className: "Location")
        var objects : [AVObject] = []
        
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
                objects = results
                for object in objects{
                    let point = self.locationManager.calculateDistance(currentPoint: self.currentLocation, longitude: object["longitude"] as! Double, latitude: object["latitude"] as! Double, altitude: object["altitude"] as! Double)
                    print("当前相对坐标系： x: \(point.x), y: \(point.y), z: \(point.z)")
                    self.arscnView.addTextLabel(text: object["content"] as! String, x: point.x, y: point.y
                        , z: point.z)
                }
            }else{
                print(error ?? "获取Location数据出错")
            }
        }
        
       
        
        //let point = self.locationManager.calculateDistance(currentPoint: self.currentLocation, longitude: targetLoction, latitude: , altitude: )
        
        //self.arscnView.addTextLabel(text: "我在github等你", x: point.x , y: 0.0, z: point.z)
    }
    //MARK: --
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        //在后台储存当前发布的内容
        AVOSCloud().saveTheLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, altitude: currentLocation.altitude, content: temp)
        return SCNNode().addLabel(text: temp)
    }
    
    // MARK: 文本输入框 -- TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        guard textField.text == nil else {
            if let currentFrame = arscnView.session.currentFrame {
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -2.0
                let transform = simd_mul(currentFrame.camera.transform, translation)
                
                // Add a new anchor to the session
                let anchor = ARAnchor(transform: transform)
                arscnView.session.add(anchor: anchor)
                temp = textField.text!
                textField.text = ""
            }
            return true
        }
        
        return true
    }
    
    @objc func keyBoardWillShow(note:NSNotification){
        
        let userInfo  = note.userInfo! as NSDictionary
        let keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let deltaY = keyBoardBounds.size.height - self.tabBarController!.tabBar.bounds.size.height
        
        let animations:(() -> Void) = {
            self.keyBoardView.transform = CGAffineTransform(translationX: 0,y: -deltaY)
        }
        
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
            
        }else{
            animations()
        }
        
    }
    
    @objc func keyBoardWillHide(note:NSNotification){
        
        let userInfo  = note.userInfo! as NSDictionary
        
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {
            self.keyBoardView.transform = CGAffineTransform.identity
        }
        
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
    


