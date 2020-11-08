//
//  SearchViewPresenter.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import APIModule
import UIKit

protocol SearchViewPresenterProtocol: AnyObject {
    func setup()
    func search(query: String?)
    func selectVideo(with indexPath: IndexPath)
    func willDisplay(indexPath: IndexPath)
}

final class SearchViewPresenter: SearchViewPresenterProtocol {
    private var snapshot = Search.Snapshot()
    private weak var view: SearchViewProtocol?
    private let model: SearchModelProtocol
    private let showDetail: (String) -> Void
    private let openURL: (URL) -> Void
    private let mainAsync: (@escaping () -> Void) -> Void
    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                if snapshot.indexOfSection(.loading) == nil {
                    snapshot.appendSections([.loading])
                }
                if snapshot.indexOfItem(.loading) == nil {
                    snapshot.appendItems([.loading], toSection: .loading)
                }
            } else {
                snapshot.deleteSections([.loading])
            }
            
            mainAsync { [snapshot] in
                self.view?.applySnapshot(snapshot, animated: true)
            }
        }
    }

    init(
        view: SearchViewProtocol,
        model: SearchModelProtocol,
        showDetail: @escaping (String) -> Void,
        openURL: @escaping (URL) -> Void,
        mainAsync: @escaping (@escaping () -> Void) -> Void
    ) {
        self.view = view
        self.model = model
        self.showDetail = showDetail
        self.openURL = openURL
        self.mainAsync = mainAsync

        model.delegate = self
    }

    func setup() {
        view?.applySnapshot(snapshot, animated: false)
    }

    func search(query: String?) {
        model.search(query: query)
    }

    func selectVideo(with indexPath: IndexPath) {
        let section = snapshot.sectionIdentifiers[indexPath.section]
        let items = snapshot.itemIdentifiers(inSection: section)
        switch items[indexPath.row] {
        case let .video(video):
            showDetail(video.videoId)
        case .loading:
            break
        }
    }

    func willDisplay(indexPath: IndexPath) {
        let section = snapshot.sectionIdentifiers[indexPath.section]
        let items = snapshot.itemIdentifiers(inSection: section)
        guard items[indexPath.row] == items.last else {
            return
        }
        model.loadMore()
    }
}

extension SearchViewPresenter: SearchModelDelegate {
    func willStartSearch() {
        isLoading = true
    }

    func didFetchSearchResult(
        query: String,
        result: Result<[YouTube.Video], Either<Error, URL>>,
        shouldRefresh: Bool
    ) {
        defer {
            isLoading = false
        }

        let videos: [YouTube.Video]
        switch result {
        case let .success(value):
            videos = value

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

        if shouldRefresh {
            snapshot.deleteAllItems()
            snapshot.appendSections([.searchResult])
        }

        let data: [Search.Item] = videos.map {
            .video(VideoViewData(
                videoId: $0.id.videoId,
                title: $0.snippet.title,
                channelTitle: $0.snippet.channelTitle,
                thumbnail: $0.snippet.thumbnails.medium.url
            ))
        }
        snapshot.appendItems(data, toSection: .searchResult)
        snapshot.deleteSections([.loading])
        mainAsync { [snapshot] in
            self.view?.applySnapshot(snapshot, animated: true)
        }
    }
}
