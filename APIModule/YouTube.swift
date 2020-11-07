public enum YouTube {
    public struct Response<Item: Decodable>: Decodable {
        public let items: [Item]
        public let nextPageToken: String?
        public let pageInfo: PageInfo
    }

    public struct Video: Decodable {
        public let id: ID
        public let snippet: Snippet
    }

    public struct VideoDetail: Decodable {
        public let id: String
        public let snippet: Snippet
        public let player: Player
    }

    public struct Channel: Decodable {
        public let id: String
        public let snippet: Snippet
    }

    public struct Thumbnail: Decodable {
        public let `default`: Info
        public let medium: Info
        public let high: Info
    }
}

extension YouTube.Response {
    public struct PageInfo: Decodable {
        public let totalResults: Int?
        public let resultsPerPage: Int
    }
}

extension YouTube.Video {

    public struct ID: Decodable {
        public let kind: String
        public let videoId: String
    }

    public struct Snippet: Decodable {
        public let publishedAt: Date
        public let channelId: String
        public let title: String
        public let description: String
        public let thumbnails: YouTube.Thumbnail
        public let channelTitle: String
        public let liveBroadcastContent: String
        public let publishTime: Date
    }
}

extension YouTube.VideoDetail {
    public struct Player: Decodable {
        public let embedHtml: String
    }

    public struct Snippet: Decodable {
        public let publishedAt: Date
        public let channelId: String
        public let title: String
        public let description: String
        public let thumbnails: YouTube.Thumbnail
        public let channelTitle: String
        public let liveBroadcastContent: String
    }
}

extension YouTube.Channel {
    public struct Snippet: Decodable {
        public let publishedAt: Date
        public let title: String
        public let description: String
        public let thumbnails: YouTube.Thumbnail
    }
}


extension YouTube.Thumbnail {
    public struct Info: Decodable {
        public let url: URL
        public let width: Int
        public let height: Int
    }
}
