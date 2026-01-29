//
//  ParaEditVC.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 29.08.2021.
//

import UIKit

class ParaEditVC: UIViewController, WebApiProtocol {

    var webApi = WebApi()
    var mainVC: MainVC?
    var thePara: Para?
    
	@IBOutlet weak var lblExchange: UILabel!
	@IBOutlet weak var lblSymbol: UILabel!
    @IBOutlet weak var lblInterval: UILabel!
    @IBOutlet weak var stpInterval: UIStepper!
    @IBOutlet weak var lblProcent: UILabel!
    @IBOutlet weak var stpProcent: UIStepper!
    @IBOutlet weak var scType: UISegmentedControl!
    @IBOutlet weak var scLevel: UISegmentedControl!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let p = thePara!
        lblSymbol.text = p.Symbol
        lblExchange.text = Exchange.DisplayName(for: p.Exchange)
		
        lblInterval.text = "\(p.Interval)"
        stpInterval.value = Double(p.Interval)
        lblProcent.text = "\(p.Procent)"
        stpProcent.value = Double(p.Procent)
        if stpProcent.value == 0 { lblProcent.text = "0,5" }
        
        scType.selectedSegmentIndex = p.Tape - 1
        scLevel.selectedSegmentIndex = p.Level - 1
 
        webApi.delegate = self
    }
    
    @IBAction func Interval_Changed(_ sender: UIStepper) {
        
		let e = thePara?.Exchange
		var i = Int(sender.value)
        
		if (i == 2 && Int(lblInterval.text!) == 1)
		{ i = e == 3 ? 5 : 3; stpInterval.value = Double(i) }
		
		if (i == 4 && Int(lblInterval.text!) == 5)
		{ i = e == 3 ? 1 : 3; stpInterval.value = Double(i) }

        if (i == 2 && Int(lblInterval.text!) == 3) { i = 1; stpInterval.value = 1 }
        if (i == 4 && Int(lblInterval.text!) == 3) { i = 5; stpInterval.value = 5 }
        if (i == 6) { i = 15; stpInterval.value = 15 }
        if (i == 14) { i = 5; stpInterval.value = 5 }
        if (i == 16) { i = 30; stpInterval.value = 30 }
        if (i == 29) { i = 15; stpInterval.value = 15 }
        if (i == 31) { i = 60; stpInterval.value = 60 }
        if (i == 59) { i = 30; stpInterval.value = 30 }

        lblInterval.text = "\(i)"
        
        //UpdatePara()
    }
    
    @IBAction func Procent_Changed(_ sender: UIStepper) {
        let proc = Int(sender.value)
        lblProcent.text = proc == 0 ? "0,5" : "\(proc)"
        
        //UpdatePara()
   }
    
    @IBAction func Level_Changed(_ sender: UIStepper) {
        //UpdatePara()
   }

    @IBAction func Type_Changed(_ sender: UISegmentedControl) {
        //UpdatePara()
    }

    @IBAction func btnSave_Click(_ sender: UIButton) {
        UpdatePara()
    }
    @IBAction func btnDel_Click(_ sender: UIButton) {
        let id = thePara!.ID
        let sy = thePara!.Symbol
        let us = usr.Name
        webApi.Delete("\(id);\(sy);\(us)")
    }
    
    func UpdatePara() {
        let id = "\(thePara!.ID)"
		let e = "\(thePara!.Exchange)"
        let s = thePara!.Symbol
        let i = lblInterval.text!
        var p = lblProcent.text!; p = p == "0,5" ? "0" : p
        let l = "\(scLevel.selectedSegmentIndex+1)"
        let t = "\(scType.selectedSegmentIndex+1)"

        let para = id+";"+s+";"+e+";"+i+";"+p+";"+t+";"+l

        EnableControls(false)
        webApi.SetPara(para)
    }
    
    func ApiRequestDone(_ jsonDataFromServer: Data) {
        // Доступ к контролам на форме из другого потока
        DispatchQueue.main.async {
            self.EnableControls(true)
            self.mainVC?.Level = self.scLevel.selectedSegmentIndex + 1
            self.mainVC?.NeedToReload = true
            print(String(data: jsonDataFromServer, encoding: .utf8)!)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func EnableControls(_ b: Bool) {
        stpInterval.isEnabled = b
        scLevel.isEnabled = b
        stpProcent.isEnabled = b
        scType.isEnabled = b
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ChartVC {
            let vc = segue.destination as? ChartVC
			vc?.para = thePara!
        }
    }
}
