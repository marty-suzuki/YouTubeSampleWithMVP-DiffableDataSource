//
//  LoadingView.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/28.
//

import Reusable
import UIKit

final class LoadingView: UIView, ReusableNibView {

    @IBOutlet private weak var indicatorView:  UIActivityIndicatorView!

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
