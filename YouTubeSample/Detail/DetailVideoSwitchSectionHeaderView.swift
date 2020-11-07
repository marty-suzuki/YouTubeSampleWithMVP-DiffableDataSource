//
//  DetailVideoSwitchSectionHeaderView.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/29.
//

import Reusable
import UIKit

protocol DetailVideoSwitchSectionHeaderViewDelegate: AnyObject {
    func sectionHeaderView(_ view: DetailVideoSwitchSectionHeaderView, selectedIndexChanged index: Int)
}

final class DetailVideoSwitchSectionHeaderView: UIView, ReusableView {

    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private weak var delegate: DetailVideoSwitchSectionHeaderViewDelegate?

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
        delegate?.sectionHeaderView(self, selectedIndexChanged: segmentedControl.selectedSegmentIndex)
    }

    func configure(
        segments: [Detail.VideoSegment],
        selectedSegment: Detail.VideoSegment,
        delegate: DetailVideoSwitchSectionHeaderViewDelegate
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

        self.delegate = delegate
    }
}
