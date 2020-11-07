//
//  ViewController.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/25.
//

import UIKit
import APIModule
import WebKit

final class ViewController: UINavigationController {
    private let isWarning: Bool

    required init?(coder aDecoder: NSCoder) {
        if let key = Bundle.main.infoDictionary?["YouTubeAPIKey"] as? String {
            self.isWarning = key.isEmpty
        } else {
            self.isWarning = true
        }

        super.init(coder: aDecoder)

        guard !isWarning else {
            return
        }

        let searchVC = SearchViewController(makePresenter: { [weak self] in
            let api = YouTube.API(urlSession: .shared, bundle: .main)
            let model = SearchModel(search: api.search)
            return SearchViewPresenter(
                view: $0,
                model: model,
                showDetail: { self?.showDetail(videoId: $0) },
                openURL: { UIApplication.shared.open($0, options: [:], completionHandler: nil) }
            )
        })
        
        setViewControllers([searchVC], animated: false)
    }

    private func showDetail(videoId: String) {
        let detailVC = DetailViewController(makePresenter: {
            let api = YouTube.API(urlSession: .shared, bundle: .main)
            let model = DetailModel(
                getRelatedVideos: api.search(relatedToVideoId:limit:completion:),
                getNewestVideos: api.search(channelId:limit:completion:),
                getVideos: api.videos,
                getChannels: api.channels
            )
            return DetailViewPresenter(
                videoId: videoId,
                view: $0,
                model: model,
                showDetail: { [weak self] videoId in
                    guard let me = self else {
                        return
                    }
                    me.dismiss(animated: true) {
                        me.showDetail(videoId: videoId)
                    }
                },
                openURL: { UIApplication.shared.open($0, options: [:], completionHandler: nil) }
            )
        })
        present(detailVC, animated: true, completion: nil)
    }

    override func loadView() {
        super.loadView()

        guard isWarning else {
            return
        }

        self.view = WarningView(frame: view.bounds)
    }
}

extension ViewController {
    private final class WarningView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)

            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 20)
            label.textColor = .darkGray
            label.text = """
            You must set value for \"YouTubeAPIKey\" in Info.plist!!
            In addtion, you must change \"Bundle Identifier\" when registering API Key.

            See \"API keys\" section in this link.
            https://developers.google.com/youtube/registering_an_application?hl=en
            """

            addSubview(label)
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            ])

            backgroundColor = .white
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
