//
//  VideoViewCell.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import Nuke
import UIKit

final class VideoViewCell: UITableViewCell {
    static let reuseIdentifier = String(describing: type(of: self))

    private let thumbnailView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()

    private let videoTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()

    private let channelTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textColor = .darkText
        return label
    }()

    private var imageTask: ImageTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(thumbnailView)
        NSLayoutConstraint.activate([
            thumbnailView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            thumbnailView.heightAnchor.constraint(equalToConstant: 72),
            thumbnailView.widthAnchor.constraint(equalTo: thumbnailView.heightAnchor, multiplier: 16 / 9)
        ])

        let stackView = UIStackView(arrangedSubviews: [
            videoTitleLabel,
            channelTitleLabel
        ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
    }

    func configure(_ data: VideoViewData) {
        videoTitleLabel.text = data.title
        channelTitleLabel.text = data.channelTitle
        imageTask = Nuke.loadImage(with: data.thumbnail, into: thumbnailView)
    }
}
