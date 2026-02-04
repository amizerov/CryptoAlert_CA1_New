//
//  AlfaBApi.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 30.01.2026.
//


import Foundation


public class AlfaBApi {

    private static let apiUrl = "https://www.binance.com/bapi/defi/v1/public/alpha-trade/"
    
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
        var url = "klines?symbol=\(symbol)&interval=\(interval)m&limit=10"
        if interval == 60 {
            url = "klines?symbol=\(symbol)&interval=1h&limit=10"
        }
        Get(url) { data in
           completion(data)
        }
    }
}
