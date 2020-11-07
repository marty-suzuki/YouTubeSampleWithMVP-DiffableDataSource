//
//  LoadingViewCell.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/28.
//

import UIKit

final class LoadingViewCell: UITableViewCell {
    static let reuseIdentifier = String(describing: type(of: self))

    private let indicatorView:  UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .gray
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            indicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopAnimation()
    }

    func startAnimating() {
        indicatorView.startAnimating()
    }

    func stopAnimation() {
        indicatorView.stopAnimating()
    }
}
