//
//  AddBookController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/11.
//

import UIKit
import CoreData
import SnapKit
protocol AddBook {
    func addBook(name: String, money: Float, num: Int, img: Data)
}
class AddBookController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: AddBook?
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var imageView = UIImageView()
    
    let nameArr = ["账本名称", "班级人数", "添加图片", "班费数额"]
    var name: String = ""
    var num: String = ""
    var money: String = ""
    let table = UITableView()
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "新建账本"

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imageView.contentMode = .scaleAspectFit
        //view.addSubview(imageView)
        
        let btnSave = UIButton(frame: CGRect(x: view.frame.size.width/2-75, y: 350, width: 150, height: 40))
        btnSave.setTitle("完成创建", for: .normal)
        btnSave.backgroundColor = .white
        btnSave.setTitleColor(.black, for: .normal)
        //button.backgroundColor = .clear
        btnSave.layer.cornerRadius = 5
        btnSave.layer.borderWidth = 1
        btnSave.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(btnSave)
        btnSave.addTarget(self, action: #selector(saveBook), for: .touchUpInside)
        btnSave.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalToSuperview().offset(-200)
            make.width.equalTo(120)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .white
        table.tableFooterView = UIView()
        table.register(TextFieldCell.self, forCellReuseIdentifier: "textFieldCell")
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(table)
        table.snp.makeConstraints{ (make) -> Void in
            make.top.equalToSuperview().offset(100)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(btnSave.snp.top).offset(-10)
        }
                
    }
    //MARK: save act
    @objc func saveBook(_sender: UIButton) {
        if name != "" && num != "" && money != ""{
            if let imageData = imageView.image?.pngData(){
                delegate?.addBook(name: name, money: Float(money)!, num: Int(num)!, img: imageData)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
     
    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView()
        return headView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.layer.borderColor = UIColor.black.cgColor
            cell?.layer.borderWidth = 0.5
            cell?.textLabel?.font = .systemFont(ofSize: 20)
            cell?.selectionStyle = .none
            cell?.textLabel?.text = nameArr[indexPath.section]
            cell?.accessoryType = .disclosureIndicator
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell",for: indexPath) as! TextFieldCell
            cell.selectionStyle = .none
            cell.textField?.delegate = self
            cell.label?.text = nameArr[indexPath.section]
            cell.textField?.tag = indexPath.section
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            pickAnImage()
        } else {
            print(1)
        }
    }
    
    //MARK: image pick act
    func pickAnImage(){
        present(imagePicker, animated: true) {
            print("UIImagePickerController: presented")
        }
     }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("error: did not picked a photo")
         }
        picker.dismiss(animated: true) { [unowned self] in
            // add a image view on self.view
            self.imageView.image = selectedImage
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            print("UIImagePickerController: dismissed")
        }
    }
 //MARK: Textfield
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.tag == 0 {
            name = textField.text!
        } else if textField.tag == 1{
            num = textField.text!
        } else {
            money = textField.text!
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            name = textField.text!
        } else if textField.tag == 1{
            num = textField.text!
        } else {
            money = textField.text!
        }
    }
}
