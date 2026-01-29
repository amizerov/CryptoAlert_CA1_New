//
//  Product.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 23.12.2021.
//

import Foundation

struct Product: Codable {
	var id: Int
	var symbol: String
	var exchange: Int
	var baseasset: String
	var quoteasset: String
	var volatility: Double
	var cnt1: Int
	var cnt2: Int
	var cnt3: Int
	var dtc: String
}

class Products {
	var arr = [Product]()
	
	init(fromData: Data = Data()){
		let jsonDecoder = JSONDecoder()
		do {
			arr = try jsonDecoder.decode([Product].self, from: fromData)
		} catch {
			print(error)
		}
	}
}
