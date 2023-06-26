//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/9.
//

import Foundation

//https://developer.apple.com/forums/thread/125891
//public func jsonStringFromJS(json: Any)->String?{
//    //let d = try! JSONSerialization.jsonObject(with: Data(json.utf8), options: [])
//    //let d = try! JSONSerialization.jsonObject(with: json, options: [])
//    //print("plist:", d)
//    let d2 = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
//    if let d2 = d2{
//        print("json:", String(data: d2, encoding: .utf8)!)
//        return String(data: d2, encoding: .utf8)!
//    }
//    return nil
//}
public func jsonObjectFromJS<T:Decodable>(json: Any)->T{
    
    let d2 = try! JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
    let decoder = JSONDecoder()
    let product = try! decoder.decode(T.self, from: d2)
    return product
}
