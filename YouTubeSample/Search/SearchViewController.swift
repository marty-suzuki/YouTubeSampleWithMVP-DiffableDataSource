//
//  SearchViewController.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import Reusable
import UIKit

protocol SearchViewProtocol: AnyObject {
    func applySnapshot(_ snapshot: Search.Snapshot, animated: Bool)
    func showAlert(title: String, message: String, actions: [UIAlertAction])
}

final class SearchViewController: UIViewController {
    typealias MakePresernter = (SearchViewProtocol) -> SearchViewPresenterProtocol

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Input keyword"
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.reusable.registerCell(VideoView.self)
        tableView.reusable.registerCell(LoadingView.self)
        tableView.tableHeaderView = {
            let view = UIView(frame: .zero)
            view.frame.size.height = .leastNormalMagnitude
            return view
        }()
        tableView.tableFooterView = {
            let view = UIView(frame: .zero)
            view.frame.size.height = .leastNormalMagnitude
            return view
        }()
        return tableView
    }()

    private lazy var cellProvider: Search.DataSource.CellProvider = { tableView, indexPath, item in
        switch item {
        case let .video(video):
            let result = tableView.reusable.dequeueCell(VideoView.self, for: indexPath)
            result.view.configure(video)
            return result.cell()
        case .loading:
            let result = tableView.reusable.dequeueCell(LoadingView.self, for: indexPath)
            result.view.startAnimating()
            return result.cell(selectionStyle: .none)
        }
    }

    private lazy var dataSource: Search.DataSource = {
        let dataSource = Search.DataSource(tableView: tableView, cellProvider: cellProvider)
        dataSource.defaultRowAnimation = .top
        return dataSource
    }()

    private let makePresenter: MakePresernter
    private lazy var presenter = makePresenter(self)

    init(makePresenter: @escaping MakePresernter) {
        self.makePresenter = makePresenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        searchBar.delegate = self
        navigationItem.titleView = searchBar

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        presenter.setup()
    }
}

extension SearchViewController: SearchViewProtocol {
    func applySnapshot(_ snapshot: Search.Snapshot, animated: Bool) {
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach(alert.addAction)
        present(alert, animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        presenter.search(query: searchBar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectVideo(with: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplay(indexPath: indexPath)
    }
}
