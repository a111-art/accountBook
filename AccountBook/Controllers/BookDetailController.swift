//
//  BookDeatilController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/26.
//

import UIKit
import SnapKit
import CoreData
protocol reloadBook {
    func reloadBook(book: Bool)
}
class BookDetailController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    var book: Book?
    var costArr = [Cost]()
    var delegate: reloadBook?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let table = UITableView()
    let switchBtn = UISwitch()
    let deleteBtn = UIButton()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        //MARK: switchBtn
        if ((book?.top) != nil) {
            if book!.top {
                switchBtn.isOn = true
            } else {
                switchBtn.isOn = false
            }
        }
            
        switchBtn.addTarget(self, action: #selector(beTop), for: .valueChanged)
        
        deleteBtn.setTitle("删除并退出", for: .normal)
        deleteBtn.backgroundColor = .white
        deleteBtn.setTitleColor(.red, for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        deleteBtn.layer.borderColor = UIColor.gray.cgColor
        deleteBtn.layer.borderWidth = 1
        deleteBtn.addTarget(self, action: #selector(deleteBook), for: .touchUpInside)
        self.view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints{ (make) -> Void in
            make.centerX.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
            make.height.equalTo(50)
        }
        //MARK: table
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .white
        table.tableFooterView = UIView()
        table.register(TextFieldCell.self, forCellReuseIdentifier: "textFieldCell")
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(table)
        table.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(deleteBtn.snp.top)
        }
    }
    // MARK: - Table view
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView()
        return headView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 3
        default:
            return 0
        }
    }

    //MARK: cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell",for: indexPath) as! TextFieldCell
            cell.selectionStyle = .none
            cell.textField?.delegate = self
            cell.textField.text = book?.comment
            cell.textField.returnKeyType = .done
            cell.label?.text = "账本备注"
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.layer.borderColor = UIColor.black.cgColor
            cell?.layer.borderWidth = 0.5
            cell?.textLabel?.font = .systemFont(ofSize: 20)
            cell?.selectionStyle = .none
            cell?.textLabel?.text = "群聊置顶"
            cell?.accessoryView = switchBtn
            return cell!
        } else {
            let arr = ["查找流水记录", "数据可视化", "清空流水记录"]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.layer.borderColor = UIColor.black.cgColor
            cell?.layer.borderWidth = 0.5
            cell?.textLabel?.font = .systemFont(ofSize: 20)
            cell?.selectionStyle = .none
            cell?.textLabel?.text = arr[indexPath.row]
            cell?.accessoryType = .disclosureIndicator
            return cell!
        }
    }
    //MARK: didSelectRowAt indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if indexPath.row == 0{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1{
                let vc = PieChartController()
                vc.selectedBook = book
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                loadCosts()
                for i in 0..<costArr.count {
                    context.delete(costArr[i])
                }
                saveBook()
                let alertController = UIAlertController(title: "已清空流水", message: nil, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                delegate?.reloadBook(book: false)
            }
        }
    }
    //MARK: Textfield
       func textFieldDidChangeSelection(_ textField: UITextField) {
            changeComment(str: textField.text!)
       }
       func textFieldDidEndEditing(_ textField: UITextField) {
            changeComment(str: textField.text!)
       }
    //MARK: change book comment
    func changeComment(str: String){
        book?.setValue(str, forKey: "comment")
        saveBook()
        delegate?.reloadBook(book: true)
    }
    func saveBook() {
        do {
            try context.save()
        }catch{
            print("Save Book Failed:\(error)")
        }
    }
    //MARK: beTop act
    @objc func beTop() {
        if switchBtn.isOn {
            var topBook : Book?
            topBook = findBook()
            if topBook != nil {
                topBook?.setValue(false, forKey: "top")
            }
            book?.setValue(true, forKey: "top")
            saveBook()
        } else {
            book?.setValue(false, forKey: "top")
            saveBook()
        }
        delegate?.reloadBook(book: true)
    }
    //MARK: load costs
    func loadCosts(with request: NSFetchRequest<Cost> = Cost.fetchRequest(), predicate: NSPredicate? = nil) {
        let bookPredicate = NSPredicate(format: "parentBook.bookName MATCHES %@", book!.bookName! )
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [bookPredicate, addtionalPredicate])
        } else {
            request.predicate = bookPredicate
        }
        
        do {
            costArr = try context.fetch(request)
        } catch {
            print("从context获取数据错误：\(error)")
        }
    }
    //MARK: findBook act
    func findBook(with request: NSFetchRequest<Book> = Book.fetchRequest(), predicate: NSPredicate? = nil) -> Book? {
        var bookArray = [Book]()
        do {
            bookArray = try context.fetch(request)
        } catch {
            print("从context获取数据错误：\(error)")
        }
        let bookArr = bookArray.filter({ (book: Book) -> Bool in return
            book.top == true
        })
        if bookArr.count == 1 {
            return bookArr[0]
        } else {
            return nil
        }
    }
    //MARK: deleteBook
    @objc func deleteBook(){
        print("Delete Book")
        self.showAlert()
    }
    //MARK: showAlert
    func showAlert() {
        let alert = UIAlertController(title: nil, message: "您确认要删除吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [self]_ in
            print("delete")
            self.context.delete(self.book!)
            self.saveBook()
            self.navigationController?.popToRootViewController(animated: true)
           }))
        self.present(alert, animated: true, completion: nil)
       }
    
    //MARK: -textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
