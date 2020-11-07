import Foundation

extension YouTube {
    public final class API {
        private let urlSession: URLSession

        private let apiKey: String?
        private let bundleID: String

        public init(urlSession: URLSession,
                    bundle: Bundle) {
            self.urlSession = urlSession
            self.bundleID = bundle.bundleIdentifier!
            self.apiKey = bundle.infoDictionary?["YouTubeAPIKey"] as? String
        }
    }
}

extension YouTube.API {
    public enum Error: Swift.Error {
        case noData
        case emptyYouTubeAPIKey
        case urlGenerationFailed
        case dataTaskFailed(Swift.Error)
        case decodeFailed(Swift.Error)
    }

    private func request<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem],
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask? {
        guard var components = URLComponents(string: "https://www.googleapis.com/youtube/v3/\(path)") else {
            completion(.failure(.urlGenerationFailed))
            return nil
        }

        guard let apiKey = apiKey, !apiKey.isEmpty else {
            completion(.failure(.emptyYouTubeAPIKey))
            return nil
        }

        components.queryItems = queryItems + [URLQueryItem(name: "key", value: apiKey)]

        guard let url = components.url else {
            completion(.failure(.urlGenerationFailed))
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue(bundleID, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.dataTaskFailed(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let response = try decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.decodeFailed(error)))
            }
        }
        task.resume()
        return task
    }

    public func search(
        query: String,
        limit: Int,
        pageToken: String?,
        completion: @escaping (Result<YouTube.Response<YouTube.Video>, Error>) -> Void
    ) -> URLSessionTask? {
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoEmbeddable", value: "true"),
            URLQueryItem(name: "maxResults", value: "\(limit)"),
            URLQueryItem(name: "q", value: query),
            pageToken.map { URLQueryItem(name: "pageToken", value: $0) }
        ].compactMap { $0 }
        return request(path: "search", queryItems: queryItems, completion: completion)
    }

    public func search(
        relatedToVideoId videoId: String,
        limit: Int,
        completion: @escaping (Result<YouTube.Response<YouTube.Video>, Error>) -> Void
    ) -> URLSessionTask? {
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoEmbeddable", value: "true"),
            URLQueryItem(name: "maxResults", value: "\(limit)"),
            URLQueryItem(name: "relatedToVideoId", value: videoId)
        ]
        return request(path: "search", queryItems: queryItems, completion: completion)
    }

    public func search(
        channelId: String,
        limit: Int,
        completion: @escaping (Result<YouTube.Response<YouTube.Video>, Error>) -> Void
    ) -> URLSessionTask? {
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoEmbeddable", value: "true"),
            URLQueryItem(name: "maxResults", value: "\(limit)"),
            URLQueryItem(name: "order", value: "date"),
            URLQueryItem(name: "channelId", value: channelId)
        ]
        return request(path: "search", queryItems: queryItems, completion: completion)
    }

    public func videos(
        ids: [String],
        completion: @escaping (Result<YouTube.Response<YouTube.VideoDetail>, Error>) -> Void
    ) -> URLSessionTask? {
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet,player"),
            URLQueryItem(name: "id", value: ids.joined(separator: ","))
        ]
        return request(path: "videos", queryItems: queryItems, completion: completion)
    }

    public func channels(
        ids: [String],
        completion: @escaping (Result<YouTube.Response<YouTube.Channel>, Error>) -> Void
    ) -> URLSessionTask? {
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "id", value: ids.joined(separator: ","))
        ]
        return request(path: "channels", queryItems: queryItems, completion: completion)
    }
}
