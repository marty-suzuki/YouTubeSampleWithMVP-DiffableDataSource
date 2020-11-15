//
//  DetailVideoSwitchSectionHeaderView.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/29.
//

import Reusable
import UIKit

final class DetailVideoSwitchSectionHeaderView: UIView, ReusableView {

    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private var selectedIndexHandler: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        segmentedControl.addTarget(
            self,
            action: #selector(segmentedControlValueChanged(_:)),
            for: .valueChanged
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        selectedIndexHandler?(segmentedControl.selectedSegmentIndex)
    }

    func configure(
        segments: [Detail.VideoSegment],
        selectedSegment: Detail.VideoSegment,
        selectedSegmentHandler: @escaping (Detail.VideoSegment) -> Void
    ) {
        segmentedControl.removeAllSegments()
        segments.forEach {
            segmentedControl.insertSegment(
                withTitle: $0.rawValue,
                at: segmentedControl.numberOfSegments,
                animated: false
            )
        }

        if let index = segments.firstIndex(of: selectedSegment) {
            segmentedControl.selectedSegmentIndex = index
        }

        selectedIndexHandler = { selectedSegmentHandler(segments[$0]) }
    }
}
