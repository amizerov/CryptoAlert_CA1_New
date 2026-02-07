//
//  ProductSearchVC.swift
//  CryptoAlert
//
//  Version 9.3 by Andrey Mizerov on 05.10.2022.
//

import Foundation
import UIKit

class ProdFindVC: UIViewController,
                  WebApiProtocol {

    @IBOutlet weak var btnProd: UIButton!
    @IBOutlet weak var btnChan: UIButton!
    @IBOutlet weak var btnVolu: UIButton!
    
    var addVC: ParaAddVC?
    let webApi = WebApi()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var arProds = [Product]()
    var arFiltr = [Product]()
    
    var sort = 2 // 1-SymUp, 2-SymDn, 3-ChaUp, 4-ChaDn, 5-VolUp, 6-VolDn
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webApi.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        btnProd.setImage(UIImage(systemName: "poweroff"), for: .normal)
        btnChan.setImage(UIImage(systemName: "poweroff"), for: .normal)
        btnVolu.setImage(UIImage(systemName: "poweroff"), for: .normal)
        
        let exchId = (addVC?.scExchange.selectedSegmentIndex)!+1
        webApi.Products(exchId)

        searchBar.delegate = self
        //searchBar.showsScopeBar = true
        //searchBar.scopeButtonTitles = ["All", "USD", "ETH", "BTC"]
        //searchBar.showsCancelButton = true
        searchBar.placeholder = Exchange.DisplayName(for: exchId)
        searchBar.selectedScopeButtonIndex = 0
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
    
    func updateSearchResults() {
        let txtSearch = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let scopeTitles = searchBar.scopeButtonTitles ?? ["All"]
        let selectedIndex = max(0, min(searchBar.selectedScopeButtonIndex, scopeTitles.count - 1))
        let txtFilter = scopeTitles[selectedIndex]

        func haystack(_ p: Product) -> String {
            // Ищем по всем полям: symbol + baseasset + quoteasset
            "\(p.symbol) \(p.baseasset) \(p.quoteasset)".uppercased()
        }

        if !txtSearch.isEmpty {
            if txtFilter != "All" {
                let scope = txtFilter.uppercased()
                arFiltr = arProds.filter {
                    let h = haystack($0)
                    return h.contains(txtSearch) && h.contains(scope)
                }
            } else {
                arFiltr = arProds.filter { haystack($0).contains(txtSearch) }
            }
        } else {
            if txtFilter != "All" {
                let scope = txtFilter.uppercased()
                arFiltr = arProds.filter { haystack($0).contains(scope) }
            } else {
                arFiltr = arProds
            }
        }
        
        switch sort {
        case 1:
            // SymUp \-\> baseasset A\.\.Z
            arFiltr = arFiltr.sorted(by: { $0.baseasset < $1.baseasset })
        case 2:
            // SymDn \-\> baseasset Z\.\.A
            arFiltr = arFiltr.sorted(by: { $0.baseasset > $1.baseasset })
        case 3:
            arFiltr = arFiltr.sorted(by: { $0.cnt1 < $1.cnt1 })
        case 4:
            arFiltr = arFiltr.sorted(by: { $0.cnt1 > $1.cnt1 })
        case 5:
            arFiltr = arFiltr.sorted(by: { $0.cnt2 < $1.cnt2 })
        case 6:
            arFiltr = arFiltr.sorted(by: { $0.cnt2 > $1.cnt2 })
        default:
            arFiltr = arFiltr.sorted(by: { $0.symbol < $1.symbol })
        }
        
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    @IBAction func btnSort_Clicked(_ sender: UIButton) {
        // 1-SymUp, 2-SymDn, 3-ChaUp, 4-ChaDn, 5-VolUp, 6-VolDn
        if sender == btnProd {
            if sort == 1 {
                sort = 2
                arFiltr = arFiltr.sorted(by: { $0.baseasset > $1.baseasset })
            } else {
                sort = 1
                arFiltr = arFiltr.sorted(by: { $0.baseasset < $1.baseasset })
            }
            btnChan.setImage(UIImage(systemName: "poweroff"), for: .normal)
            btnVolu.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
        if sender == btnChan {
            if sort == 4 {
                sort = 3
                arFiltr = arFiltr.sorted(by: { $0.cnt1 < $1.cnt1 })
            }
            else {
                sort = 4
                arFiltr = arFiltr.sorted(by: { $0.cnt1 > $1.cnt1 })
            }
            btnProd.setImage(UIImage(systemName: "poweroff"), for: .normal)
            btnVolu.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
        if sender == btnVolu {
            if sort == 6 {
                sort = 5
                arFiltr = arFiltr.sorted(by: { $0.cnt2 < $1.cnt2 })
            }
            else {
                sort = 6
                arFiltr = arFiltr.sorted(by: { $0.cnt2 > $1.cnt2 })
            }
            btnChan.setImage(UIImage(systemName: "poweroff"), for: .normal)
            btnProd.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
        let ud = sort % 2 == 0 ? "down" : "up"
        sender.setImage(UIImage(systemName: "arrowtriangle.\(ud).fill"), for: .normal)

        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
}

extension ProdFindVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        updateSearchResults()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        updateSearchResults()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        searchBar.text = ""
        
        arFiltr = arProds
        searchBar.selectedScopeButtonIndex = 0
        
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
}

extension ProdFindVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arFiltr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProdFindCell") as? ProdFindTVCell
    
        let p = arFiltr[indexPath.row] as Product
        cell?.UpdateData(p)

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let prod = arFiltr[indexPath.row]
        addVC!.txtSymbol.text = prod.baseasset+"/"+prod.quoteasset
        addVC!.selectedSymbol = prod.symbol
        addVC!.selectedProductId = prod.id
        
        self.dismiss(animated: true)
    }
}
