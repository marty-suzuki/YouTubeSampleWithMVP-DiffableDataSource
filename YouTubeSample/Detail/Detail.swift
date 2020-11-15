//
//  Detail.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/27.
//

import UIKit

enum Detail {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>

    enum Section: Hashable {
        case information
        case videos(segments: [VideoSegment])
        case loading
    }

    enum Item: Hashable {
        case summary(SummaryViewData)
        case channel(ChannelViewData)
        case description(String)
        case video(VideoViewData)
        case loading
    }

    struct SummaryViewData: Hashable {
        let title: String
        let dateText: String
        var numberOfTitleLines: Int
        var arrowText: String
    }

    struct ChannelViewData: Hashable {
        let title: String
        let thumbnail: URL
    }

    enum VideoSegment: String, CaseIterable {
        case newest = "Newest"
        case related = "Related"
    }
}
