//
//  ProfileVC.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 17.10.2021.
//

import UIKit

class ProfileVC: UIViewController, UserProtocol {
    
    var mainVC: MainVC?
    
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
	
    @IBOutlet weak var txtToken: UITextView!
	
	@IBOutlet weak var segExchange: UISegmentedControl!
	@IBOutlet weak var txtApiKey: UITextField!
	@IBOutlet weak var txtApiSecret: UITextField!
	@IBOutlet weak var txtPassPhrase: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        lblVersion.text = "Версия: " + logger.Version

        usr.delegate = self
        
        txtUserName.text = usr.Name
        txtEmail.text = usr.Email
		
		txtApiKey.text = usr.ApiKeys[0].ApiKey
		txtApiSecret.text = usr.ApiKeys[0].ApiSecret
		
		txtApiKey.backgroundColor = usr.ApiKeys[0].IsWorking ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
		txtApiSecret.backgroundColor = usr.ApiKeys[0].IsWorking ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
		txtPassPhrase.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	
        txtToken.text = usr.fcmToken + " / " + usr.uuid;
    }

	@IBAction func btnClear_Click(_ sender: UIButton) {
		txtApiKey.text = ""
		txtApiSecret.text = ""
		txtPassPhrase.text = ""
		let e = segExchange.selectedSegmentIndex
		usr.ApiKeys[e].ApiKey = ""
		usr.ApiKeys[e].ApiSecret = ""
		usr.ApiKeys[e].IsWorking = false
		usr.ApiKeys[e].IsWorking = false
		txtApiKey.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
		txtApiSecret.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
	}
	@IBAction func txtApiKey_BeginEdit(_ sender: UITextField) {
		weak var pb: UIPasteboard? = .general
		sender.text = pb?.string
		let e = segExchange.selectedSegmentIndex
		usr.ApiKeys[e].ApiKey = sender.text!
		self.view.endEditing(true)
	}
	
	@IBAction func txtApiSecret_BeginEdit(_ sender: UITextField) {
		weak var pb: UIPasteboard? = .general
		sender.text = pb?.string
		let e = segExchange.selectedSegmentIndex
		usr.ApiKeys[e].ApiSecret = sender.text!
		self.view.endEditing(true)
	}
	@IBAction func txtPassPhrase_BeginEdit(_ sender: Any) {
		weak var pb: UIPasteboard? = .general
		txtPassPhrase.text = pb?.string
		let e = segExchange.selectedSegmentIndex
		usr.ApiKeys[e].ApiPassPhrase = txtPassPhrase.text!
		self.view.endEditing(true)	}
	
	@IBAction func segExchange_Changed(_ sender: UISegmentedControl) {
		
		let e = sender.selectedSegmentIndex
		
		txtApiKey.text = usr.ApiKeys[e].ApiKey
		txtApiSecret.text = usr.ApiKeys[e].ApiSecret
		txtPassPhrase.text = usr.ApiKeys[e].ApiPassPhrase
		
		txtApiKey.backgroundColor = usr.ApiKeys[e].IsWorking ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
		txtApiSecret.backgroundColor = usr.ApiKeys[e].IsWorking ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
		txtPassPhrase.backgroundColor =
			segExchange.selectedSegmentIndex == 1 ?
				usr.ApiKeys[e].IsWorking ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
	}
	
	@IBAction func btnSave_Taped(_ sender: Any) {
        usr.Name = txtUserName.text!
        usr.Email = txtEmail.text!
        
        usr.Save()
        dismiss(animated: true)
    }
	func SaveDone() {
		DispatchQueue.main.async {
			usr.Name = self.txtUserName.text!
			self.mainVC?.btnProfile.title = usr.Name
		}
	}
	
    @IBAction func btnCopy_Taped(_ sender: Any) {
        UIPasteboard.general.string = usr.uuid
    }
    //************************************
    //Убрать клаву касанием по белому
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}


