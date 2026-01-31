//
//  Para.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 27.08.2021.
//

import Foundation

class Paras {
    var arr = [Para]()
    
    init(fromData: Data = Data()){

        do {
            let ps = try JSONDecoder().decode([String].self, from: fromData)
            ps.forEach { p in
                
                let a = p.split(separator: ";")
                if(a.count < 8) { logger.Log("Bad para"); return }
                
                let id = Int(a[0])!
                let sy = String(a[1])
				let ex = Int(a[2])!
                let iv = Int(a[3])!
                let pr = Int(a[4])!
                let ty = Int(a[5])!
                let le = Int(a[6])!
                let us = String(a[7])
                let dt = String(a[8])
                
                let p = Para(id, sy, ex, iv, pr, ty, le, us, dt)
                arr.append(p)
            }
        }
        catch {
            logger.Log("Ошбка парсинга Paras: \(error)")
        }
    }
}

class Para {

    var ID = 0
    var Symbol = ""
	var Exchange = 1
    var baseAsset = ""
    var quoteAsset = ""
    var Interval = 0
    var Procent = 0
    var Tape = 0
    var Level = 0
    var User = ""
    var Dtc = ""
    
    var Klines = [Kline]()
    
	init(_ id: Int, completion: @escaping (_ para: Para) -> Void) {
		
		WebApi.GetPara(id) { data in
			
			let p = String(decoding: data, as: UTF8.self)
			let a = p.split(separator: ";")
			
			self.ID = Int(a[0])!
			self.Symbol = String(a[1])
			self.Exchange = Int(a[2])!
			self.Interval = Int(a[3])!
			self.Procent = Int(a[4])!
			self.Tape = Int(a[5])!
			self.Level = Int(a[6])!
			self.User = String(a[7])
			self.Dtc = String(a[8])
					
			completion(self)
		}
	}

	init(_ id: Int = 0, _ symb: String = "Use it for empty constructor", _ excha: Int = 0,
		 _ inter: Int = 0, _ pro: Int = 0, _ typ: Int = 0, _ lvl: Int = 0,
		 _ usr: String = "", _ dtc: String = "")
    {
		if(symb == "Use it for empty constructor") { return }
        ID = id
        Symbol = symb.uppercased()
		Exchange = excha
        Interval = inter
        Procent = pro
        Tape = typ
        Level = lvl
        User = usr
        Dtc = dtc == "@" ? "@" : DateToLocal(dtc)
    }

    func SymbolDecorate() -> String {
		
		// Binance Symbol has no separator but Kucoin has
		var s = Symbol; if s.contains("-") { return s }
        var b = false

        (s, b) = Decorator("USDT"); if(b){return s}
        (s, b) = Decorator("TUSD"); if(b){return s}
        (s, b) = Decorator("EUR"); if(b){return s}
        (s, b) = Decorator("BTC"); if(b){return s}
        (s, b) = Decorator("ETH"); if(b){return s}
        (s, b) = Decorator("BUSD"); if(b){return s}
        (s, b) = Decorator("STEEM"); if(b){return s}
        (s, b) = Decorator("USDC"); if(b){return s}
        (s, b) = Decorator("BNB"); if(b){return s}
        
        return s
    }
    
    private func Decorator(_ sym: String) -> (String, Bool) {
        var s = Symbol
        var b = false
		
        if let r: Range<String.Index> = s.range(of: sym) {
            b = true
            let i: Int = s.distance(from: s.startIndex, to: r.lowerBound)
            if(i == 0) {
                s = s.replacingOccurrences(of: sym, with: "\(sym)/")
            }
            else {
                s = s.replacingOccurrences(of: sym, with: "/\(sym)")
            }
        }
        return (s, b)
    }
    
    private func DateToLocal(_ d: String) -> String {
        var res = "", t = "", M = 0, D = 0

        let a1 = d.split(separator: " ")

        let a2 = a1[0].split(separator: ".")
        if a2.count < 2 {
            M = Calendar.current.component(.month, from: Date())
            D = Calendar.current.component(.day, from: Date())
            t = String(a1[0])
        }
        else {
            M = Int(a2[1])!
            D = Int(a2[0])!
            t = String(a1[1])
        }
        
        let a3 = t.split(separator: ":")
        if a3.count < 2 { logger.Log("Wrong dtc3 \(d)"); return d }

        let h = Int(a3[0])
        let m = Int(a3[1])

        let dc = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone(abbreviation: "GMT+3"),
            year: Calendar.current.dateComponents([.year], from: Date()).year,
            month: M, day: D, hour: h, minute: m
        )
        let date = dc.date!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        res = formatter.string(from: date)
        
        return res
    }
    
	func GetKlines(completion: @escaping () -> Void) {
		if Exchange == 1 {
			BinanceApi.GetChartData2(Symbol, Interval) { data in
				self.LoadKlines(data)
				completion()
			}
		}
		else if Exchange == 2 {
			KucoinApi.GetChartData(Symbol, Interval) { data in
				self.LoadKlines(data)
				completion()
			}
		}
		else if Exchange == 3 {
			HuobiApi.GetChartData(Symbol, Interval) { data in
				self.LoadKlines(data)
				completion()
			}
		}
        else {
            AlfaBApi.GetChartData(Symbol, Interval) { data in
                self.LoadKlines(data)
                completion()
            }
        }
	}
	
    func LoadKlines(_ data: Data) {
        let jsonDecoder = JSONDecoder()
        do {
			if Exchange == 1 {
				var bks = [BinaKline]()
				bks = try jsonDecoder.decode([BinaKline].self, from: data)
				Klines.removeAll()
				for bk in bks {
					let k = Kline()
					k.Open = Double(bk.Open)!
					k.Close = Double(bk.Close)!
					k.High = Double(bk.High)!
					k.Low = Double(bk.Low)!
					k.CloseTime = bk.CloseTime
					Klines.append(k)
				}
			}
			else if Exchange == 2 {
				var kk: KucoKline
				kk = try jsonDecoder.decode(KucoKline.self, from: data)
				Klines.removeAll()
				for d in kk.data {
					let k = Kline()
					k.Open = Double(d[1])!
					k.Close = Double(d[2])!
					k.High = Double(d[3])!
					k.Low = Double(d[4])!
					k.CloseTime = UInt64(d[0])! + UInt64(Interval * 60)
					Klines.append(k)
				}
				Klines = Klines.reversed()
			}
            else if Exchange == 3 {
				var kk: HuobiKline
				kk = try jsonDecoder.decode(HuobiKline.self, from: data)
				Klines.removeAll()
				for d in kk.data {
					let k = Kline()
					k.Open = d.open
					k.Close = d.close
					k.High = d.high
					k.Low = d.low
					k.CloseTime = d.id + UInt64(Interval * 60)
					Klines.append(k)
				}
				Klines = Klines.reversed()
			}
            else {
                let resp = try jsonDecoder.decode(BinanceAlphaKlinesResponse.self, from: data)
                Klines.removeAll(keepingCapacity: true)
                guard resp.code == "000000" else { return }

                for bk in resp.data {
                    guard
                        let o = Double(bk.open),
                        let c = Double(bk.close),
                        let h = Double(bk.high),
                        let l = Double(bk.low)
                    else { continue }

                    let k = Kline()
                    k.Open = o
                    k.Close = c
                    k.High = h
                    k.Low = l
                    k.CloseTime = bk.closeTime/1000
                    Klines.append(k)
                }
            }
        } catch {
            print("AM: \(error)")
        }
    }
}

