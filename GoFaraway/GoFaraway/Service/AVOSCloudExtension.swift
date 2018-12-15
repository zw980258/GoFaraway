//
//  AVOSCloudExtension.swift
//  GoFaraway
//
//  Created by 钟炜 on 2018/12/15.
//  Copyright © 2018 WEI ZHONG. All rights reserved.
//

extension AVOSCloud{
    
    func saveTheLocation(latitude: Double, longitude: Double, altitude: Double, content: String)  {
        let cloudObject = AVObject(className: "Location")
        cloudObject["latitude"] = latitude
        cloudObject["longitude"] = longitude
        cloudObject["altitude"] = altitude
        cloudObject["content"] = content
        
        cloudObject.saveEventually()
    }
    
    func getDataFromCloud() -> [AVObject]{
        let query =  AVQuery(className: "Location")
        var object : [AVObject] = []
        
        query.findObjectsInBackground { (result, error) in
            if let results = result as? [AVObject]{
                object = results
            }else{
                print(error ?? "获取Location数据出错")
            }
        }
        return object
    }
}
