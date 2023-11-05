//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/5.
//

import Foundation

///
///https://blog.js.cytoscape.org/2020/05/11/layouts/
///
public enum CyLayout: String, Codable, Equatable, Hashable, CaseIterable, Identifiable{
    case grid
    case fcose //need import
    case circle
    case concentric
    //case avsdf //Whereas the circle layout is useful when you want to order the nodes yourself, the avsdf layout is useful when you want to automatically order the nodes to try to avoid edge overlap. //need import
    //case dagre //need import
    case breadthfirst
    
    public var id: String{
        return rawValue
    }
}
