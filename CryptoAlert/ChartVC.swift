//
//  CandleStickChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

class ChartVC: UIViewController, ChartViewDelegate {

	var para = Para()
    var chartView = CandleStickChartView()
	@IBOutlet weak var mainView: UIView!
	@IBOutlet weak var lblAlert: UILabel!
	@IBOutlet weak var lblInfo: UILabel!
	@IBOutlet weak var segInterval: UISegmentedControl!
    @IBOutlet weak var btnOrders: UIBarButtonItem!
    @IBOutlet weak var btnTrade: UIButton!
    var maxChange = 0.0
	var maxChangeAt = ""
	var indexOfAlertedKline = 0
	var lock = false
	var quit = false
	
	override func viewDidLoad() {
        super.viewDidLoad()

        var sy = para.Exchange == 4 ? para.baseAsset + "/" + para.quoteAsset : para.Symbol
        title = sy + " " + Exchange.DisplayName(for: para.Exchange)
        //setButtons()
        
		lblAlert.text = ""
		let perc = para.Procent == 0 ? "0,5" : "\(para.Procent)"
		lblInfo.text = "Interval: \(para.Interval) min, Percent: \(perc) %" +
						 (para.Tape == 1 ? "" : (para.Tape == 2 ? ", Up" : ", Down"))
		var i = 0
		switch(para.Interval){
		case 3: i = 1; case 5: i = 2; case 15: i = 3; case 30: i = 4; case 60: i = 5;
		default: i = 0
		}
		segInterval.selectedSegmentIndex = i
		
        chartView.delegate = self

		quit = false
		LoadChart()
    }
	
	override func didMove(toParent parent: UIViewController?) {
		if parent == nil {
			quit = true
		}
	}
    
    override func viewDidLayoutSubviews() {
        chartView.frame = CGRect(x: 0, y: 0,
                                 width: mainView.frame.size.width,
								 height: mainView.frame.size.height - 85)
        mainView.addSubview(chartView)
		NSLayoutConstraint.activate(
			[
				chartView.topAnchor.constraint(equalTo: mainView.topAnchor)
			]
		)
    }
    
	@IBAction func segInterval_ValueChanged(_ sender: UISegmentedControl) {
		var i = 1
		switch(sender.selectedSegmentIndex){
		case 1: i = 3; case 2: i = 5; case 3: i = 15; case 4: i = 30; case 5: i = 60;
		default: i = 1
		}
		para.Interval = i
		LoadChart()
	}
	
	func LoadChart() {
		para.GetKlines {
			let ks = self.para.Klines
			DispatchQueue.main.async {

				self.lock = true // Пока рисуется график не запускать обновление данных
				self.setChartData()
				
				if(self.indexOfAlertedKline >= 0) {
					let k = ks[self.indexOfAlertedKline]
					self.lblAlert.text =
						"Last Alert at \(self.getxAxisLabel(k.CloseTime)), " +
						"change: " + String(format: "%.1f", self.maxChange) + "%"
				}
				else {
					self.lblAlert.text =
						"No Alerts. " +
						"Max change: " + String(format: "%.1f", self.maxChange) + "% " +
						"at " + self.maxChangeAt
				}
				self.lock = false // ... теперь можно обновить свечи для пары

				delay(bySeconds: 1){
					if !self.lock {
						if !self.quit {
							self.LoadChart()
						}
					}
				}
			}
		}
	}
	
    func setChartData() {
        
		var times = [String]()
		indexOfAlertedKline = -1
		maxChange = 0.0

		let ks = para.Klines
		let count = ks.count;
        let yVals = (0..<count).map { (i) -> CandleChartDataEntry in
            
            let k = ks[i]
			if(checkForAlert(k)) {
				indexOfAlertedKline = i
			}
			times.append(getxAxisLabel(k.CloseTime))
            return getEntry(i, k)
        }
		
        let ds = CandleChartDataSet(entries: yVals)
        ds.axisDependency = .left
        ds.setColor(UIColor(white: 80/255, alpha: 1))
        ds.drawIconsEnabled = false
        ds.shadowColor = .darkGray
		ds.shadowWidth = 2.0
        ds.decreasingColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1) //.red
        ds.decreasingFilled = true
        ds.increasingColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) //UIColor(red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        ds.increasingFilled = true
        ds.neutralColor = .blue
        
		
        let data = CandleChartData(dataSet: ds)
		
		chartView.backgroundColor = #colorLiteral(red: 1, green: 0.9446702814, blue: 0.8856676099, alpha: 1)
		chartView.leftAxis.drawLabelsEnabled = false
		chartView.xAxis.labelPosition = .bottom
		chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: times)
		//chartView.xAxis.granularity = 1
		chartView.legend.enabled = false
        chartView.data = data
    }
     
    func getEntry(_ idx: Int, _ k: Kline) -> CandleChartDataEntry {
        
		let x = Double(idx)
        let h = k.High
        let l = k.Low
        let o = k.Open
        let c = k.Close
        
		return CandleChartDataEntry(x: x, shadowH: h, shadowL: l, open: o, close: c)
    }
	
	func getxAxisLabel(_ t: UInt64) -> String {
		var t = t
		if para.Exchange == 1 {
			t = t/1000 + 1
		}
		let d = Date(timeIntervalSince1970: Double(t))
		let c = Calendar.current
		let h = c.component(.hour, from: d); //let sh = h < 10 ? "0\(h)" : "\(h)"
		let m = c.component(.minute, from: d); let sm = m < 10 ? "0\(m)" : "\(m)"
		
		return "\(h):\(sm)"
	}
	
	func checkForAlert(_ k: Kline) -> Bool {
		
		var p = 0.0
		let o = k.Open
		let h = k.High
		let l = k.Low
		
		let Type = para.Tape
		if (Type == 1) {
			p = 100.0 * (h - l) / o
		}
		else if (Type == 2) {
			p = 100 * (h - o) / o;
		}
		else if (Type == 3) {
			p = 100 * (o - l) / o;
		}
		if(p > maxChange) {
			maxChange = p
			maxChangeAt = getxAxisLabel(k.CloseTime)
		}
		let proc = para.Procent == 0 ? 0.5 : Double(para.Procent)
		if (p >= proc)
		{
			return true
		}
		return false
	}
    
    func setButtons() {
        self.navigationItem.rightBarButtonItem = 
            UIBarButtonItem(title: "Trade", style: .plain, target: nil, action: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? TradeVC {
            dest.symbol = para.Symbol
            dest.exchange = para.Exchange
        }
        
    }

}

//#Preview(){
//    ChartVC()
//}
