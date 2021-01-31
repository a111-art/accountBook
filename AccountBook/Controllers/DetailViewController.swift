//
//  DetailViewController.swift
//  AccountBook
//
//  Created by a111 on 2021/1/18.
//

import UIKit

class DetailViewController: UIViewController {
    var cost: Cost? {
        didSet {
            configureView()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    func configureView() {
    }


}
