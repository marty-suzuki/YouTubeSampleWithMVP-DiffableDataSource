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
    
    private enum CodingKeys: String, CodingKey {
        case items
        case nextPageToken
        case pageInfo
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([Result<Item, Error>].self, forKey: .items)
            .compactMap { try? $0.get() }
        self.pageInfo = try container.decode(PageInfo.self, forKey: .pageInfo)
        self.nextPageToken = try container.decodeIfPresent(String.self, forKey: .nextPageToken)
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
