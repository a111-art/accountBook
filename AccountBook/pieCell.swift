//
//  pieCell.swift
//  AccountBook
//
//  Created by a111 on 2021/1/29.
//

import UIKit
import SnapKit
class pieCell: UITableViewCell {

    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var moneyL: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img.layer.cornerRadius = 5
        
        img.snp.makeConstraints{ (make) -> Void in
            make.left.equalToSuperview().offset(20)
            make.height.width.equalTo(40)
            make.centerY.equalToSuperview()
            }
        moneyL.snp.makeConstraints{ (make) -> Void in
            make.right.equalToSuperview().offset(-20)
            make.height.centerY.equalTo(img)
            }
        nameL.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(img.snp.right).offset(20)
            make.height.centerY.equalTo(img)
            make.right.equalTo(moneyL.snp.left).offset(10)
            }
    }
    
}
