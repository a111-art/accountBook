//
//  BookViewController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/11.
//

import UIKit
import CoreData
import SnapKit

class BookViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, AddBook, UISearchBarDelegate, ReloadBook {
   
    var bookArray = [Book]()
    var costArray = [Cost]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let table = UITableView()
  //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBooks()
        
        let tabbar = CustomizedTabBar()
        //let tabbar = CustomizedTabBar(frame: CGRect(x: 0, y: view.frame.size.height-47, width: view.frame.size.width, height: 47))
        self.view.addSubview(tabbar)
        tabbar.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalToSuperview()
            make.width.left.equalToSuperview()
            make.height.equalTo(60)
        }
        
        //MARK: addbtn
        let addButton = UIButton()
        //addButton.frame=CGRect(x: view.frame.size.width/2-33, y: view.frame.size.height-80, width: 66, height: 66)
        addButton.setImage(UIImage(named: "addImg"), for: .normal)
        addButton.layer.cornerRadius = 33
        addButton.layer.masksToBounds = true
        addButton.layer.borderColor = UIColor.black.cgColor
        addButton.layer.borderWidth = 1
        addButton.adjustsImageWhenHighlighted = false
        self.view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(touchAdd), for: .touchUpInside)
        addButton.snp.makeConstraints{ (make) -> Void in
            make.height.width.equalTo(66)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(tabbar.snp.top)
        }
        
        //MARK: searchBtn
        let searchBtn = UIButton()
         searchBtn.setTitleColor(.gray, for: .normal)
         searchBtn.setTitle("搜索", for: .normal)
         searchBtn.contentHorizontalAlignment = .left
         searchBtn.layer.cornerRadius = 5
         searchBtn.layer.borderWidth = 1
         searchBtn.layer.borderColor = UIColor.gray.cgColor
         self.view.addSubview(searchBtn)
         searchBtn.addTarget(self, action: #selector(goSearch), for: .touchUpInside)
         searchBtn.snp.makeConstraints{ (make) -> Void in
             make.height.equalTo(45)
             make.right.equalToSuperview().offset(-20)
             make.left.equalToSuperview().offset(20)
             make.top.equalToSuperview().offset(100)
         }
        //MARK: table
         table.tableFooterView = UIView()
         table.backgroundColor = .white
         self.view.addSubview(table)
         table.dataSource = self
         table.delegate = self
         table.register(UINib.init(nibName: "BookCell", bundle: nil), forCellReuseIdentifier: "BookCell")
         table.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(searchBtn.snp.bottom).offset(10)
             make.left.equalToSuperview()
             make.right.equalToSuperview()
            make.bottom.equalTo(addButton.snp.top)
         }
    }
    //MARK: add & search actions
    @objc func touchAdd() {
        let vc = AddBookController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: false)
    }
    @objc func goSearch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Table View 方法
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return bookArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for:indexPath) as! BookCell
        if indexPath.section == 0{
            cell.nameLabel.text = "小助手"
            cell.detailLabel.text = "账单日报"
            cell.picture.image = UIImage(named: "组 40")
        } else {
            cell.nameLabel.text = bookArray[indexPath.row].bookName
            cell.detailLabel.text = newestCell(index: indexPath.row)
             if bookArray[indexPath.row].img != nil{
                cell.picture.image = UIImage(data: bookArray[indexPath.row].img!)
             }
        }
        return cell
    }
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
         if indexPath.section == 0{
            self.navigationController?.pushViewController(HelpController(), animated: false)
         }
        if indexPath.section == 1{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "CostViewController") as? CostViewController else { return }
            vc.selectedBook = bookArray[indexPath.row]
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func newestCell(index: Int) -> String {
        let request: NSFetchRequest<Cost> = Cost.fetchRequest()
        let costPredicate = NSPredicate(format: "parentBook.bookName MATCHES %@",bookArray[index].bookName! )
        request.predicate = costPredicate
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            costArray = try context.fetch(request)
        } catch {
            print("从context获取数据错误：\(error)")
        }
        if costArray.count > 0{
            let str = (costArray.last?.tag?.name)! + String(costArray.last!.money) + "元"
            return str
        }else{
            return ""
        }
    }
   /* func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
                    //创建“删除”事件按钮
         let delete = UITableViewRowAction(style: .normal, title: "删除") { action, index in
        //将对应条目的数据删除
             self.bookArray.remove(at: index.row)
             tableView.reloadData()
             }
         delete.backgroundColor = UIColor.red
                     
         //返回所有的事件按钮
         return [delete]
    }
    */
    //MARK: table 侧滑
    @available( iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1{
        let deteleAct = UIContextualAction(style: .destructive, title: "删除"){
            (action, sourceView, actionPerformed) in
            print("Delete Book")
            self.showAlert(indexPath: indexPath)
            actionPerformed(true)
        }
        deteleAct.backgroundColor = .red
        
        let topAct = UIContextualAction(style: .destructive, title: "置顶"){
            (action, sourceView, actionPerformed) in
            print("the Book become first one")
            self.bookArray[indexPath.row].top = true
            self.bookArray[0].top = false
            self.bookArray[indexPath.row].setValue(true, forKey: "top")
            self.bookArray[0].setValue(false, forKey: "top")
            let theBook = self.bookArray[indexPath.row]
            self.bookArray.remove(at: indexPath.row)
            self.bookArray.insert(theBook, at: 0)
            self.table.reloadData()
            self.saveBook()
            actionPerformed(true)
        }
        topAct.backgroundColor = .gray
        
        let configuration = UISwipeActionsConfiguration(actions: [deteleAct, topAct])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        }else{
            return nil
        }
    }
    //MARK: showAlert
    func showAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "您确认要删除吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [self]_ in
            print("delete")
            self.context.delete(self.bookArray[indexPath.row])
            self.bookArray.remove(at: indexPath.row)
            self.table.reloadData()
            self.saveBook()
           }))
        self.present(alert, animated: true, completion: nil)
       }
    //MARK: Book actions
    func addBook(name: String, money: Float, num: Int, img: Data) {
        let newBook = Book(context: self.context)
        newBook.bookName = name
        newBook.money = money
        newBook.studentNum = Int32(num)
        newBook.img = img
        newBook.top = false
        bookArray.append(newBook)
        print("add book success")
        self.saveBook()
        table.reloadData()
    }
    func saveBook() {
        do {
            try context.save()
        }catch{
            print("Save Book Failed:\(error)")
        }
        table.reloadData()
    }
    //MARK: load books
    func loadBooks() {
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        do {
            bookArray = try context.fetch(request)
        } catch {
            print("载入Book错误：\(error)")
        }
        let n = bookArray.count
        for i in 0..<n {
            if bookArray[i].top == true {
                let theBook: Book = self.bookArray[i]
                self.bookArray.remove(at: i)
                self.bookArray.insert(theBook, at: 0)
                break
            }
        }
        table.reloadData()
    }
    func reload() {
        loadBooks()
    }

}


 
