//
//  ParaAddVC.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 29.08.2021.
//

import UIKit

class ParaAddVC: UIViewController, WebApiProtocol {

    var webApi = WebApi()
    var mainVC: MainVC?
    var selectedSymbol: String?
    var selectedProductId: Int?
    
    @IBOutlet weak var txtSymbol: UITextField!
	@IBOutlet weak var scExchange: UISegmentedControl!
	@IBOutlet weak var lblInterval: UILabel!
    @IBOutlet weak var stpInterval: UIStepper!
    @IBOutlet weak var lblProcent: UILabel!
    @IBOutlet weak var stpProcent: UIStepper!
    @IBOutlet weak var scType: UISegmentedControl!
    @IBOutlet weak var scLevel: UISegmentedControl!
    @IBOutlet weak var btnSave: UIButton!
    
    enum Exchange: Int {
        case binance = 0
        case kucoin  = 1
        case huobi   = 2
        case alfa    = 3
    }

    var currentExchange: Exchange {
        guard isViewLoaded else { return .binance }
        return Exchange(rawValue: scExchange.selectedSegmentIndex) ?? .binance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webApi.delegate = self

        stpInterval.value = Double(lblInterval.text!)!
        stpProcent.value = Double(lblProcent.text!)!

        scLevel.selectedSegmentIndex = (mainVC?.Level)! - 1
        //addToolBar(textField: txtSymbol)
    }

    @IBAction func Interval_Changed(_ sender: UIStepper) {

        let ex = currentExchange
        var i = Int(sender.value)
        let p = Int(lblInterval.text ?? "") ?? i

        // Перескоки нужны, потому что stepper меняет значение на +1/-1,
        // а мы разрешаем только "дискретный" набор интервалов (например 1,3,5,15,30,60).
        // Поэтому промежуточные числа (2,4,6..,14.. и т.д.) мы не показываем, а перепрыгиваем на ближайшее допустимое.

        // 1 -> (2) : число 2 запрещено. Для Binance/Kucoin/Alfa прыгаем на 3.
        // Для Huobi правила другие: после 1 сразу разрешён 5, поэтому прыжок на 5.
        if (i == 2 && p == 1) { i = (ex == .huobi) ? 5 : 3; stpInterval.value = Double(i) }

        // 5 -> (4) : число 4 запрещено. Для Binance/Kucoin/Alfa возвращаемся на 3.
        // Для Huobi возвращаемся сразу на 1 (обратное правило к предыдущему).
        if (i == 4 && p == 5) { i = (ex == .huobi) ? 1 : 3; stpInterval.value = Double(i) }

        // Защита от "неправильного" прохода через 2/4 вокруг 3:
        // если пользователь оказался на 2 при движении от 3 — откатываем на 1,
        // если оказался на 4 при движении от 3 — докидываем на 5.
        if (i == 2 && p == 3) { i = 1;  stpInterval.value = Double(i) }
        if (i == 4 && p == 3) { i = 5;  stpInterval.value = Double(i) }

        // Дальше — превращаем линейную шкалу степпера в "ступени" допустимых интервалов.
        // Промежуточные значения не используются: перепрыгиваем через них.
        if (i == 6)  { i = 15; stpInterval.value = Double(i) } // после 5 следующий допустимый — 15 (пропускаем 6..14)
        if (i == 14) { i = 5;  stpInterval.value = Double(i) } // обратный перескок: перед 15 возвращаемся на 5
        if (i == 16) { i = 30; stpInterval.value = Double(i) } // после 15 следующий допустимый — 30 (пропускаем 16..29)
        if (i == 29) { i = 15; stpInterval.value = Double(i) } // обратный перескок: перед 30 возвращаемся на 15
        if (i == 31) { i = 60; stpInterval.value = Double(i) } // после 30 следующий допустимый — 60 (пропускаем 31..59)
        if (i == 59) { i = 30; stpInterval.value = Double(i) } // обратный перескок: перед 60 возвращаемся на 30

        // Финально синхронизируем UI: label всегда должен показывать фактический выбранный интервал.
        lblInterval.text = "\(i)"
    }

    
    @IBAction func Procent_Changed(_ sender: UIStepper) {
        let proc = Int(sender.value)
        lblProcent.text = proc == 0 ? "0,5" : "\(proc)"
    }

    func EnableControls(_ b: Bool) {
        txtSymbol.isEnabled = b
        stpInterval.isEnabled = b
        scLevel.isEnabled = b
        stpProcent.isEnabled = b
        scType.isEnabled = b
        btnSave.isEnabled = b
    }
    
    func AddNewPara() {

        // SYMBOL: убираем пробелы, чтобы "BTC USDT" превратилось в "BTCUSDT"
        //let s = selectedSymbol!.replacingOccurrences(of: " ", with: "")
        let s = "\(selectedProductId ?? 0)"

        // INTERVAL: уже “причесан” в Interval_Changed (разрешённые значения типа 1/3/5/15/30/60)
        let i = lblInterval.text!

        // 1=Binance, 2=Kucoin, 3=Huobi, 4=Alfa (Alfa как Binance по логике, но на сервере это другой endpoint)
        let e = String((Exchange(rawValue: scExchange.selectedSegmentIndex) ?? .binance).rawValue + 1)

        // PERCENT: спец-кейс — "0,5" заменяем на "0" (как у вас было, чтобы сервер корректно принял)
        var p = lblProcent.text!; if p == "0,5" { p = "0" }

        // LEVEL (1-based): UI индекс 0..N превращаем в значение 1..N+1 для протокола
        let l = "\(scLevel.selectedSegmentIndex + 1)"

        // TYPE (1-based): UI индекс 0..N превращаем в значение 1..N+1 для протокола
        let t = "\(scType.selectedSegmentIndex + 1)"

        // PARA: "0" в начале означает, что id пары нет => сервер должен СОЗДАТЬ новую пару наблюдения
        let para = "0;\(s);\(e);\(i);\(p);\(t);\(l)"

        // UI: блокируем контролы на время сетевого запроса и отправляем строку на сервер
        EnableControls(false); webApi.SetPara(para)
    }
    
    func ApiRequestDone(_ jsonDataFromServer: Data) {
        // Доступ к контролам на форме из другого потока
        DispatchQueue.main.async {
            self.mainVC?.Level = self.scLevel.selectedSegmentIndex+1
            self.mainVC?.LoadDataFromServer()
            self.dismiss(animated: true)
            print("New para id = " + String(data: jsonDataFromServer, encoding: .utf8)!)
        }
    }
    @IBAction func btnSaveClick(_ sender: UIButton) {
        AddNewPara()
    }
    
    //************************************
    //Убрать клаву касанием по белому
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ProdFindVC {
            let vc = segue.destination as? ProdFindVC
            vc?.addVC = self
        }
    }
}
//************************************
//Добавляем тулбар для клавиатуры редактора символа
//ошибка с констрэйнами
extension UIViewController {
    
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()

        //textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func donePressed(){ view.endEditing(true) }
    @objc func cancelPressed(){ view.endEditing(true) }

}
