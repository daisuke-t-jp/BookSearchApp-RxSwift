//
//  BookTableViewCell.swift
//  Sample
//
//  Created by Daisuke TONOSAKI on 2022/09/03.
//

import UIKit

import Nuke

class BookTableViewCell: UITableViewCell {
    // MARK: - Outlet
    @IBOutlet weak var imageViewArtwork: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelTrackName: UILabel!
    @IBOutlet weak var labelArtistName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    
    // MARK: - Constans
    static let height: CGFloat = 150
    
    
    func configure(item: BookModel) {
        labelTrackName.text = item.trackName
        labelArtistName.text = item.artistName
        labelDescription.text = item.description
        
        imageViewArtwork.image = R.image.defaultThumbnail()
        
        if let artworkUrl: URL = item.artworkUrl100 {
            activityIndicator.startAnimating()
            Nuke.loadImage(with: artworkUrl,
                           into: imageViewArtwork) { _ in
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
}
