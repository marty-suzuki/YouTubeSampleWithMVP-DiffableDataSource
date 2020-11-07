//
//  DetailChannelView.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/29.
//

import Nuke
import Reusable
import UIKit

final class DetailChannelView: UIView, ReusableView {

    private let thumbnailView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let height: CGFloat = 32
        imageView.layer.cornerRadius = height / 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: height),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
        return imageView
    }()

    private let channelTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkText
        label.numberOfLines = 2
        return label
    }()

    private var imageTask: ImageTask?

    override init(frame: CGRect) {
        super.init(frame: .zero)

        addSubview(thumbnailView)
        NSLayoutConstraint.activate([
            thumbnailView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            thumbnailView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            thumbnailView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        addSubview(channelTitleLabel)
        NSLayoutConstraint.activate([
            channelTitleLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 8),
            channelTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            channelTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func prepareForReuse() {
        imageTask?.cancel()
        imageTask = nil
    }

    func configure(_ data: Detail.ChannelViewData) {
        channelTitleLabel.text = data.title
        imageTask = Nuke.loadImage(with: data.thumbnail, into: thumbnailView)
    }
}
