//
//  PickMonthController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/26.
//

import UIKit
// MARK: ChangeDate
protocol ChangeDate {
    func changeDate(date1: String, date2: String)
    func changeMonth(date: String)
}

class PickMonthController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var delegate: ChangeDate?
    
    //MARK: dateFormatter
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    let yearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter
    }()
    let monthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter
    }()
    
    let yearArr = ["2020年","2021年","2022年","2023年",]
    let monthArr = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月",]
    
    let navBar = UINavigationBar()
    let label = UILabel()                       //“按月选择”
    let button1 = UIButton()                //切换
    let button = UIButton()                  //取消
    let savebtn = UIButton()
    let dayPicker = UIDatePicker()
    let label2 = UILabel()                      //“至”
    let startDate = UIButton()
    let stopDate = UIButton()
    let monthPicker = UIPickerView()
    let monthBtn = UIButton()
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "选择时间"
        
        navBar.frame = CGRect(x: 0, y: 45, width: view.frame.size.width, height: 44)
        let navItem = UINavigationItem()
        navItem.title = "选择时间"
        navBar.pushItem(navItem, animated: true)
        self.view.addSubview(navBar)
        
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(ret), for: .touchUpInside)
        self.view.addSubview(button)
        button.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(40)
            make.top.equalToSuperview().offset(100)
        }
        
        savebtn.setTitle("完成", for: .normal)
        savebtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        savebtn.backgroundColor = .white
        savebtn.setTitleColor(.black, for: .normal)
        self.view.addSubview(savebtn)
        savebtn.addTarget(self, action: #selector(save_act), for: .touchUpInside)
        savebtn.snp.makeConstraints{ (make) -> Void in
            make.height.width.top.equalTo(button)
            make.right.equalToSuperview().offset(-10)
        }
        
        label.text = "按月选择"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        self.view.addSubview(label)
        label.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(button)
            make.height.equalTo(40)
            make.top.equalTo(button.snp.bottom).offset(40)
        }
        
        button1.setTitle("切换", for: .normal)
        button1.backgroundColor = .white
        button1.setTitleColor(.gray, for: .normal)
        button1.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        self.view.addSubview(button1)
        button1.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(40)
            make.left.equalTo(label.snp.right).offset(5)
            make.width.equalTo(40)
            make.top.equalTo(label)
        }
       //MARK: date buttton
        let dateNow = dateFormatter.string(from: Date())
        let yearNow = yearFormatter.string(from: Date())
        let monthNow = monthFormatter.string(from: Date())
        dayPicker.isHidden = true
        startDate.isHidden = true
        stopDate.isHidden = true
        label2.isHidden = true
        
        monthBtn.backgroundColor = .white
        monthBtn.setTitle("\(yearNow)-\(monthNow)", for: .normal)
        monthBtn.setTitleColor(.blue, for: .normal)
        monthBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(monthBtn)
        monthBtn.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.top.equalTo(button1.snp.bottom).offset(10)
        }
        
        startDate.backgroundColor = .white
        startDate.setTitle(dateNow, for: .normal)
        startDate.setTitleColor(.black, for: .normal)
        startDate.setTitleColor(.blue, for: .selected)
        startDate.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        startDate.isSelected = true
        startDate.tag = 1
        startDate.addTarget(self, action: #selector(pickDate), for: .touchUpInside)
        self.view.addSubview(startDate)
        startDate.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(150)
            make.top.equalTo(button1.snp.bottom).offset(10)
        }
        
        stopDate.backgroundColor = .white
        stopDate.setTitle(dateNow, for: .normal)
        stopDate.setTitleColor(.black, for: .normal)
        stopDate.setTitleColor(.blue, for: .selected)
        stopDate.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        stopDate.isSelected = false
        stopDate.tag = 2
        stopDate.addTarget(self, action: #selector(pickDate), for: .touchUpInside)
        self.view.addSubview(stopDate)
        stopDate.snp.makeConstraints{ (make) -> Void in
            make.right.equalToSuperview().offset(-20)
            make.width.top.height.equalTo(startDate)
        }
        
        label2.text = "至"
        label2.textColor = .black
        label2.font = .systemFont(ofSize: 18)
        label2.textAlignment = .center
        self.view.addSubview(label2)
        label2.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(startDate.snp.right)
            make.height.top.equalTo(startDate)
            make.right.equalTo(stopDate.snp.left)
        }
        //MARK: pickers set
        if #available(iOS 13.4, *) {
            dayPicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        dayPicker.datePickerMode = .date
        dayPicker.locale = NSLocale(localeIdentifier: "zh_CN") as Locale
        dayPicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        self.view.addSubview(dayPicker)
        dayPicker.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(150)
            make.left.right.equalToSuperview()
            make.top.equalTo(label2.snp.bottom).offset(10)
        }
        
        monthPicker.dataSource = self
        monthPicker.delegate = self
        monthPicker.backgroundColor = .white
        self.view.addSubview(monthPicker)
        monthPicker.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(monthBtn.snp.bottom).offset(20)
            make.height.equalTo(150)
            make.left.right.equalToSuperview()
        }
    }
    //MARK: actions
    @objc func refresh() {
        if label.text == "按月选择"{
            label.text = "按日选择"
            dayPicker.isHidden = false
            startDate.isHidden = false
            stopDate.isHidden = false
            label2.isHidden = false
            monthBtn.isHidden = true
            monthPicker.isHidden = true
        }else{
            label.text = "按月选择"
            dayPicker.isHidden = true
            startDate.isHidden = true
            stopDate.isHidden = true
            label2.isHidden = true
            monthBtn.isHidden = false
            monthPicker.isHidden = false
        }
    }
    @objc func ret() {
        dismiss(animated: false, completion: nil)
    }
    @objc func save_act() {
        if label.text == "按月选择"{
            delegate?.changeMonth(date: monthBtn.currentTitle!)
        }else{
            delegate?.changeDate(date1: startDate.currentTitle!, date2: stopDate.currentTitle!)
        }
        self.dismiss(animated: false, completion: nil)
    }
    //MARK: DatePicker actions
    @objc func pickDate(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            startDate.isSelected = true
            stopDate.isSelected = false
        case 2:
            startDate.isSelected = false
            stopDate.isSelected = true
        default:
            return
        }
    }
    @objc func dateChange(){
        let dateStr = dateFormatter.string(from:dayPicker.date)
        if startDate.isSelected {
            startDate.setTitle(dateStr, for: .selected)
            startDate.setTitle(dateStr, for: .normal)
        }
        if stopDate.isSelected {
            stopDate.setTitle(dateStr, for: .selected)
            stopDate.setTitle(dateStr, for: .normal)
        }
    }
    // MARK: MonthPicker Delegate
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150.0
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let yearRow = monthPicker.selectedRow(inComponent: 0)
        let year = yearArr[yearRow].dropLast()
        let monthRow = monthPicker.selectedRow(inComponent: 1)
        let month = monthArr[monthRow].dropLast()
        let dateStr: String
        if monthRow >= 9{
            dateStr = "\(year)-\(month)"
        }else{
            dateStr = "\(year)-0\(month)"
        }
        monthBtn.setTitle(dateStr, for: .normal)
       // monthBtn.setTitle(dateStr?, for: .selected)
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return (yearArr[row])
        }else{
            return (monthArr[row])
        }
    }
    // MARK: MonthPicker DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return yearArr.count
        } else {
            return monthArr.count
        }
    }
    

    
}
