//
//  DetailModel.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import APIModule
import Foundation

protocol DetailModelDelegate: AnyObject {
    func willStartFetchingVideoDetail()
    func didFetchVideoDetail(_ result: Result<YouTube.VideoDetail, Either<Error, URL>>)
    func didFetchRelatedVideos(_ videos: [YouTube.Video])
    func didFetchNewestVideos(_ videos: [YouTube.Video])
    func didFetchChannel(_ channel: YouTube.Channel)
}

protocol DetailModelProtocol: AnyObject {
    var delegate: DetailModelDelegate? { get set }
    func videoDetail(videoId: String)
    func relatedVideos(videoId: String)
    func channel(channelId: String)
    func newestVideos(channelId: String, excludeVideoId: String)
}

final class DetailModel: DetailModelProtocol {
    typealias VideosResponse = Result<YouTube.Response<YouTube.Video>, YouTube.API.Error>
    typealias GetVideos = (String, Int, @escaping (VideosResponse) -> Void) -> URLSessionTask?
    typealias VideoDeailsResponse = Result<YouTube.Response<YouTube.VideoDetail>, YouTube.API.Error>
    typealias GetVideoDetails = ([String], @escaping (VideoDeailsResponse) -> Void) -> URLSessionTask?
    typealias ChannelsResponse = Result<YouTube.Response<YouTube.Channel>, YouTube.API.Error>
    typealias GetChannels = ([String], @escaping (ChannelsResponse) -> Void) -> URLSessionTask?

    private let _getRelatedVideos: GetVideos
    private let _getNewestVideos: GetVideos
    private let _getVideos: GetVideoDetails
    private let _getChannels: GetChannels

    weak var delegate: DetailModelDelegate?

    init(
        getRelatedVideos: @escaping GetVideos,
        getNewestVideos: @escaping GetVideos,
        getVideos: @escaping GetVideoDetails,
        getChannels: @escaping GetChannels
    ) {
        self._getRelatedVideos = getRelatedVideos
        self._getNewestVideos = getNewestVideos
        self._getVideos = getVideos
        self._getChannels = getChannels
    }

    func videoDetail(videoId: String) {
        delegate?.willStartFetchingVideoDetail()
        
        _ = _getVideos([videoId]) { [weak delegate] result in
            let makeURL: () -> URL? = {
                guard var componets = URLComponents(string: "https://www.youtube.com/watch") else {
                    // - TODO: Irregular case handling
                    return nil
                }
                componets.queryItems = [URLQueryItem(name: "v", value: videoId)]
                return componets.url
            }

            let res: Result<YouTube.VideoDetail, Either<Error, URL>>
            switch result {
            case let .success(response):
                if let video = response.items.first {
                    res = .success(video)
                } else if let url = makeURL() {
                    res = .failure(.right(url))
                } else {
                    // - TODO: Irregular case handling
                    return
                }

            case let .failure(error):
                if let url = makeURL() {
                    res = .failure(.right(url))
                } else {
                    res = .failure(.left(error))
                }
            }
            delegate?.didFetchVideoDetail(res)
        }
    }

    func relatedVideos(videoId: String) {
        _ = _getRelatedVideos(videoId, 20) { [weak delegate] result in
            switch result {
            case let .success(response):
                delegate?.didFetchRelatedVideos(response.items)

            case .failure:
                // - TODO: Error handling
                break
            }
        }
    }

    func newestVideos(channelId: String, excludeVideoId: String) {
        _ = _getNewestVideos(channelId, 20) { [weak delegate] result in
            switch result {
            case let .success(response):
                let videos = response.items
                    .filter { $0.id.videoId != excludeVideoId }
                delegate?.didFetchNewestVideos(videos)

            case .failure:
                // - TODO: Error handling
                break
            }
        }
    }

    func channel(channelId: String) {
        _ = _getChannels([channelId]) { [weak delegate] result in
            switch result {
            case let .success(response):
                guard let channel = response.items.first else {
                    // - TODO: Irregular case handling
                    return
                }
                delegate?.didFetchChannel(channel)
            case .failure:
                // - TODO: Error handling
                break
            }
        }
    }
}
