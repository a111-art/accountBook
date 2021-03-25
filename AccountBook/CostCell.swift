//
//  CostCell.swift
//  AccountBook
//
//  Created by a111 on 2021/1/13.
//

import UIKit

class CostCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var holder: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var showLabel: UILabel!

    @IBOutlet weak var img: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        holder.layer.borderColor = UIColor.gray.cgColor
        holder.layer.borderWidth = 1
        holder.layer.cornerRadius = 5
        dateLabel.snp.makeConstraints{ (make) -> Void in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(10)
            }
        holder.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
          }
        tagLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(holder).offset(15)
            make.right.equalTo(holder).offset(-15)
            make.top.equalTo(holder)
            make.height.equalTo(30)
        }
        moneyLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(holder).offset(15)
            make.right.equalTo(holder).offset(-15)
            make.top.equalTo(tagLabel.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        nameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(holder).offset(15)
            make.right.equalTo(holder).offset(-15)
            make.top.equalTo(moneyLabel.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        img.snp.makeConstraints{ (make) -> Void in
            make.right.equalTo(holder).offset(-15)
            make.width.equalTo(30)
            make.top.equalTo(nameLabel.snp.bottom)
            make.height.equalTo(30)
        }
        showLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(tagLabel)
            make.top.height.equalTo(img)
            make.right.equalTo(img.snp.left).offset(-20)
        }
        
    }
    
}
