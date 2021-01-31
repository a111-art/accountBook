//
//  PieChartController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/26.
//

import UIKit
import CoreData
import SnapKit
import Charts

class PieChartController: UIViewController, ChangeDate, UITableViewDelegate, UITableViewDataSource {

    var tagArr = [Tag]()
    var costArr = [Cost]()
    var tagNameArr = [String]()
    var tagMoneyArr = [Float]()
    var colors = [UIColor]()
    var inSum: Float = 0
    var outSum: Float = 0
    var inArr = [Cost]()
    var outArr = [Cost]()
    var startDate: Date?
    var stopDate: Date?
    var selectedBook: Book? {
        didSet {
            findCost(date1: nil, date2: nil, monthD: monthFormatter.string(from: Date()))
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: dateFormatter
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    let monthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter
    }()
    //MARK: UI
    let pie = PieChartView()
    let table = UITableView()
    let outBtn = UIButton()
    let inBtn = UIButton()
    let dateButton = UIButton()
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        //MARK: btn
        dateButton.setTitle(monthFormatter.string(from: Date()), for: .normal)
        dateButton.setTitleColor(.blue, for: .normal)
        dateButton.addTarget(self, action: #selector(pickDate), for: .touchUpInside)
        self.view.addSubview(dateButton)
        dateButton.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(100)
        }
        
        outBtn.setTitle("支出\n¥\(abs(outSum))", for: .normal)
        outBtn.backgroundColor = .white
        outBtn.setTitleColor(.gray, for: .normal)
        outBtn.setTitleColor(.black, for: .selected)
        outBtn.isSelected = true
        outBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        outBtn.titleLabel?.lineBreakMode = .byWordWrapping
        outBtn.titleLabel?.textAlignment = .center
        outBtn.titleLabel?.numberOfLines = 2
        self.view.addSubview(outBtn)
        outBtn.addTarget(self, action: #selector(outBtn_act), for: .touchUpInside)
        outBtn.snp.makeConstraints{ (make) -> Void in
            make.width.equalToSuperview().dividedBy(2)
            make.left.equalToSuperview()
            make.height.equalTo(60)
            make.top.equalTo(dateButton.snp.bottom).offset(10)
        }
        
        inBtn.setTitle("收入\n¥\(abs(inSum))", for: .normal)
        inBtn.backgroundColor = .white
        inBtn.setTitleColor(.gray, for: .normal)
        inBtn.setTitleColor(.black, for: .selected)
        inBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        inBtn.titleLabel?.lineBreakMode = .byWordWrapping
        inBtn.titleLabel?.textAlignment = .center
        inBtn.titleLabel?.numberOfLines = 2
        self.view.addSubview(inBtn)
        inBtn.addTarget(self, action: #selector(inBtn_act), for: .touchUpInside)
        inBtn.snp.makeConstraints{ (make) -> Void in
            make.centerY.height.width.equalTo(outBtn)
            make.right.equalToSuperview()
        }
        //MARK: pie
        // 不显示文字
         pie.drawEntryLabelsEnabled = false
         //不转动
         pie.rotationEnabled = false
         pie.legend.enabled = false
         self.view.addSubview(pie)
        customizeChart(dataPoints: tagNameArr, values: tagMoneyArr.map{ Float(Float($0)) })
         pie.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(inBtn.snp.bottom).offset(10)
             make.width.height.equalTo(250)
             make.centerX.equalToSuperview()
         }
        //MARK: table
         table.delegate = self
         table.dataSource = self
        table.tableFooterView = UIView()
         self.view.addSubview(table)
        table.register(UINib.init(nibName: "pieCell", bundle: nil), forCellReuseIdentifier: "pieCell")
         table.snp.makeConstraints{ (make) -> Void in
             make.top.equalTo(pie.snp.bottom).offset(10)
             make.width.equalToSuperview()
             make.centerX.equalToSuperview()
             make.bottom.equalToSuperview()
         }
        
    }
    //MARK: changeDate
    func changeDate(date1: String, date2: String){
        dateButton.setTitle("\(date1)至\(date2)", for: .normal)
        startDate = dateFormatter.date(from: date1)
        stopDate = dateFormatter.date(from: date2)?.addingTimeInterval(60*60*24)
        findCost(date1: startDate, date2: stopDate, monthD: nil)
    }
    func changeMonth(date: String) {
        dateButton.setTitle(date, for: .normal)
        findCost(date1: nil, date2: nil, monthD: date)
    }
    @ objc func pickDate(_ sender: Any) {
       let vc = PickMonthController()
        vc.modalPresentationStyle = .fullScreen
        vc.delegate=self
        self.present(vc, animated: false, completion: nil)
    }
    //MARK: find costs
    func findCost(date1: Date?, date2: Date?, monthD: String?){
        let request: NSFetchRequest<Cost> = Cost.fetchRequest()
        do {
            costArr = try context.fetch(request)
        } catch {
            print("从context获取数据错误：\(error)")
        }
        
        if (date1 != nil && date2 != nil){
            let range = date1!...date2!
            costArr = costArr.filter({ (cost: Cost) -> Bool in return
                range.contains(cost.date!)
            })
        }
        
        if monthD != nil{
            costArr = costArr.filter({ (cost: Cost) -> Bool in return monthFormatter.string(from: cost.date!) == monthD
            })
        }
        
        costArr = costArr.filter({ (cost: Cost) -> Bool in return cost.parentBook?.bookName == selectedBook?.bookName
        })
        //loadMoney
        inArr = costArr.filter({ (cost: Cost) -> Bool in return cost.money > 0
        })
        outArr = costArr.filter({ (cost: Cost) -> Bool in return cost.money < 0
        })
        inSum = inArr.reduce(0) { $0 + $1.money }
        inBtn.setTitle("收入\n¥\(abs(inSum))", for: .selected)
        inBtn.setTitle("收入\n¥\(abs(inSum))", for: .normal)
        
        outSum = outArr.reduce(0) { $0 + $1.money }
        outBtn.setTitle("支出\n¥\(abs(outSum))", for: .selected)
        outBtn.setTitle("支出\n¥\(abs(outSum))", for: .normal)
        
        findTag(costs: outArr)

    }
    
    //MARK: find tags
    func findTag(costs: [Cost]){
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        do {
            tagArr = try context.fetch(request)
        } catch {
            print("载入Tag错误：\(error)")
        }
        
        let tagN = tagArr.count
        tagMoneyArr = [Float](repeating: 0, count: tagN)
        tagNameArr = [String](repeating: "", count: tagN)
        let costN = costs.count
        for i in 0..<tagN {
            tagNameArr[i] = tagArr[i].name!
            for j in 0..<costN {
                if costs[j].tag?.name == tagArr[i].name {
                    tagMoneyArr[i] += abs(costs[j].money) }
            }
        }
        
        var i = 0
        while i < tagNameArr.count {
            if tagMoneyArr[i] == 0{
                tagMoneyArr.remove(at: i)
                tagNameArr.remove(at: i)
            } else {
                i += 1
            }
        }
        customizeChart(dataPoints: tagNameArr, values: tagMoneyArr.map{ Float($0) })
        table.reloadData()
    }
    //MARK: in out btn
    @objc func outBtn_act(){
        outBtn.isSelected = true
        inBtn.isSelected = false
        findTag(costs: outArr)
    }
    @objc func inBtn_act() {
        outBtn.isSelected = false
        inBtn.isSelected = true
        findTag(costs: inArr)
    }
    //MARK: pie
    func customizeChart(dataPoints: [String], values: [Float]) {
        // 1. Set ChartDataEntry
          var dataEntries: [ChartDataEntry] = []
          for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
          }
          // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
          pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        colors = pieChartDataSet.colors
        pieChartDataSet.selectionShift = 0
        pieChartDataSet.drawValuesEnabled = false
          // 3. Set ChartData
          let pieChartData = PieChartData(dataSet: pieChartDataSet)
          let format = NumberFormatter()
          format.numberStyle = .none
          let formatter = DefaultValueFormatter(formatter: format)
          pieChartData.setValueFormatter(formatter)
          // 4. Assign it to the chart’s data
          pie.data = pieChartData

    }
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
      var colors: [UIColor] = []
      for _ in 0..<numbersOfColor {
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))
        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        colors.append(color)
      }
      return colors
    }
    
    //MARK: table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "账单详情"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tagNameArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pieCell", for: indexPath) as! pieCell
        cell.img.backgroundColor = colors[indexPath.row]
        cell.nameL.text = tagNameArr[indexPath.row]
        cell.moneyL.text = String(tagMoneyArr[indexPath.row])
        return cell
    }
    
    
}
