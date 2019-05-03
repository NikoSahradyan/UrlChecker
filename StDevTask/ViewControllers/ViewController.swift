//
//  ViewController.swift
//  StDevTask
//
//  Created by Developer on 01/05/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var viewModel: MainViewModel = {
        let viewModel = MainViewModel()
        viewModel.alertPresentingClosure = { [weak self] title in
            self?.presentAlertWithTitile(title: title)
        }
        return viewModel
    } ()

    @IBOutlet weak var sortTableView: UITableView!
    //AddView UI fragments
    @IBOutlet weak var addBackgroundView: UIView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addUrlTextField: UITextField!
    @IBAction func addDone() {
        guard let currentUrl = addUrlTextField.text,
            currentUrl.count > 0 else {
                self.presentAlertWithTitile(title:  "To add Url You need to enter URL)))")
                return 
        }
        viewModel.insertNewUrl(url: URL(string: currentUrl))
        self.hideAddView()
        
    }

    @IBAction func addCancel() {
        self.hideAddView()
    }
    
    @objc func hideAddView() {
        self.addBackgroundView.isHidden = true
        addUrlTextField.text = nil
    }
    
    //Main Fragments
    @IBOutlet weak var urlTableView: UITableView!
    
    
    @IBAction func Add() {
        self.addBackgroundView.isHidden = false
    }
    
    @IBAction func Refresh() {
        self.viewModel.refresh()
    }
    
    @IBAction func Sort() {
        self.sortTableView.isHidden = false
    }
    
    func presentAlertWithTitile(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hideAddTap = UITapGestureRecognizer(target: self, action: #selector(hideAddView))
        hideAddTap.delegate = self
        self.addBackgroundView.addGestureRecognizer(hideAddTap)
        
        self.viewModel.setupTableView(tableView: self.urlTableView)
        self.viewModel.setupSortTableView(tableView: self.sortTableView)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view === gestureRecognizer.view {
            return true
        }
        return false
    }
}

