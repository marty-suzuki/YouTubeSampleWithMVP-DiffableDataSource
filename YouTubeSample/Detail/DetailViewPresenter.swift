//
//  DetailViewPresenter.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import APIModule
import UIKit

protocol DetailViewPresenterProtocol: AnyObject {
    var videoSegments: [Detail.VideoSegment] { get }
    var selectedVideoSegment: Detail.VideoSegment { get }
    func setup()
    func viewDidAppear()
    func select(indexPath: IndexPath)
    func selectSegment(index: Int)
}

final class DetailViewPresenter: DetailViewPresenterProtocol {
    private var snapshot = Detail.Snapshot()
    private weak var view: DetailViewProtocol?
    private let model: DetailModelProtocol
    private let showDetail: (String) -> Void
    private let openURL: (URL) -> Void
    private let mainAsync: (@escaping () -> Void) -> Void
    private let videoId: String
    private var channelId: String?
    private var isViewAppeared = false
    private var isLoading = false
    private var canShowAll = false
    private var summary: Detail.SummaryViewData?
    private var desciprion: String?
    private var relatedVideos: [VideoViewData] = []
    private var newestVideos: [VideoViewData] = []
    private var channel: Detail.ChannelViewData?

    let videoSegments = Detail.VideoSegment.allCases
    private(set) var selectedVideoSegment: Detail.VideoSegment = .newest

    init(
        videoId: String,
        view: DetailViewProtocol,
        model: DetailModelProtocol,
        showDetail: @escaping (String) -> Void,
        openURL: @escaping (URL) -> Void,
        mainAsync: @escaping (@escaping () -> Void) -> Void
    ) {
        self.view = view
        self.model = model
        self.videoId = videoId
        self.showDetail = showDetail
        self.openURL = openURL
        self.mainAsync = mainAsync

        model.delegate = self
    }

    func setup() {
        view?.applySnapshot(snapshot, animated: false)
        model.videoDetail(videoId: videoId)
    }

    func viewDidAppear() {
        guard !isViewAppeared else {
            return
        }
        isViewAppeared = true

        setupContents()
    }

    func select(indexPath: IndexPath) {
        let section = snapshot.sectionIdentifiers[indexPath.section]
        let items = snapshot.itemIdentifiers(inSection: section)
        let item = items[indexPath.row]

        switch item {
        case let .video(data):
            showDetail(data.videoId)

        case .summary:
            self.canShowAll = !canShowAll
            self.summary?.numberOfTitleLines = numberOfTitleLines()
            self.summary?.arrowText = arrowText()
            updateSnapshot()

        case .description, .channel, .loading:
            break
        }
    }

    func selectSegment(index: Int) {
        self.selectedVideoSegment = videoSegments[index]
        updateSnapshot()
    }

    private func setupContents() {
        guard isViewAppeared, let channelId = channelId else {
            return
        }

        if channel == nil {
            model.channel(channelId: channelId)
        }

        if relatedVideos.isEmpty {
            model.relatedVideos(videoId: videoId)
        }

        if newestVideos.isEmpty {
            model.newestVideos(
                channelId: channelId,
                excludeVideoId: videoId
            )
        }
    }

    private func updateSnapshot() {
        guard isViewAppeared else {
            if isLoading {
                snapshot = Detail.Snapshot()
                snapshot.appendSections([.loading])
                snapshot.appendItems([.loading], toSection: .loading)
                mainAsync {
                    self.view?.applySnapshot(self.snapshot, animated: true)
                }
            }
            return
        }

        let data: [(Detail.Section, [Detail.Item])] = [
            (.information, [
                summary.map(Detail.Item.summary),
                channel.map(Detail.Item.channel),
                canShowAll ? desciprion.map(Detail.Item.description) : nil
            ].compactMap { $0 }),
            (.videos, {
                switch selectedVideoSegment {
                case .newest:
                    return newestVideos.map(Detail.Item.video)
                case .related:
                    return relatedVideos.map(Detail.Item.video)
                }
            }())
        ]

        snapshot = Detail.Snapshot()
        data.forEach { section, items in
            guard !items.isEmpty else {
                return
            }
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }

        mainAsync {
            self.view?.applySnapshot(self.snapshot, animated: true)
        }
    }

    private func numberOfTitleLines() -> Int {
        canShowAll ? 0 : 2
    }

    private func arrowText() -> String {
        canShowAll ? "▲" : "▼"
    }
}

extension DetailViewPresenter: DetailModelDelegate {
    func willStartFetchingVideoDetail() {
        isLoading = true
        updateSnapshot()
    }

    func didFetchVideoDetail(_ result: Result<YouTube.VideoDetail, Either<Error, URL>>) {
        defer {
            isLoading = false
            updateSnapshot()
        }

        let videoDetail: YouTube.VideoDetail
        switch result {
        case let .success(value):
            videoDetail = value

        case let .failure(.right(url)):
            let actions = [
                UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                    self?.openURL(url)
                },
                UIAlertAction(title: "No", style: .cancel, handler: nil)
            ]

            mainAsync {
                self.view?.showAlert(
                    title: "Error",
                    message: "Do you open in Safari?",
                    actions: actions
                )
            }
            return

        case .failure(.left):
            return
        }

        let snippet = videoDetail.snippet

        self.channelId = snippet.channelId
        self.summary = Detail.SummaryViewData(
            title: snippet.title,
            dateText: {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                return formatter.string(from: snippet.publishedAt)
            }(),
            numberOfTitleLines: numberOfTitleLines(),
            arrowText: arrowText()
        )
        self.desciprion = snippet.description

        mainAsync {
            self.view?.loadPlayer(videoDetail.player.embedHtml)
        }

        setupContents()
    }

    func didFetchRelatedVideos(_ videos: [YouTube.Video]) {
        guard !videos.isEmpty else {
            return
        }

        self.relatedVideos = videos.map {
            VideoViewData(
                videoId: $0.id.videoId,
                title: $0.snippet.title,
                channelTitle: $0.snippet.channelTitle,
                thumbnail: $0.snippet.thumbnails.medium.url
            )
        }

        updateSnapshot()
    }

    func didFetchNewestVideos(_ videos: [YouTube.Video]) {
        guard !videos.isEmpty else {
            return
        }

        self.newestVideos = videos.map {
            VideoViewData(
                videoId: $0.id.videoId,
                title: $0.snippet.title,
                channelTitle: $0.snippet.channelTitle,
                thumbnail: $0.snippet.thumbnails.medium.url
            )
        }

        updateSnapshot()
    }

    func didFetchChannel(_ channel: YouTube.Channel) {
        let snippet = channel.snippet
        self.channel = Detail.ChannelViewData(
            title: snippet.title,
            thumbnail: snippet.thumbnails.default.url
        )

        updateSnapshot()
    }
}
