//
//  Api.v.1.swift
//  CryptoAlert
//
//  Version 11.3 by Andrey Mizerov on 24.05.2025.
//
import UIKit
import Foundation

//let apiUrl = "https://cryptoalert.Mizerov.com/api/"
let apiUrl = "https://ca1.svr.vc:444/api/"


protocol WebApiProtocol {
    func ApiRequestDone(_ jsonDataFromServer: Data) -> ()
}

public class WebApi {
    var delegate: WebApiProtocol?
    
    private func Get(_ url: URL, _ bDone: Bool = true, retryCount: Int = 3)
    {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Ошибка подключения: \(error.localizedDescription)")
                if retryCount > 0 {
                    print("🔄 Retrying (\(retryCount) attempts left)...")
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        self.Get(url, bDone, retryCount: retryCount - 1)
                    }
                }
                return
            }

            if let data = data {
                print("✅ Получен ответ от сервера")
                if bDone {
                    self.delegate?.ApiRequestDone(data)
                }
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
		if let url = URL(string: apiUrl + urlEncoded) {
			URLSession.shared.dataTask(with: url) { data, response, error in
			   if let data = data {
				 completion(data)
			   }
			}.resume()
		}
		else {
			print("Api Get3 URL encoding Error")
		}
	}
	private static func Get4(_ urlString: String) {
		let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
		if let url = URL(string: apiUrl + urlEncoded) {
			URLSession.shared.dataTask(with: url) { data, response, error in
			}.resume()
		}
		else {
			print("Api Get4 URL encoding Error")
		}
	}
    //**************************************************************
    
	//Получить список всех торговых пар биржи
	func Products(_ exchange: Int) {
		Get2("Products/\(exchange)")
	}
	
    //Получить список пар по уровням
    func List(lvl: Int) {
        let url = "List/\(lvl);\(usr.uuid)"
        Get2(url)
    }
    
    //Получить список алертов
    func Alert() {
        let url = "Alert/\(usr.uuid)"
        Get2(url)
    }

	//Получить список активных ордеров
	public static func GetOrders(completion: @escaping (_ orders: [String]) -> Void) {
		let url = "Order/\(usr.uuid)"
		Get3(url) { data in
			do {
				let orders = try JSONDecoder().decode([String].self, from: data)
				completion(orders)
			}
			catch {
				logger.Log("Ошбка парсинга GetOrders: \(error)")
			}
		}
	}
	//Получить список исполненных ордеров
	public static func GetOrdersFilled(completion: @escaping (_ orders: [String]) -> Void) {
		let url = "OrderFilled/\(usr.uuid)"
		Get3(url) { data in
			do {
				let orders = try JSONDecoder().decode([String].self, from: data)
				completion(orders)
			}
			catch {
				logger.Log("Ошбка парсинга GetOrders: \(error)")
			}
		}
	}
    //Добавить или Обновить пару
    func SetPara(_ para: String) {
        let url = "Update/\(para);\(usr.Name);\(usr.uuid);\(usr.fcmToken)"
        Get2(url)
    }
	
	//Получить пару по id
	public static func GetPara(_ id: Int, completion: @escaping (_ data: Data) -> Void) {
		let url = "GetPara/\(id)"
		Get3(url) { data in completion(data) }
	}

    //Удалить пару
    func Delete(_ paraToDelete: String) {
        let url = "Delete/\(paraToDelete);\(usr.uuid);\(usr.fcmToken)"
        Get2(url, true)
    }
    
    //Получить звуки для определенного устройства
    func GetSounds() {
        let url = "Sound/get;\(usr.uuid)"
        Get2(url)
    }
    
    func SetSounds(_ sound: String) {
        let url = "Sound/Set;\(usr.uuid);\(sound)"
        Get2(url, false)
    }
    //Регистрация токена для Firebase и созание нового Юзера
    func UpdateUser() {
        let url = "UpdateUser/\(usr.uuid);\(usr.fcmToken)"
        Get2(url)
    }
    
    func SaveUser() {
        var url = "SaveUser/\(usr.uuid);\(usr.Name);\(usr.Email)"
        Get2(url)
		url = "SaveUserKey/\(usr.uuid);\(usr.ApiKeys[0].ApiKey);\(usr.ApiKeys[0].ApiSecret);Bina"
		Get2(url, false)
		url = "SaveUserKey/\(usr.uuid);\(usr.ApiKeys[1].ApiKey);\(usr.ApiKeys[1].ApiSecret);\(usr.ApiKeys[1].ApiPassPhrase);Kuco"
		Get2(url, false)
		url = "SaveUserKey/\(usr.uuid);\(usr.ApiKeys[2].ApiKey);\(usr.ApiKeys[2].ApiSecret);Huob"
		Get2(url, false)
    }
    
    func CheckServer() {
        let url = "CheckServer/\(usr.uuid);\(usr.Name);\(usr.Email)"
        Get2(url)
    }
    
    func WriteLog(_ msg: String) {
        let url = "ActionLog/\(msg);\(usr.id)"
        Get2(url, false)
    }
	public static func Log(_ msg: String) {
		Get4("ActionLog/\(msg.replacingOccurrences(of: " ", with: "_"));\(usr.id)")
	}
}



