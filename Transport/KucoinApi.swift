//
//  KucoinApi.swift
//  CryptoAlert
//
//  Version 9.2 by Andrey Mizerov on 30.09.2022.
//

import Foundation


public class KucoinApi {

	private static let apiUrl = "https://api.kucoin.com/api/v1/"
	
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
	static func GetChartData(_ symbol: String, _ interval: Int, completion: @escaping (_ data: Data) -> Void)
    {
        WebApi.Log("KucoinApi.GetChartData: symbol=\(symbol), interval=\(interval)")
        
		let snt = interval == 60 ? "1hour" : "\(interval)min"
		let end = UInt64(round(Date().timeIntervalSince1970))
		let sta = end - UInt64(interval * 60 * 10)
		let url = "market/candles?type=\(snt)&symbol=\(symbol)&startAt=\(sta)&endAt=\(end)"
		Get(url) { data in
		   completion(data)
		}
	}
}
