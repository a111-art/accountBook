//
//  TextFieldCell.swift
//  AccountBook
//
//  Created by a111 on 2021/1/27.
//

import UIKit
import SnapKit

class TextFieldCell: UITableViewCell {
    var textField: UITextField!
    var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        label = UILabel.init()
        label.font = .systemFont(ofSize: 20)
        self.contentView.addSubview(label)
        
        textField = UITextField.init()
        textField = UITextField()
        textField.returnKeyType = .done
        textField.backgroundColor = .white
        textField.font = .systemFont(ofSize: 20)
        textField.clearButtonMode = .whileEditing
        self.accessoryView = textField
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        label.snp.makeConstraints{ (make) -> Void in
            make.centerY.height.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        textField.snp.makeConstraints{ (make) -> Void in
            make.centerY.height.equalToSuperview()
            make.left.equalToSuperview().offset(120)
            make.right.equalToSuperview().offset(-20)
        }
    }
    

}
