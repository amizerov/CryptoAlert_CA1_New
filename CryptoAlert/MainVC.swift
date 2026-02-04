//
//  ViewController.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 27.08.2021.
//

import UIKit
import CoreMedia

class MainVC: UIViewController,
              UITableViewDelegate, UITableViewDataSource,
              WebApiProtocol, UISearchResultsUpdating, UISearchBarDelegate
{
    // MARK: Search section ***************************************
    @IBAction func btnSearch_Clicked(_ sender: UIBarButtonItem) {
        tbvParas.tableHeaderView = searchBar
        //searchBar?.becomeFirstResponder()
        searchBar?.searchTextField.becomeFirstResponder()
    }
    func searchSetUp() {
        searchCon.searchResultsUpdater = self
        searchCon.searchBar.delegate = self
        definesPresentationContext = true
        searchBar = searchCon.searchBar
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        arParas = arParaf

        tbvParas.tableHeaderView = nil
        
        self.tbvParas.reloadData()
        self.tbvParas.refreshControl?.endRefreshing()
    }
    func updateSearchResults(for searchController: UISearchController) {
        var str = searchBar?.text
        if str == nil { str = "" }
        if (str?.count)! > 0 {
            str = str?.uppercased()
            arParas = arParaf.filter {
                $0.Symbol.contains(str!) ||
                $0.baseAsset.uppercased().contains(str!)
            }
        }
        else {
            arParas = arParaf
        }
        self.tbvParas.reloadData()
        self.tbvParas.refreshControl?.endRefreshing()
        return
    }
    //*************************************** End Search section
    
    @IBOutlet weak var btnProfile: UIBarButtonItem!
    
    @IBOutlet weak var btnLevel1: UIBarButtonItem!
    @IBOutlet weak var btnLevel2: UIBarButtonItem!
    @IBOutlet weak var btnLevel3: UIBarButtonItem!
    @IBOutlet weak var btnLevel4: UIBarButtonItem!
    
    //@IBOutlet weak var btnOrders: UIBarButtonItem!
    @IBOutlet weak var btnAlerts: UIBarButtonItem!
	//@IBOutlet weak var btnVOrders: UIBarButtonItem!

	@IBOutlet weak var tbvParas: UITableView!
    let searchCon = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar?
    
    var NeedToReload = false
    var webApi = WebApi()
    var arParas = [Para]()
    var arParaf = [Para]()
	var arOrders = [Order]()
    var Level = 1
    
	override func viewWillAppear(_ animated: Bool) {
		print("AM: \(usr.Name)")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ver = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let bld = Bundle.main.infoDictionary!["CFBundleVersion"]!
        logger.Log("Start ver.\(ver)(\(bld))")
        
        searchSetUp()
        
        webApi.delegate = self
        SetColos()
        
        // Регистрация кастомного вью для ячейки таблицы
        let nib1 = UINib(nibName: "TableViewCell", bundle: nil)
        tbvParas.register(nib1, forCellReuseIdentifier: "TableViewCell")
		let nib2 = UINib(nibName: "OrderTVCell", bundle: nil)
		tbvParas.register(nib2, forCellReuseIdentifier: "OrderTVCell")

        // Первоначальная загрузка данных в таблицу
        LoadDataFromServer()
        
        tbvParas.delegate = self
        tbvParas.dataSource = self
        
        // Обновление данных когда потянешь экран вниз
        tbvParas.refreshControl = UIRefreshControl()
        tbvParas.refreshControl?.addTarget(self, action: #selector(qqq), for: .valueChanged)
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
    }
    
    @objc func qqq() {
        // .. для обновления данных когда потянешь экран вниз
        LoadDataFromServer()
    }

    @IBAction func btnLevel_Click(_ sender: UIBarButtonItem) {
        Level = sender.tag
        if(Level == 0) {return}
        LoadDataFromServer()
    }
	@IBAction func btnAlerts_Click(_ sender: UIBarButtonItem) {
        Level = 5
        LoadDataFromServer()
    }
	@IBAction func btnOrders_Click(_ sender: UIBarButtonItem) {
		Level = 6
		LoadDataFromServer()
	}
	@IBAction func btnVOrders_Click(_ sender: UIBarButtonItem) {
		Level = 7
		LoadDataFromServer()
	}
	
    // Асинхронная функция получения данных с сервера через JSON REST API
    func LoadDataFromServer() {
        if(Level == 5)
        {
            webApi.Alert()
			//UIApplication.shared.applicationIconBadgeNumber = 0
            UNUserNotificationCenter.current().setBadgeCount(0) 
        }
		else if(Level == 6) {
			WebApi.GetOrders() { arrOrderStr in
				
				self.arOrders.removeAll()
				arrOrderStr.forEach{ o in self.arOrders.append(Order(o)) }

				DispatchQueue.main.async {
					self.SetColos()
					self.tbvParas.reloadData()
					self.tbvParas.refreshControl?.endRefreshing()
				}
			}
		}
		else if(Level == 7) {
			WebApi.GetOrdersFilled() { arrOrderStr in
				
				self.arOrders.removeAll()
				arrOrderStr.forEach{ o in self.arOrders.append(Order(o)) }

				DispatchQueue.main.async {
					self.SetColos()
					self.tbvParas.reloadData()
					self.tbvParas.refreshControl?.endRefreshing()
				}
			}
		}
        else {
            logger.Log("LoadDataFromServer")
            webApi.List(lvl: Level)
        }
    }
    
    func ApiRequestDone(_ jsonDataFromServer: Data) {
        // Доступ к контролам на форме из другого потока
        DispatchQueue.main.async {
            
            self.searchBarCancelButtonClicked(UISearchBar())
            self.SetColos()
            
            //logger.Log("ParasLoaded")
            
            self.arParas = Paras(fromData: jsonDataFromServer).arr
            self.arParaf = self.arParas
            
            self.tbvParas.reloadData()
            self.tbvParas.refreshControl?.endRefreshing()
            
            //logger.Log("ParasParsed")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Вызывается при возврате и любом появлении таблицы на экране
        // Если на экране редактирования оплаты поменяли данные,
        // то надо обновить таблицу
        if NeedToReload {
            LoadDataFromServer()
            NeedToReload = false
        }
        btnProfile.title = usr.Name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var cnt = 0
		
		if Level >= 6 { cnt = arOrders.count }
		else { cnt = arParas.count }
        
		return cnt
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 103
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if Level >= 6
		{
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTVCell") as? OrderTVCell
			cell?.backgroundColor = view.backgroundColor
			
			let o = arOrders[indexPath.row]
			cell?.fillData(o)
			
			return cell!
		}
		else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? ParaTVCell
			cell?.backgroundColor = view.backgroundColor
			
			let p = arParas[indexPath.row]
			cell?.fillData(p)
			
			return cell!
		}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let dv = storyboard?
            .instantiateViewController(identifier: "ParaEditVC") as? ParaEditVC {
			
            dv.mainVC = self
            dv.thePara = arParas[indexPath.row]

            self.navigationController?.pushViewController(dv, animated: Level < 5)
			
			if(Level == 5) {
				if let cv = storyboard?
					.instantiateViewController(withIdentifier: "ChartVC") as? ChartVC {
					cv.para = arParas[indexPath.row]
					self.navigationController?.pushViewController(cv, animated: true)
				}
			}
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Перед тем как открыть модальное окно создания новой пары
        // надо передать в него ссылку на себя на основное вью
        if segue.destination is ParaAddVC {
            let vc = segue.destination as? ParaAddVC
            vc?.mainVC = self
        }
        if segue.destination is ProfileVC {
            let vc = segue.destination as? ProfileVC
            vc?.mainVC = self
        }
        if segue.destination is SoundsVC {
            let vc = segue.destination as? SoundsVC
            
            vc?.Level = Level == 6 ? 1 : Level
        }
    }
    /* Сдвиг влево для редактирования - удаления,
       заменили на свайп для переключения между уровнями.
       Удаление перенес в редактор пары6 по кнопке Удалить.
     ----------------------------------------------------
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        let p = arParas[indexPath.item]
        let id = p.ID
        let sy = p.Symbol
        let us = p.User
        webApi.Delete("\(id);\(sy);\(us)")
        
        arParas.remove(at: indexPath.item)
        tableView.deleteRows(at: [indexPath], with: .top)
    }*/

    func SetColos()
    {
        var c = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        let cc = #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1)
        
        btnLevel1.tintColor = c; StyleButton(btnLevel1, "1")
        btnLevel2.tintColor = c; StyleButton(btnLevel2, "2")
        btnLevel3.tintColor = c; StyleButton(btnLevel3, "3")
        btnLevel4.tintColor = c; StyleButton(btnLevel4, "4")
		btnAlerts.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		//btnOrders.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		//btnVOrders.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        if(Level == 4) { c = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            btnLevel4.tintColor = cc
            UnStyleButton(btnLevel4)
        }        
        if(Level == 3) { c = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            btnLevel3.tintColor = cc
            UnStyleButton(btnLevel3)
        }
        if(Level == 2) { c = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            btnLevel2.tintColor = cc
            UnStyleButton(btnLevel2)
        }
        if(Level == 1) { c = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            btnLevel1.tintColor = cc
            UnStyleButton(btnLevel1)
        }
        if(Level == 5) { c = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1);  btnAlerts.tintColor = c }
		//if(Level == 5) { c = #colorLiteral(red: 0.9230434299, green: 0.8728587031, blue: 0.8091325164, alpha: 1);  btnOrders.tintColor = c }
		//if(Level == 6) { c = #colorLiteral(red: 0.8307692279, green: 0.8862745166, blue: 0.6189431401, alpha: 1);  btnVOrders.tintColor = c }

        //navigationController?.navigationBar.backgroundColor = c
        navigationController?.navigationBar.tintColor = cc
        view.backgroundColor = c
        
        let l = Level
        if(l == 5) {
            self.title = "Алерты"
        }
        else {
            self.title = "\(l)-" +
                (l == 1 ? "ый" : (l == 2 ? "ой" : (l == 3 ? "ий" : "ый"))) +
                " уровень"
        }
    }
    
    func StyleButton(_ btn: UIBarButtonItem, _ img: String) {
        let b = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        b.addTarget(self, action: #selector(btnLevel_Click), for: .touchUpInside)
        b.setBackgroundImage(UIImage(named: img), for: .normal)
        b.tag = Int(img)!
        b.layer.cornerRadius = 20
        b.layer.masksToBounds = true
        btn.customView = b
    }
    func UnStyleButton(_ btn: UIBarButtonItem) {
        btn.customView = nil
    }
    
    // MARK: Swipe guesture section
    @objc func swipedLeft(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            if(Level < 6) {Level += 1}
            LoadDataFromServer()
        }
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            if(Level > 1) {Level -= 1}
            LoadDataFromServer()
        }
    }
    
    lazy var leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .left
        gesture.addTarget(self, action: #selector(swipedLeft))
        return gesture
    }()
    
    lazy var rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .right
        gesture.addTarget(self, action: #selector(swipedRight))
        return gesture
    }()
}

