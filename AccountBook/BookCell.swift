//
//  BookCell.swift
//  AccountBook
//
//  Created by a111 on 2021/1/23.
//

import UIKit

class BookCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
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
        picture.layer.cornerRadius = 5
        dateLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(nameLabel.snp_rightMargin)
            make.right.equalToSuperview().offset(-10)
            make.height.top.equalTo(nameLabel)
        }
    }
    
}
