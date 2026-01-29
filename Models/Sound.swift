//
//  Sound.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 06.09.2021.
//

import Foundation

class Sound {
    var s = [Int]()
    func str() -> String { return "\(s[0]);\(s[1]);\(s[2]);\(s[3])" }
    
    init(fromData: Data = Data()){

        let st =  String(data: fromData, encoding: .utf8)!
        let ar = st.split(separator: ";")
        s.append(Int(ar[0])!)
        s.append(Int(ar[1])!)
        s.append(Int(ar[2])!)
        s.append(Int(ar[3])!)
    }
}
