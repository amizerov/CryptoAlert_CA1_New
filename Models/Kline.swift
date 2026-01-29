//
//  Kline.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 17.12.2021.
//

import Foundation

class Kline {
	var Open = 0.0
	var Close = 0.0
	var High = 0.0
	var Low = 0.0
	var CloseTime = UInt64(0)
	init() {}
}

struct BinaKline: Codable {
    var OpenTime: UInt64
    var Open: String
    var High: String
    var Low: String
    var Close: String
    var Volume: String
    var CloseTime: UInt64
    var BaseAssetVolume: String
    var NumberOfTrades: Int
    var TakerBuyVolume: String
    var TakerBuyBaseAssetVolume: String
    var Ignore: String
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.OpenTime = try container.decode(UInt64.self)
        self.Open = try container.decode(String.self)
        self.High = try container.decode(String.self)
        self.Low = try container.decode(String.self)
        self.Close = try container.decode(String.self)
        self.Volume = try container.decode(String.self)
        self.CloseTime = try container.decode(UInt64.self)
        self.BaseAssetVolume = try container.decode(String.self)
        self.NumberOfTrades = try container.decode(Int.self)
        self.TakerBuyVolume = try container.decode(String.self)
        self.TakerBuyBaseAssetVolume = try container.decode(String.self)
        self.Ignore = try container.decode(String.self)
      }
}

struct KucoKline: Codable {
	var code: String
	var data: [[String]]
}

struct HuobiKline: Codable {
	var ch: String
	var status: String
	var ts: UInt64
	var data: [HuobiCandle]
}
struct HuobiCandle: Codable {
	var id: UInt64
	var open: Double
	var close: Double
	var low: Double
	var high: Double
	var amount: Double
	var vol: Double
	var count: Int
}
