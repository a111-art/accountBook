//
//  SearchViewController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/17.
//

import UIKit
import CoreData
class SearchViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    var costs: [Cost] = []
    var filteredCosts: [Cost] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //MARK: viewDIdLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.backButtonTitle = ""
        
        searchTable.tableFooterView = UIView()
        searchTable.dataSource = self
        searchTable.delegate = self
        searchTable.register(UINib.init(nibName: "CostCell", bundle: nil), forCellReuseIdentifier: "CostCell")
        loadCosts()
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "ShowDetailSegue",
            let indexPath = searchTable.indexPathForSelectedRow,
            let detailViewController = segue.destination as? DetailViewController
        else {
            return
        }
        let cost: Cost
            cost = filteredCosts[indexPath.row]
        detailViewController.cost = cost
    }
    */
    //MARK: load cost
    func loadCosts() {
           let request: NSFetchRequest<Cost> = Cost.fetchRequest()
           do {
            costs = try context.fetch(request)
            } catch {
                print("载入Cost错误：\(error)")
            }
        searchTable.reloadData()
    }
    //MARK: dateFormatter
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    //MARK: tableview
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(filteredCosts.count)
        return filteredCosts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CostCell? = tableView.dequeueReusableCell(withIdentifier: "CostCell", for: indexPath) as? CostCell
        if cell == nil {
            cell = CostCell(style: .default, reuseIdentifier: "CostCell")
        }
        cell?.tagLabel.text = filteredCosts[indexPath.row].tag?.name
        cell?.nameLabel.text = filteredCosts[indexPath.row].name
        cell?.moneyLabel.text = "\(filteredCosts[indexPath.row].money)"
        cell?.dateLabel.text = self.dateFormatter.string(from: filteredCosts[indexPath.row].date!)
        return cell!
       }
}
//MARK:SearchController
extension SearchViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text  = ""
        searchBar.endEditing(true)
        filteredCosts = costs
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        filteredCosts = searchText.isEmpty ? costs : costs.filter({ (cost: Cost) -> Bool in return (cost.name!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil ) || (cost.tag?.name!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil ) || (dateFormatter.string(from: cost.date!).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil ) })
        searchTable.reloadData()
    }
}
