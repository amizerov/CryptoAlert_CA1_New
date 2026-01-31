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

struct BinanceAlphaKlinesResponse: Decodable {
    let code: String
    let message: String?
    let messageDetail: String?
    let data: [BinaAlfaKline]
}

struct BinaAlfaKline: Decodable {
    let openTime: UInt64
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
    let closeTime: UInt64
    let quoteAssetVolume: String
    let numberOfTrades: Int
    let takerBuyBaseAssetVolume: String
    let takerBuyQuoteAssetVolume: String
    let ignore: Int

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()

        func decodeStringOrNumberString() throws -> String {
            if let s = try? c.decode(String.self) { return s }
            if let i = try? c.decode(Int.self) { return String(i) }
            if let d = try? c.decode(Double.self) { return String(d) }
            throw DecodingError.typeMismatch(
                String.self,
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Expected String/number convertible to String")
            )
        }

        func decodeUInt64FromStringOrNumber() throws -> UInt64 {
            if let u = try? c.decode(UInt64.self) { return u }
            let s = try decodeStringOrNumberString()
            guard let u = UInt64(s) else {
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Bad UInt64: \(s)")
            }
            return u
        }

        func decodeIntFromStringOrNumber() throws -> Int {
            if let i = try? c.decode(Int.self) { return i }
            let s = try decodeStringOrNumberString()
            guard let i = Int(s) else {
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Bad Int: \(s)")
            }
            return i
        }

        openTime = try decodeUInt64FromStringOrNumber()
        open = try decodeStringOrNumberString()
        high = try decodeStringOrNumberString()
        low = try decodeStringOrNumberString()
        close = try decodeStringOrNumberString()
        volume = try decodeStringOrNumberString()
        closeTime = try decodeUInt64FromStringOrNumber()
        quoteAssetVolume = try decodeStringOrNumberString()
        numberOfTrades = try decodeIntFromStringOrNumber()
        takerBuyBaseAssetVolume = try decodeStringOrNumberString()
        takerBuyQuoteAssetVolume = try decodeStringOrNumberString()
        ignore = (try? c.decode(Int.self)) ?? 0
    }
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
