//
//  HelpController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/24.
//

import UIKit

class HelpController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "小助手"
        
        let holder = UIView()
        holder.backgroundColor = .white
        holder.layer.borderWidth = 1
        holder.layer.borderColor = UIColor.black.cgColor
        holder.layer.cornerRadius = 15
        self.view.addSubview(holder)
        holder.snp.makeConstraints{ (make) -> Void in
            make.top.equalToSuperview().offset(110)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(200)
        }
        
        let label = UILabel()
        label.backgroundColor = UIColor.white
        label.text = "欢迎来到**记账，我是你的小助手，有什么问题都可以问我呀"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        let size = label.sizeThatFits(CGSize(width: self.view.frame.width, height: CGFloat(MAXFLOAT)))
        holder.addSubview(label)
        label.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(holder).offset(10)
            make.left.equalTo(holder).offset(10)
            make.right.equalTo(holder).offset(-10)
            make.height.equalTo(size.height)
        }
        
        let dateLabel = UILabel()
        dateLabel.backgroundColor = UIColor.white
        dateLabel.text = "2020-12-31"
        dateLabel.textColor = UIColor.black
        dateLabel.textAlignment = .right
        holder.addSubview(dateLabel)
        dateLabel.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(40)
            make.left.equalTo(holder).offset(10)
            make.right.equalTo(holder).offset(-10)
            make.bottom.equalTo(holder).offset(-10)
        }
        
        let askBtn = UIButton()
        askBtn.setTitle("问题反馈", for: .normal)
        askBtn.setTitleColor(.black, for: .normal)
        askBtn.layer.borderColor = UIColor.black.cgColor
        askBtn.layer.borderWidth = 1
        self.view.addSubview(askBtn)
        askBtn.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(60)
            make.left.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        let helpBtn = UIButton()
        helpBtn.setTitle("使用帮助", for: .normal)
        helpBtn.setTitleColor(.black, for: .normal)
        helpBtn.layer.borderColor = UIColor.black.cgColor
        helpBtn.layer.borderWidth = 1
        self.view.addSubview(helpBtn)
        helpBtn.snp.makeConstraints{ (make) -> Void in
            make.height.equalTo(askBtn)
            make.right.equalToSuperview()
            make.width.equalTo(askBtn)
            make.bottom.equalTo(askBtn)
        }
    }
    

}
