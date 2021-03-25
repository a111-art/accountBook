//
//  AddCostController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/13.
//

import UIKit
import CoreData
import SnapKit

protocol AddCost {
    func addCost(name: String, date :Date, money: Float, img: Data?, tagName: String)
}

class AddCostController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    var delegate: AddCost?
    
    let datePicker = UIDatePicker()
    let nameTextField = UITextField()
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    lazy var imageView = UIImageView(frame: CGRect(x: 10, y: 160, width: view.frame.size.width/3, height: view.frame.size.width/4))
    
    var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "¥"
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    let historyLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    var calculateResult: CalculateResult!
    var inputType = -1
    var num = 0
    var resultNum = 0
    var theOperation: Operations?
    var history: String = ""
    enum Operations {
        case add, subtract, multiply, divide
    }
    let inBtn = UIButton()
    let outBtn = UIButton()
    let tagNameLabel = UILabel()
    
    //load tags
    var tagArr = [Tag]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        loadTags()
        calculateResult = CalculateResult()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        //imageView.contentMode = .scaleAspectFit
        //view.addSubview(imageView)
        
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(ret), for: .touchUpInside)
        self.view.addSubview(button)
        button.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(40)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        let savebtn = UIButton()
        savebtn.setTitle("完成", for: .normal)
        savebtn.backgroundColor = .white
        savebtn.setTitleColor(.black, for: .normal)
        self.view.addSubview(savebtn)
        savebtn.addTarget(self, action: #selector(save_act), for: .touchUpInside)
        savebtn.snp.makeConstraints{ (make) -> Void in
            make.height.width.top.equalTo(button)
            make.right.equalToSuperview().offset(-10)
        }
        
        outBtn.setTitle("支出", for: .normal)
        outBtn.backgroundColor = .white
        outBtn.setTitleColor(.gray, for: .normal)
        outBtn.setTitleColor(.blue, for: .selected)
        outBtn.isSelected = true
        outBtn.contentHorizontalAlignment = .right
        outBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(outBtn)
        outBtn.addTarget(self, action: #selector(outBtn_act), for: .touchUpInside)
        outBtn.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(button)
            make.right.equalToSuperview().offset(-view.frame.size.width/2-5)
            make.height.equalTo(50)
            make.width.equalTo(80)
        }
        
        inBtn.setTitle("收入", for: .normal)
        inBtn.backgroundColor = .white
        inBtn.setTitleColor(.gray, for: .normal)
        inBtn.setTitleColor(.blue, for: .selected)
        inBtn.contentHorizontalAlignment = .left
        inBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(inBtn)
        inBtn.addTarget(self, action: #selector(inBtn_act), for: .touchUpInside)
        inBtn.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(outBtn)
            make.left.equalToSuperview().offset(view.frame.size.width/2+5)
            make.height.width.equalTo(outBtn)
        }
        //MARK: textField
        nameTextField.delegate = self
        nameTextField.placeholder = "请在此输入备注信息"
        nameTextField.layer.borderColor = UIColor.gray.cgColor
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 10
        nameTextField.returnKeyType = .done
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints{ (make) -> Void in
            make.right.equalTo(savebtn)
            make.left.equalTo(button)
            make.height.equalTo(50)
            make.top.equalTo(inBtn).offset(50)
        }
        
        resultLabel.font = .systemFont(ofSize: 40)
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints{ (make) -> Void in
            make.right.left.equalTo(nameTextField)
            make.height.equalTo(80)
            make.top.equalTo(nameTextField.snp.bottom)
        }
        
        historyLabel.font = .systemFont(ofSize: 20)
        view.addSubview(historyLabel)
        historyLabel.snp.makeConstraints{ (make) -> Void in
            make.right.left.equalTo(nameTextField)
            make.height.equalTo(40)
            make.top.equalTo(resultLabel.snp.bottom)
        }
        
        //MARK: tag UI
        let tagLabel = UILabel()
        tagLabel.text = "选择标签"
        tagLabel.textColor = .black
        tagLabel.font = .boldSystemFont(ofSize: 20)
        tagLabel.textAlignment = .left
        self.view.addSubview(tagLabel)
        tagLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(nameTextField)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.top.equalTo(historyLabel.snp.bottom)
        }
        
        //default tag or choosed tag
        tagNameLabel.text = tagArr[0].name
        tagNameLabel.textColor = .blue
        tagNameLabel.layer.borderWidth = 1
        tagNameLabel.textAlignment = .left
        tagNameLabel.layer.borderColor = UIColor.gray.cgColor
        tagNameLabel.layer.cornerRadius = 5
        self.view.addSubview(tagNameLabel)
        tagNameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(tagLabel.snp.right).offset(10)
            make.height.equalTo(30)
            make.top.equalTo(tagLabel).offset(5)
        }
        
        //MARK: - Calculator UI
        let buttonWidth = view.frame.size.width/4
        
        let zeroButton = UIButton()
        zeroButton.setTitleColor(.black, for: .normal)
        zeroButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        zeroButton.backgroundColor = .white
        zeroButton.setTitle("0", for: .normal)
        zeroButton.tag = 1
        self.view.addSubview(zeroButton)
        zeroButton.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
        zeroButton.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview().offset(buttonWidth)
            make.width.equalTo(buttonWidth)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(50)
        }
        // "."
        let pointButton = UIButton()
        pointButton.setTitleColor(.black, for: .normal)
        pointButton.backgroundColor = .white
        pointButton.setTitle(".", for: .normal)
        pointButton.tag = 11
        pointButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        self.view.addSubview(pointButton)
        pointButton.addTarget(self, action: #selector(pointPressed(_:)), for: .touchUpInside)
        pointButton.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview().offset(buttonWidth*2)
            make.height.width.bottom.equalTo(zeroButton)
        }
        //clearButton
        let clearButton = UIButton()
        clearButton.setTitleColor(.black, for: .normal)
        clearButton.backgroundColor = .white
        clearButton.setTitle("AC", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        self.view.addSubview(clearButton)
        clearButton.addTarget(self, action: #selector(clearAll), for: .touchUpInside)
        clearButton.snp.makeConstraints{ (make) -> Void in
                make.left.equalToSuperview()
                make.height.width.bottom.equalTo(zeroButton)
            }
        //operationButton
        let operation = ["*", "-", "+"]
        for x in 0...2 {
            let button4 = UIButton()
            button4.setTitleColor(.black, for: .normal)
            button4.backgroundColor = .white
            button4.setTitle(operation[x], for: .normal)
            button4.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            self.view.addSubview(button4)
            button4.tag = x+1
            button4.addTarget(self, action: #selector(operationPressed(_:)), for: .touchUpInside)
            button4.snp.makeConstraints{ (make) -> Void in
                make.right.equalToSuperview()
                make.bottom.equalTo(zeroButton).offset(-(50*x))
                make.height.width.equalTo(zeroButton)
            }
        }
        
        let delBtn = UIButton()
        delBtn.setTitleColor(.black, for: .normal)
        delBtn.backgroundColor = .white
        delBtn.setTitle("删除", for: .normal)
        delBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(delBtn)
        delBtn.addTarget(self, action: #selector(delete_act), for: .touchUpInside)
        delBtn.snp.makeConstraints{ (make) -> Void in
            make.right.equalToSuperview()
            make.height.width.equalTo(zeroButton)
            make.bottom.equalTo(zeroButton).offset(-150)
        }
        //7-9
            for x in 0...2 {
                let button3 = UIButton()
                button3.setTitleColor(.black, for: .normal)
                button3.backgroundColor = .white
                button3.setTitle("\(x+7)", for: .normal)
                button3.titleLabel?.font = UIFont.systemFont(ofSize: 25)
                self.view.addSubview(button3)
                button3.tag = x+8
                button3.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
                button3.snp.makeConstraints{ (make) -> Void in
                    make.left.equalToSuperview().offset(buttonWidth * CGFloat(x))
                    make.bottom.equalTo(zeroButton).offset(-50)
                    make.height.width.equalTo(zeroButton)
                }
            }
        //4-6
            for x in 0...2 {
                let button2 = UIButton()
                button2.setTitleColor(.black, for: .normal)
                button2.backgroundColor = .white
                button2.setTitle("\(x+4)", for: .normal)
                button2.titleLabel?.font = UIFont.systemFont(ofSize: 25)
                self.view.addSubview(button2)
                button2.tag = x+5
                button2.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
                button2.snp.makeConstraints{ (make) -> Void in
                    make.left.equalToSuperview().offset(buttonWidth * CGFloat(x))
                    make.bottom.equalTo(zeroButton).offset(-100)
                    make.height.width.equalTo(zeroButton)
                }
            }
        //1-3
        for x in 0...2 {
            let button1 = UIButton()
            button1.setTitleColor(.black, for: .normal)
            button1.backgroundColor = .white
            button1.setTitle("\(x+1)", for: .normal)
            button1.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            self.view.addSubview(button1)
            button1.tag = x+2
            button1.addTarget(self, action: #selector(numberPressed(_:)), for: .touchUpInside)
            button1.snp.makeConstraints{ (make) -> Void in
                make.left.equalToSuperview().offset(buttonWidth * CGFloat(x))
                make.bottom.equalTo(zeroButton).offset(-150)
                make.height.width.equalTo(zeroButton)
            }
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
            make.right.equalTo(nameTextField)
            make.width.equalTo(120)
            make.bottom.equalTo(delBtn.snp.top)
            make.height.equalTo(40)
        }
        
        datePicker.datePickerMode = .date
        datePicker.locale = NSLocale(localeIdentifier: "zh_CN") as Locale
        //datePicker.preferredDatePickerStyle = .wheels
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(nameTextField)
            make.width.equalTo(150)
            make.height.top.equalTo(btnPick)
        }
        
        let createTagBtn = UIButton()
        createTagBtn.setTitle("+自定义", for: .normal)
        createTagBtn.backgroundColor = .white
        createTagBtn.setTitleColor(.gray, for: .normal)
        createTagBtn.layer.borderWidth = 1
        createTagBtn.layer.borderColor = UIColor.gray.cgColor
        createTagBtn.layer.cornerRadius = 5
        createTagBtn.tag = 1
        self.view.addSubview(createTagBtn)
        createTagBtn.addTarget(self, action: #selector(tagBtn_act), for: .touchUpInside)
        createTagBtn.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(nameTextField)
            make.width.equalTo(80)
            make.bottom.equalTo(datePicker.snp.top)
            make.height.equalTo(30)
        }
        
        //MARK: -scrollView show tags
        //show tag btns
        let tagView = UIScrollView()
        tagView.backgroundColor = .white
        tagView.delegate = self
        tagView.bounces = true
        tagView.alwaysBounceVertical = true
        //set btn
        let btnHeight = CGFloat(30)
        let rowHeight = CGFloat(35)
        var index = 0
        var x : CGFloat = 0
        var y : CGFloat = 0
        
        for i in 0..<tagArr.count {
            let btnSize = tagArr[i].name!.getLabWidth(font: .systemFont(ofSize: 22), height: btnHeight)
            if x + btnSize.width > UIScreen.main.bounds.size.width {
                index += 1
                x = CGFloat(0)
                y += rowHeight
            }
            let rect = CGRect(x: x, y: y, width: btnSize.width, height: btnHeight)
            x += btnSize.width + CGFloat(10)
            
            let btn = UIButton()
            btn.frame = rect
            btn.setTitle(tagArr[i].name, for: .normal)
            btn.backgroundColor = .white
            btn.setTitleColor(.gray, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 18)
            /*btn.contentHorizontalAlignment = .left
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)*/
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.gray.cgColor
            btn.layer.cornerRadius = 5
            btn.tag = 10+i
            btn.addTarget(self, action: #selector(tagBtn_act), for: .touchUpInside)
            tagView.addSubview(btn)
        }
        view.addSubview(tagView)
        tagView.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(tagLabel.snp.bottom).offset(10)
            make.bottom.equalTo(createTagBtn.snp.top)
        }
        
    }
    //MARK: actions
    @objc func outBtn_act() {
        inputType = -1
        print(inputType)
        outBtn.isSelected = true
        inBtn.isSelected = false
    }
    @objc func inBtn_act() {
        inputType = 1
        print(inputType)
        outBtn.isSelected = false
        inBtn.isSelected = true
    }
    @objc func tagBtn_act(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            print("自定义标签")
            self.showAlert()
        default:
            tagNameLabel.text = sender.title(for: .normal)
        }
    }
    //MARK: AlertController
    func showAlert() {
        let alert = UIAlertController(title: nil, message: "编辑自定义标签", preferredStyle: .alert)
        alert.addTextField {
            (textField: UITextField!) -> Void in
          }
        let textfield = alert.textFields!.first!
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "好的", style: .default, handler: {
            action in
            //也可以用下标的形式获取textField let login = alertController.textFields![0]
            print("标签: \(String(describing: textfield.text))")
            self.tagNameLabel.text = textfield.text
        })
        okAction.isEnabled = (textfield.text != nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
       }
    
    //MARK: Cancel  Save  act
    @objc func ret() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func save_act () {
        var theMoney = resultLabel.text!.dropFirst()
        if Float(theMoney)==nil {
            theMoney = "0"
        }
        if let imageData = imageView.image?.pngData(){
            delegate?.addCost(name: nameTextField.text!, date: datePicker.date, money: (Float(theMoney)! * Float(inputType)), img: imageData, tagName: tagNameLabel.text!)
            self.dismiss(animated: true, completion: nil)
        } else {
            delegate?.addCost(name: nameTextField.text!, date: datePicker.date, money: (Float(theMoney)! * Float(inputType)), img: nil, tagName: tagNameLabel.text!)
            self.dismiss(animated: true, completion: nil)
        }
        
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
    //MARK: - Calculator  actions
    @objc func delete_act() {
        historyLabel.text?.removeLast()
        let numArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."]
        if historyLabel.text != "" {
            var str = historyLabel.text
            let lastStr = String(str![(str?.index(before: str!.endIndex))!])
            if !(numArray.contains(lastStr)) {
                str?.removeLast()
            }
            history = str! + "="
            var result: String
            result = (calculateResult.calculateWithString(s: history))
            resultLabel.text = "¥"
            resultLabel.text!.append(result)
        }
    }
    @objc func numberPressed(_ sender: UIButton) {
        let tag = sender.tag - 1
        if historyLabel.text != "0"{
            historyLabel.text!.append("\(tag)")
        } else {
            historyLabel.text = "\(tag)"
        }
        history = historyLabel.text! + "="
        var result: String = ""
        result = (calculateResult.calculateWithString(s: history))
        resultLabel.text = "¥"
        resultLabel.text!.append(result)
    }
    @objc func operationPressed(_ sender: UIButton) {
        let tag = sender.tag
        if let text = resultLabel.text, let value = Int(text), num == 0 {
            num = value
            resultLabel.text = "0"
        }
        if tag == 3 {
            historyLabel.text!.append("+")
        }
        else if tag == 2 {
            historyLabel.text!.append("-")
        }
        else if tag == 1 {
            historyLabel.text!.append("*")
        }
    }
    @objc func clearAll() {
        resultLabel.text = "0"
        historyLabel.text = "0"
    }
    @ objc func pointPressed(_ sender: UIButton){
        historyLabel.text!.append(".")
    }
    //MARK: - load tags
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func loadTags() {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        do {
            tagArr = try context.fetch(request)
        } catch {
            print("载入tags错误：\(error)")
        }
        let defaultTags = ["聚餐","团费","班级活动","书籍资料"]
        if tagArr.count == 0 {
            for i in 0..<defaultTags.count {
                let newTag = Tag(context: self.context)
                newTag.name = defaultTags[i]
                do {
                    try context.save()
                }catch{
                    print("load default tags Failed:\(error)")
                }
            }
            loadTags()
        }
        
    }
    //MARK: -textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
//MARK: - extension String
extension String {
    /// 通过string动态获取其对应的size
    /// - font: 字体大小
    func getLabWidth(font:UIFont,height:CGFloat) -> CGSize {
        let size = CGSize(width: 900, height: height)
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let strSize = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context:nil).size
        return strSize
    }
}


