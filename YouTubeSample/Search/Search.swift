//
//  Search.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/27.
//

import UIKit

enum Search {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    
    enum Section: Hashable {
        case searchResult
        case loading
    }

    enum Item: Hashable {
        case video(VideoViewData)
        case loading
    }
}
