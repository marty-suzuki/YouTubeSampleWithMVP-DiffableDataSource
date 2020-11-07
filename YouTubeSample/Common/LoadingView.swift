//
//  LoadingViewCell.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/28.
//

import Reusable
import UIKit

final class LoadingView: UIView, ReusableView {

    private let indicatorView:  UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .gray
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func prepareForReuse() {
        stopAnimation()
    }

    func startAnimating() {
        indicatorView.startAnimating()
    }

    func stopAnimation() {
        indicatorView.stopAnimating()
    }
}
