//
//  StartVCViewController.swift
//  CryptoAlert
//
//  Version 9.3 by Andrey Mizerov on 05.10.2022.
//

import UIKit

class StartVC: UIViewController {

    @IBOutlet weak var lblVer: UILabel!
    @IBOutlet weak var btnReload: UIButton!
    @IBOutlet weak var btnGoToMain: UIButton!
    
    private var navb: UINavigationBar?
    private var font: Any?
    private var fcol: Any?
    
    @IBAction func btnReload_Clicked(_ sender: Any) {
        self.btnReload.isHidden = true
        usr.Update()
        viewDidLoad()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        		
        lblVer.text = logger.Version
        
        navigationController?.toolbar.isHidden = true
        
        navb = navigationController?.navigationBar
        if font == nil && fcol == nil {
            font = navb?.largeTitleTextAttributes?[.font]
            fcol = navb?.largeTitleTextAttributes?[.foregroundColor]
        }
        navb?.largeTitleTextAttributes?[.font] = UIFont(name: "Arial", size: 15)
        navb?.largeTitleTextAttributes?[.foregroundColor] = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
        title = "Check internet ..."

		delay(bySeconds: 1.5) {
			if usr.id > 0 {
				self.title = "Internet - Ok";
				self.continueWithInternet();
			}
			else {
				self.title = "Check internet (1) ..."
				delay(bySeconds: 5) {
					if usr.id > 0 {
						self.title = "Internet - Ok";
						self.continueWithInternet();
					}
					else{
						self.title = "Check internet (2) ..."
						delay(bySeconds: 10) {
							if usr.id > 0 {
								self.title = "Internet - Ok";
								self.continueWithInternet();
							}
							else{
								self.title = "Internet - Error";
								self.btnReload.isHidden = false
								return
							}
						}
					}
				}
			}
		}
    }

	func continueWithInternet() {
		delay(bySeconds: 0.3) {
			self.title = "Hellow \(usr.Name) (id=\(usr.id))"

			delay(bySeconds: 0.3) {
				self.title = "Check Server ..."
				
				logger.CheckServer() { srv, res in
					
					if res == "" {
						DispatchQueue.main.async {
							self.title = "Db Ver. \(srv.DbVersion)/\(srv.CountUsers)/\(srv.CountDevices)"
						}
						delay(bySeconds: 0.3) {
							self.navigationController?.toolbar.isHidden = false
							self.navb?.largeTitleTextAttributes?[.font] = self.font
							self.navb?.largeTitleTextAttributes?[.foregroundColor] = self.fcol
							
							if paraPush.ID > 0 { return }

							self.btnGoToMain.sendActions(for: .touchUpInside)
						}
					}
					else {
						DispatchQueue.main.async {
							self.title = res
							self.btnReload.isHidden = false
						}
					}
				}
			}
		}
	}

	func waitForInet(i: Int = 0, closure: @escaping () -> Void) {
		
		if(i == 0) {
			title = "Check for internet ..."
		}
		else {
			title = "Check for internet (\(i)) ..."
		}
		delay(bySeconds: 1.5) {
			if usr.id > 0 {
				self.title = "Internet - Ok";
			}
			else {
				self.title = "Internet - Error";
				self.btnReload.isHidden = false
				if(i < 5) {
					self.waitForInet(i: i+1){}
				}
			}
		}
	}
}

public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
    let dispatchTime = DispatchTime.now() + seconds
    dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
}

public enum DispatchLevel {
    case main, userInteractive, userInitiated, utility, background
    var dispatchQueue: DispatchQueue {
        switch self {
        case .main:                 return DispatchQueue.main
        case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
        case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
        case .utility:              return DispatchQueue.global(qos: .utility)
        case .background:           return DispatchQueue.global(qos: .background)
        }
    }
}
