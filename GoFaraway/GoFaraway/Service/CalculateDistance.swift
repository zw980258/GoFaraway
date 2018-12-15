//
//  CalculateDistance.swift
//  AR3DTest
//
//  Created by 钟炜 on 2018/12/10.
//  Copyright © 2018 WEI ZHONG. All rights reserved.
//

import CoreLocation

extension CLLocationManager{
    //currentPoint -- 当前真实地理坐标
    //point2 -- 目标的真实地理坐标
    //x -- 目标距离当前位置的东西向距离
    //y -- 目标的海拔高度差
    //z -- 目标距离当前位置的南北向距离
    //point2: CLLocation -- longitude latitude altitude
    func calculateDistance(currentPoint: CLLocation, longitude: Double, latitude: Double, altitude: Double) -> (x : Float, y: Float, z: Float)  {
        let xPoint = CLLocation(latitude: currentPoint.coordinate.latitude, longitude: longitude)
        let zPoint = CLLocation(latitude: latitude, longitude: currentPoint.coordinate.longitude)

        var xDistance = 0.0
        var zDistance = 0.0
        let yDistance = (altitude - currentPoint.altitude)
        
        
        //点位相对arkit坐标原点在第一二象限
        //point2.longitude > currentpoint.longitude
        if longitude - currentPoint.coordinate.longitude > 0 {
            //点位相对arkit坐标原点在第一象限
            //point2.latitude > currentpoint.latitude
            if latitude > currentPoint.coordinate.latitude{
                xDistance = currentPoint.distance(from: xPoint)
                zDistance = -currentPoint.distance(from: zPoint)
            }else{
                //点位相对arkit坐标原点在第二象限
                xDistance = currentPoint.distance(from: xPoint)
                zDistance = currentPoint.distance(from: zPoint)
            }
        }else{
            //point2.longitude - currentpoint.longitude < 0
            //点位相对arkit坐标原点在第三象限
            //point2.latitude > currentpoint.latitude
            if latitude < currentPoint.coordinate.latitude{
                xDistance = -currentPoint.distance(from: xPoint)
                zDistance = currentPoint.distance(from: zPoint)
            }else{
                //点位相对arkit坐标原点在第四象限
                //point2.latitude > currentpoint.latitude
                xDistance = -currentPoint.distance(from: xPoint)
                zDistance = -currentPoint.distance(from: zPoint)
            }
            
        }
        
        return (Float(xDistance),Float(yDistance), Float(zDistance))
    }
}
