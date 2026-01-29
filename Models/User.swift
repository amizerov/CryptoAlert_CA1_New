//
//  User.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 05.09.2021.
//

import Foundation
import UIKit

struct Usr: Codable
{
    var id = 0
    var Name = ""
    var Email = ""
	
	var BinaKey = ""
	var BinaSecret = ""
	var KucoKey = ""
	var KucoSecret = ""
	var KucoPassPhrase = ""
	var HuobKey = ""
	var HuobSecret = ""
	
	var IsBinaKeyWorks = false
	var IsKucoKeyWorks = false
	var IsHuobKeyWorks = false
}

struct UserKey {
	var ApiKey = ""
	var ApiSecret = ""
	var ApiPassPhrase = ""
	var Exchange = ""
	var IsWorking = false
}

protocol UserProtocol {
    func SaveDone()
}

class User: WebApiProtocol {
    var delegate: UserProtocol?
    private let webApi = WebApi()
    
    var id = 0
    var Name = ""
    var Email = ""
    var uuid = ""
    var fcmToken = ""
	
    var ApiKeys = [UserKey]()

    init() {
        uuid = UIDevice.current.identifierForVendor?.uuidString ?? "nil"
        webApi.delegate = self
    }
    
    func Update() {
        webApi.UpdateUser()
    }
    
    func Save() {
        webApi.SaveUser()
    }
    
    internal func ApiRequestDone(_ jsonData: Data) {
        
        do {
            let u = try JSONDecoder().decode(Usr.self, from: jsonData) as Usr
            
			self.id = u.id
            self.Name = u.Name
            self.Email = u.Email

			var b = UserKey(); b.Exchange = "Bina"; b.IsWorking = u.IsBinaKeyWorks
			b.ApiKey = u.BinaKey; b.ApiSecret = u.BinaSecret
			
			var k = UserKey(); k.Exchange = "Kuco"; k.IsWorking = u.IsKucoKeyWorks
			k.ApiKey = u.KucoKey; k.ApiSecret = u.KucoSecret; k.ApiPassPhrase = u.KucoPassPhrase

			var h = UserKey(); h.Exchange = "Huob"; h.IsWorking = u.IsHuobKeyWorks
			h.ApiKey = u.HuobKey; h.ApiSecret = u.HuobSecret

			self.ApiKeys.append(b); self.ApiKeys.append(k); self.ApiKeys.append(h);

            delegate?.SaveDone()
        }
        catch {
            print(error.localizedDescription)
            return
        }

    }
}
