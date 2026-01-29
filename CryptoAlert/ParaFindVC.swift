//
//  ParaSearchVC.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 09.09.2021.
//

import UIKit

class ParaFindVC: UITableViewController,
                  UISearchBarDelegate,
				  WebApiProtocol {

    var addVC: ParaAddVC?
    
    let webApi = WebApi()
    @IBOutlet weak var searchBar: UISearchBar!
    var arProds = [Product]()
    var arFiltr = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        webApi.delegate = self

		let Exchange = (addVC?.scExchange.selectedSegmentIndex)!+1
		webApi.Products(Exchange)
	}

    func ApiRequestDone(_ jsonDataFromServer: Data) {
        // Доступ к контролам на форме из другого потока
        DispatchQueue.main.async {
            
            self.arProds = Products(fromData: jsonDataFromServer).arr
            self.arFiltr = self.arProds
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 44
	}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arFiltr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolCell") as? ParaFindTVCell
    
        let p = arFiltr[indexPath.row] as Product
        
        cell?.lblSymbol.text = p.symbol
		cell?.lblBase.text = "\(p.cnt1)" //p.baseasset
		cell?.lblQuote.text = "\(p.cnt2)" //"p.quoteasset
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addVC!.txtSymbol.text = arFiltr[indexPath.row].symbol
        self.dismiss(animated: true)
    }
    
    // MARK: - Search bar config
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //
		if(searchText.count > 0) {
			arFiltr = arProds.filter {
				$0.symbol.contains(searchText.uppercased())
			}
		}
        
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
}
