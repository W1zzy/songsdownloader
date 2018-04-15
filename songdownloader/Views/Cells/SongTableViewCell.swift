//
//  SongTableViewCell.swift
//  songdownloader
//
//  Created by Антон Братчик on 14.04.2018.
//  Copyright © 2018 Антон Братчик. All rights reserved.
//

import UIKit

protocol SongTableViewCellDelegate: class {
    func changeState(for cell: SongTableViewCell)
}

class SongTableViewCell: UITableViewCell {
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var changeStateImageView: UIImageView!
    @IBOutlet weak var progressView: ProgressView!
    
    weak var delegate: SongTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeStateTaped))
        changeStateImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configure(with song: Song, progress: Float) {
        progressView.progress = progress
        
        songNameLabel.text = song.name
        
        switch song.state {
        case .none:
            changeStateImageView.image = #imageLiteral(resourceName: "download_icon")
            changeStateImageView.isHidden = false
            progressView.isHidden = true
        case .downloading:
            changeStateImageView.isHidden = true
            progressView.isHidden = false
        case .pause:
            changeStateImageView.image = #imageLiteral(resourceName: "play")
            changeStateImageView.isHidden = false
            progressView.isHidden = true
        case .play:
            changeStateImageView.image = #imageLiteral(resourceName: "pause")
            changeStateImageView.isHidden = false
            progressView.isHidden = true
        }
    }
    
    func updateDisplay(progress: Float) {
        progressView.progress = progress
    }
    
    @objc func changeStateTaped() {
        delegate?.changeState(for: self)
    }
}
