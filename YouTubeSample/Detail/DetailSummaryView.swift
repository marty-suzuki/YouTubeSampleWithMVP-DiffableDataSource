//
//  DetailSummaryView.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import Reusable
import UIKit

final class DetailSummaryView: UIView, ReusableView {

    private let videoTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 1
        label.textColor = .darkGray
        return label
    }()

    private let arrowLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        label.numberOfLines = 1
        label.textColor = .darkGray
        label.textAlignment = .right
        label.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let vStackView = UIStackView(arrangedSubviews: [
            videoTitleLabel,
            dateLabel
        ])
        vStackView.axis = .vertical
        vStackView.spacing = 4
        vStackView.translatesAutoresizingMaskIntoConstraints = false

        let hStackView = UIStackView(arrangedSubviews: [
            vStackView,
            arrowLabel
        ])
        hStackView.axis = .horizontal
        hStackView.spacing = 4
        hStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hStackView)
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ data: Detail.SummaryViewData) {
        videoTitleLabel.numberOfLines = data.numberOfTitleLines
        arrowLabel.text = data.arrowText
        videoTitleLabel.text = data.title
        dateLabel.text = data.dateText
    }
}
