//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Diliara Sadrieva on 11.12.2024.
//

import Foundation
import UIKit
final class ImagesListCell: UITableViewCell {
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    static let reuseIdentifier = "ImagesListCell"
    
}
