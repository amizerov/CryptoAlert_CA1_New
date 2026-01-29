//
//  HuobiApi.swift
//  CryptoAlert
//
//  Version 9.2 by Andrey Mizerov on 30.09.2022.
//

import Foundation


public class HuobiApi {

	private static let apiUrl = "https://api.huobi.pro/"
	
	private static func Get(_ urlString: String, completion: @escaping (_ data: Data) -> Void) {
		let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		if let url = URL(string: apiUrl + urlEncoded) {
			URLSession.shared.dataTask(with: url) { data, response, error in
			   if let data = data {
				   // получил ответ от сервера
				   completion(data)
			   }
			}.resume()
		}
		else {
			print("Api Get URL encoding Error")
		}
	}
	//-------------------------------------------------->
	
   //Получить данные для свечного графика
	static func GetChartData(_ symbol: String, _ interval: Int, completion: @escaping (_ data: Data) -> Void) {
		let snt = "\(interval)min"
		let url = "market/history/kline?period=\(snt)&size=10&symbol=\(symbol.lowercased())"
		Get(url) { data in
		   completion(data)
		}
	}
}
