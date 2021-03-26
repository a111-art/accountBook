//
//  CostViewController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/13.
//

import UIKit
import CoreData
import SnapKit
protocol ReloadBook {
    func reload()
}
class CostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddCost, reloadBook, ChangeCost {
    
    var delegate: ReloadBook?
    var i = 0
    let table = UITableView()
    var costArray = [Cost]()
    var tagArray = [Tag]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Cost.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedBook: Book? {
        didSet {
            loadCosts()
        }
    }
    let restMoneylabel = UILabel()
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedBook?.bookName
        self.view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "余额"
        label.font = UIFont(name: "Helvetica", size: 15)
        self.view.addSubview(label)
        label.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(20)
            make.left.equalTo(40)
        }
        
        restMoneylabel.text = "¥" + String(selectedBook!.money)
        restMoneylabel.font = UIFont(name: "Helvetica", size: 15)
        restMoneylabel.textColor = .white
        restMoneylabel.backgroundColor = .blue
        self.view.addSubview(restMoneylabel)
        restMoneylabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(label.snp.bottom)
            make.height.equalTo(label)
            make.left.equalTo(label.snp.left).offset(5)
        }
        
        let addBtn = UIButton()
        addBtn.setTitle("添加账单", for: .normal)
        addBtn.setTitleColor(.black, for: .normal)
        self.view.addSubview(addBtn)
        addBtn.addTarget(self, action: #selector(add_Act), for: .touchUpInside)
        addBtn.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(60)
            make.width.equalToSuperview().dividedBy(2)
            make.left.equalToSuperview()
        }
        
        let pieBtn = UIButton()
        pieBtn.setTitle("统计界面", for: .normal)
        pieBtn.setTitleColor(.black, for: .normal)
        self.view.addSubview(pieBtn)
        pieBtn.addTarget(self, action: #selector(goPie), for: .touchUpInside)
        pieBtn.snp.makeConstraints{ (make) -> Void in
            make.top.height.width.equalTo(addBtn)
            make.right.equalToSuperview()
        }
    
        //MARK: table
        table.dataSource = self
        table.delegate = self
        table.register(UINib.init(nibName: "CostCell", bundle: nil), forCellReuseIdentifier: "CostCell")
        table.tableFooterView = UIView()
        table.backgroundColor = .lightGray
        view.addSubview(table)
        table.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(restMoneylabel.snp.bottom).offset(5)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(addBtn.snp.top).offset(-5)
        }
        
    }
    //MARK: dateFormatter
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
   
    //MARK: - Table View DataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return costArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CostCell? = tableView.dequeueReusableCell(withIdentifier: "CostCell") as? CostCell
        if cell == nil {
            cell = CostCell(style: .default, reuseIdentifier: "CostCell")
        }
        cell?.nameLabel?.text = costArray[indexPath.row].name
        cell?.moneyLabel?.text = "\(costArray[indexPath.row].money)"
        cell?.dateLabel?.text = Self.dateFormatter.string(from: costArray[indexPath.row].date!)
        cell?.tagLabel?.text = costArray[indexPath.row].tag?.name
        if indexPath.row == costArray.count-1 && i==0{
            i = 1
            self.table.setContentOffset(CGPoint(x: 0, y: 200.0*CGFloat((costArray.count))-self.table.frame.size.height), animated: false)
        }
            
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CostDetailController()
        vc.selectedCost = costArray[indexPath.row]
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: - Add New Costs
    func addCost(name: String, date :Date, money: Double, img: Data?, tagName: String) {
        let theTag = self.saveTag(name: tagName)
        let newCost = Cost(context: self.context)
        newCost.name = name
        newCost.date = date
        newCost.money = money
        newCost.image = img
        newCost.tag = theTag
        newCost.parentBook = self.selectedBook
        costArray.append(newCost)
        print("add  cost success")
        self.saveCost()
        loadRestMoney()
        table.reloadData()
        delegate?.reload()
    }
    func saveCost() {
        do {
            try context.save()
        }catch{
            print("Save Cost Failed:\(error)")
        }
        table.reloadData()
    }
    //MARK: load costs
    func loadCosts(with request: NSFetchRequest<Cost> = Cost.fetchRequest(), predicate: NSPredicate? = nil) {
        let bookPredicate = NSPredicate(format: "parentBook.bookName MATCHES %@",selectedBook!.bookName! )
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [bookPredicate, addtionalPredicate])
        } else {
            request.predicate = bookPredicate
        }
        
        do {
            costArray = try context.fetch(request)
        } catch {
            print("从context获取数据错误：\(error)")
        }

        table.reloadData()
    }
    //MARK: save tag
    func saveTag(name: String) -> Tag {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        do {
            tagArray = try context.fetch(request)
        } catch {
            print("载入tags错误：\(error)")
        }
        let n = tagArray.count
        if n != 0 {
            for i in 0..<n {
                if tagArray[i].name == name{
                    return tagArray[i] }
            }
        }
        let newTag = Tag(context: self.context)
        newTag.name = name
        do {
            try context.save()
        }catch{
            print("Save Cost Failed:\(error)")
        }
        return newTag
    }
    //MARK: loadRestMoney
    func loadRestMoney(){
        var restMoney = selectedBook!.money
        for i in 0..<costArray.count {
            restMoney += costArray[i].money
        }
        restMoneylabel.text = "¥" + String(restMoney)
    }
    
    func saveBook() {
        do {
            try context.save()
        }catch{
            print("Save Book Failed:\(error)")
        }
        table.reloadData()
    }
    
    //MARK: navigation
    @IBAction func showBookDetail(_ sender: Any) {
        let vc = BookDetailController()
        vc.delegate = self
        vc.book = selectedBook
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func add_Act() {
        let vc = AddCostController()
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
    @objc func goPie(){
        let vc = PieChartController()
        vc.selectedBook = selectedBook
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: change book or cost
    func reloadBook(book: Bool) {
        if book{
            delegate?.reload()
        } else {
            changeCost(CostOnly: true)
        }
    }
    func changeCost(CostOnly: Bool) {
        loadCosts()
        loadRestMoney()
        if CostOnly == false {
            delegate?.reload()
        }
    }
    
    
    
}
