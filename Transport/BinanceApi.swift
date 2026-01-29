//
//  BinanceApi.swift
//  CryptoAlert
//
//  Version 9.2 by Andrey Mizerov on 30.09.2022.
//

import UIKit
import Foundation

protocol BinanceApiProtocol {
    func BinanceApiRequestDone(_ jsonDataFromServer: Data) -> ()
}

public class BinanceApi {
    var delegate: BinanceApiProtocol?
    private let apiUrl = "https://api.binance.com/api/v1/"
    static let sapiUrl = "https://api.binance.com/api/v1/"
    
    private func Get(_ url: URL, _ bDone: Bool = true) {
        URLSession.shared.dataTask(with: url) { data, response, error in
           if let data = data {
             // получил ответ от сервера
            if(bDone) { self.delegate?.BinanceApiRequestDone(data) }
           }
        }.resume()
    }
    private func Get2(_ urlString: String, _ bDone: Bool = true) {
        let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = URL(string: apiUrl + urlEncoded) {
            Get(url, bDone)
        }
        else {
            print("Api Get2 URL encoding Error")
        }
    }
    private static func Get3(_ urlString: String, completion: @escaping (_ data: Data) -> Void) {
        let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = URL(string: sapiUrl + urlEncoded) {
            URLSession.shared.dataTask(with: url) { data, response, error in
               if let data = data {
                   // получил ответ от сервера
                   completion(data)
               }
            }.resume()
        }
        else {
            print("Api Get3 URL encoding Error")
        }
    }
    //-------------------------------------------------->
    
    //Получить список пар
    func GetParasList() {
        if let url = URL(string: apiUrl + "exchangeInfo") {
            Get(url)
        }
    }
 
    //Получить данные для свечного графика
    static func GetChartData(_ para: Para, completion: @escaping (_ data: Data) -> Void) {
        let url = "klines?symbol=\(para.Symbol)&interval=\(para.Interval)m&limit=10"
        Get3(url) { data in
            completion(data)
        }
    }
	
   //Получить данные для свечного графика
	static func GetChartData2(_ symbol: String, _ interval: Int, completion: @escaping (_ data: Data) -> Void) {
		let snt = interval == 60 ? "1h" : "\(interval)m"
		let url = "klines?symbol=\(symbol)&interval=\(snt)&limit=10"
		Get3(url) { data in
		   completion(data)
		}
	}
}
