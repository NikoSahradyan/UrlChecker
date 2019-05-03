//
//  URlCell.swift
//  StDevTask
//
//  Created by Developer on 03/05/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class URlCell: UITableViewCell {

    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stateView: UIImageView!
    var cellModel: URLCellModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupWithCellModel(cellModel: URLCellModel) {
        self.cellModel = cellModel
        self.urlLabel.text = cellModel.url.absoluteString
        self.setupForState(state: cellModel.state)
        self.cellModel?.updateCellWithStateClosure = { [weak self] state in
            self?.setupForState(state: state)
        }
    }
    
    func setupForState(state: URLCellModelState) {
        DispatchQueue.main.async {
            switch state {
            case .loading:
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                self.stateView.isHidden = true
            case .available(_):
                self.loadingIndicator.isHidden = true
                self.loadingIndicator.stopAnimating()
                self.stateView.isHidden = false
                self.stateView.image = UIImage(named: "greenCheckMark")
            case .unavailable:
                self.loadingIndicator.isHidden = true
                self.loadingIndicator.stopAnimating()
                self.stateView.isHidden = false
                self.stateView.image = UIImage(named: "redCheckMark")
            }
        }
    }
    
    override func prepareForReuse() {
        urlLabel.text = nil
        setupForState(state: .loading)
        cellModel?.updateCellWithStateClosure = nil
        cellModel = nil
    }
    
}
