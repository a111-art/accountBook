//
//  CostDetailController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/29.
//

import UIKit
protocol ChangeCost{
    func changeCost(CostOnly: Bool)
}
class CostDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var str = ["","",""]
    var money : Double?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: ChangeCost?


    var selectedCost: Cost? {
        didSet {
            if selectedCost?.image != nil {
                img.image = UIImage(data: selectedCost!.image!)
            }
        }
    }
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    let table = UITableView()
    let moneyL = UILabel()
    var img = UIImageView()
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "账单详情"
        
        let delBtn = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(deleteCost))
        self.navigationItem.rightBarButtonItem = delBtn
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        moneyL.font = .boldSystemFont(ofSize: 20)
        moneyL.textAlignment = .right
        
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .white
        table.tableFooterView = UIView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(table)
        table.snp.makeConstraints{ (make) -> Void in
            make.top.equalToSuperview().offset(100)
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        let btnPick = UIButton()
        btnPick.setTitle("添加图片", for: .normal)
        btnPick.backgroundColor = .white
        btnPick.setTitleColor(.blue, for: .normal)
        btnPick.contentHorizontalAlignment = .right
        btnPick.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(btnPick)
        btnPick.addTarget(self, action: #selector(pickAnImage), for: .touchUpInside)
        btnPick.snp.makeConstraints{ (make) -> Void in
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(table.snp.bottom)
            make.height.equalTo(40)
        }
        
        self.view.addSubview(img)
        img.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(btnPick.snp.bottom)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(btnPick.snp.left)
            make.height.equalTo(200)
        }
    }
    //MARK: tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    //MARK: cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        str[0] = (selectedCost?.tag?.name) ?? ""
        str[1] = ("时间：\(dateFormatter.string(from: (selectedCost?.date) ?? Date() ))")
        str[2] = ("备注信息："+(selectedCost?.name ?? ""))
        money = selectedCost!.money
        cell?.layer.borderColor = UIColor.black.cgColor
        cell?.layer.borderWidth = 0.5
        cell?.textLabel?.font = .systemFont(ofSize: 18)
        cell?.selectionStyle = .none
        cell?.textLabel?.text = str[indexPath.row]
        if indexPath.row == 0{
            cell?.accessoryView = moneyL
            moneyL.frame = CGRect(x: 150, y: 5, width: 120, height: 30)
            moneyL.text = "¥\(String(money!))"
        } else {
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(index: indexPath.row)
    }
    //MARK: AlertController
    func showAlert(index: Int) {
        let str = ["修改费用", "修改时间", "修改备注"]
        let alert = UIAlertController(title: nil, message: str[index], preferredStyle: .alert)
        alert.addTextField {
            (textField: UITextField!) -> Void in
          }
        let textfield = alert.textFields!.first!
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "好的", style: .default, handler: { [self]
            action in
            print("标签: \(String(describing: textfield.text))")
            if index == 0{
                self.moneyL.text = textfield.text
                self.selectedCost?.setValue(Double(textfield.text!), forKey: "money")
                delegate?.changeCost(CostOnly: false)
            } else if index == 1{
                self.selectedCost?.setValue(dateFormatter.date(from: (textfield.text!)), forKey: "date")
                delegate?.changeCost(CostOnly: true)
            } else {
                self.selectedCost?.setValue( (textfield.text!), forKey: "name")
                delegate?.changeCost(CostOnly: false)
            }
            saveCost()
            table.reloadData()
        })
        okAction.isEnabled = (textfield.text != nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
       }
    //MARK: - imagePicker
    @objc func pickAnImage(){
        present(imagePicker, animated: true) {
            print("UIImagePickerController: presented")
        }
     }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("error: did not picked a photo")
         }
        selectedCost?.setValue(selectedImage.pngData(), forKey: "image")
        saveCost()
        picker.dismiss(animated: true) { [unowned self] in
            // add a image view on self.view
            self.img.image = selectedImage
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            print("UIImagePickerController: dismissed")
        }
    }
    //MARK: save costs
    func saveCost() {
        do {
            try context.save()
        }catch{
            print("Save Cost Failed:\(error)")
        }
        table.reloadData()
    }
    
    // MARK: - delete act
    @objc func deleteCost(){
        context.delete(selectedCost!)
        saveCost()
        delegate?.changeCost(CostOnly: false)
        self.navigationController?.popViewController(animated: true)
    }

    

}
