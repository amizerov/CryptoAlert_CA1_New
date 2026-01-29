//
//  Order.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 29.03.2022.
//

import Foundation

class Order {
	var ID = 0
	var Exchange = 1
	var Symbol = ""
	var SpotMar = true
	var BuySel = true
	var Price = 0.0
	var Qty = 0.0
	var DtExec = ""
	
	init(_ o: String){
		
		let a = o.split(separator: ";")
		
		ID = Int(a[0])!
		Symbol = String(a[1])
		Exchange = Int(a[2])!
		SpotMar = Int(a[3])! == 1
		BuySel = Int(a[4])! == 1
		Price = Double(a[5])!
		Qty = Double(a[6])!
		
		if a.count > 7 {
			DtExec = String(a[7])
		}
	}
}
