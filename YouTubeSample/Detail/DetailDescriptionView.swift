//
//  DetailDescriptionView.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/27.
//

import Reusable
import UIKit

final class DetailDescriptionView: UIView, ReusableView {
    static let reuseIdentifier = String(describing: type(of: self))

    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .darkText
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ description: String) {
        descriptionLabel.text = description
    }
}
