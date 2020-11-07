//
//  SearchModel.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import APIModule
import Foundation

protocol SearchModelDelegate: AnyObject {
    func willStartSearch()
    func didFetchSearchResult(
        query: String,
        result: Result<[YouTube.Video], Either<Error, URL>>,
        shouldRefresh: Bool
    )
}

protocol SearchModelProtocol: AnyObject {
    var delegate: SearchModelDelegate? { get set }
    func search(query: String?)
    func loadMore()
}

final class SearchModel: SearchModelProtocol {
    typealias SearchResponse = Result<YouTube.Response<YouTube.Video>, YouTube.API.Error>
    typealias Search = (String, Int, String?, @escaping (SearchResponse) -> Void) -> URLSessionTask?

    private let _search: Search
    private var dataTask: URLSessionTask?
    private var fetchState: FetchState = .initial

    weak var delegate: SearchModelDelegate?

    init(search: @escaping Search) {
        self._search = search
    }

    func search(query: String?) {
        guard let query = query, !query.isEmpty else {
            return
        }

        dataTask?.cancel()
        fetchState = .initial

        search(query: query, nextToken: nil, shouldRefresh: true)
    }

    func loadMore() {
        guard
            case let .hasNext(query, nextToken) = fetchState,
            dataTask == nil
        else {
            return
        }

        search(query: query, nextToken: nextToken, shouldRefresh: false)
    }

    private func search(query: String, nextToken: String?, shouldRefresh: Bool) {
        delegate?.willStartSearch()
        dataTask = _search(query, 20, nextToken) { [weak self] result in
            guard let me = self else {
                return
            }

            do {
                let response = try result.get()
                me.fetchState = response.nextPageToken
                    .map { .hasNext(query: query, nextToken: $0) }
                    ?? .fetchAll
                me.dataTask = nil
                me.delegate?.didFetchSearchResult(
                    query: query,
                    result: .success(response.items),
                    shouldRefresh: shouldRefresh
                )
            } catch {
                let either: Either<Error, URL>
                if let url: URL = {
                    guard var componets = URLComponents(string: "https://www.youtube.com/results") else {
                        return nil
                    }
                    componets.queryItems = [URLQueryItem(name: "search_query", value: query)]
                    return componets.url
                }() {
                    either = .right(url)
                } else {
                    either = .left(error)
                }
                me.delegate?.didFetchSearchResult(
                    query: query,
                    result: .failure(either),
                    shouldRefresh: shouldRefresh
                )
            }
        }
    }
}

extension SearchModel {
    fileprivate enum FetchState {
        case initial
        case hasNext(query: String, nextToken: String)
        case fetchAll
    }
}
