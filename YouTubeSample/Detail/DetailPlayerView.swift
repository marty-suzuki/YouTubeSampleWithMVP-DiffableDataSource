//
//  DetailPlayerView.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import UIKit
import WebKit

final class DetailPlayerView: UIView {

    private let webview: WKWebView = {
        let webview = WKWebView(frame: .zero, configuration: .init())
        webview.scrollView.isScrollEnabled = false
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.scrollView.backgroundColor = .clear
        return webview
    }()

    private lazy var landscapeConstraints: [NSLayoutConstraint] = [
        webview.topAnchor.constraint(equalTo: topAnchor, constant: 24),
        webview.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 24),
        webview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        webview.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
    ]

    private lazy var portraitConstraints: [NSLayoutConstraint] = [
        webview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        webview.leadingAnchor.constraint(equalTo: leadingAnchor),
        webview.trailingAnchor.constraint(equalTo: trailingAnchor),
        webview.bottomAnchor.constraint(equalTo: bottomAnchor)
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(webview)
        webview.heightAnchor.constraint(equalTo: webview.widthAnchor, multiplier: 9 / 16).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        let isLandscape = traitCollection.verticalSizeClass == .compact && traitCollection.horizontalSizeClass == .regular
        if isLandscape {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }  else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }

        super.updateConstraints()
    }

    func load(embedHtml: String) {
        let htmlString = """
        <!DOCTYPE html>
        <html lang="ja">
            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <style>
                    body,html,iframe {
                        margin:0;
                        padding:0;
                    }
                    .iframe-wrap {
                        position: relative;
                        width: 100%;
                        padding-top: 56.25%;
                        overflow:auto;
                        -webkit-overflow-scrolling:touch;
                    }
                    .iframe-wrap iframe {
                        position:absolute;
                        top:0;
                        left:0;
                        width:100%;
                        height:100%;
                        border:none;
                        display:block;
                    }
                </style>
            </head>
            <body>
                <div class="iframe-wrap">\(embedHtml)</div>
            </body>
        </html>
        """
        webview.loadHTMLString(htmlString, baseURL: URL(string: "https://www.youtube.com")!)
    }
}
