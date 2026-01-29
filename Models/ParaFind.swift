//
//  ParaFind.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 10.09.2021.
//

import Foundation

struct F: Codable {
    
}
struct L: Codable {
    var rateLimitType: String
    var interval: String
    var intervalNum: Int
    var limit: Int
}
struct P: Codable {
    var symbol: String
    var baseAsset: String
    var quoteAsset: String
}
struct BinanceInfo: Codable {
    var timezone: String
    var serverTime: Int64
    var rateLimits: [L]
    var exchangeFilters: [F]
    var symbols: [P]
}

class ParasFind {
    var arr = [ParaFind]()
    
    init(fromData: Data = Data()){
        let jsonDecoder = JSONDecoder()
        do {
            let parsedJSON = try jsonDecoder.decode(BinanceInfo.self, from: fromData)
            for sym in parsedJSON.symbols {
                let p = ParaFind(sym.symbol, sym.baseAsset, sym.quoteAsset)
                arr.append(p)
            }
        } catch {
            print(error)
        }
    }
}

class ParaFind {
    var symbol = ""
    var baseAsset = ""
    var quoteAsset = ""
    
    init(_ sym: String, _ base: String, _ quote: String) {
        symbol = sym
        baseAsset = base
        quoteAsset = quote
    }
}

