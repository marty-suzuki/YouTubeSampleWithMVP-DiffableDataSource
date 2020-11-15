//
//  DetailViewController.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

import Reusable
import UIKit

protocol DetailViewProtocol: AnyObject {
    func loadPlayer(_ embedHtml: String)
    func applySnapshot(_ snapshot: Detail.Snapshot, animated: Bool)
    func showAlert(title: String, message: String, actions: [UIAlertAction])
}

final class DetailViewController: UIViewController {
    typealias MakePresenter = (DetailViewProtocol) -> DetailViewPresenterProtocol

    private let playerView: DetailPlayerView = {
        let playerView = DetailPlayerView(frame: .zero)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.reusable.registerCell(DetailSummaryView.self)
        tableView.reusable.registerCell(DetailChannelView.self)
        tableView.reusable.registerCell(DetailDescriptionView.self)
        tableView.reusable.registerCell(VideoView.self)
        tableView.reusable.registerCell(LoadingView.self)
        tableView.reusable.registerHeaderFooterView(DetailVideoSwitchSectionHeaderView.self)
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

    private lazy var baseStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [playerView, tableView])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var ratioConstraint = playerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2 / 5)

    private lazy var cellProvider: Detail.DataSource.CellProvider = { tableView, indexPath, item in
        switch item {
        case let .summary(data):
            let result = tableView.reusable.dequeueCell(DetailSummaryView.self, for: indexPath)
            result.view.configure(data)
            return result.cell()

        case let .channel(data):
            let result = tableView.reusable.dequeueCell(DetailChannelView.self, for: indexPath)
            result.view.configure(data)
            return result.cell(selectionStyle: .none)

        case let .description(text):
            let result = tableView.reusable.dequeueCell(DetailDescriptionView.self, for: indexPath)
            result.view.configure(text)
            return result.cell(selectionStyle: .none)

        case let .video(data):
            let result = tableView.reusable.dequeueCell(VideoView.self, for: indexPath)
            result.view.configure(data)
            return result.cell()

        case .loading:
            let result = tableView.reusable.dequeueCell(LoadingView.self, for: indexPath)
            result.view.startAnimating()
            return result.cell(selectionStyle: .none)
        }
    }

    private lazy var dataSource: Detail.DataSource = {
        let dataSource = Detail.DataSource(tableView: tableView, cellProvider: cellProvider)
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }()

    private let makePresenter: MakePresenter
    private lazy var presenter = makePresenter(self)

    init(makePresenter: @escaping MakePresenter) {
        self.makePresenter = makePresenter
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        view.backgroundColor = .systemGray6

        view.addSubview(baseStackView)
        NSLayoutConstraint.activate([
            baseStackView.topAnchor.constraint(equalTo: view.topAnchor),
            baseStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            baseStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            baseStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        presenter.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        playerView.setNeedsUpdateConstraints()
        view.setNeedsUpdateConstraints()
        coordinator.animate(alongsideTransition: { _ in
            self.playerView.updateConstraintsIfNeeded()
        })
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        let isLandscape = traitCollection.verticalSizeClass == .compact && traitCollection.userInterfaceIdiom == .phone
        if isLandscape {
            baseStackView.axis = .horizontal
            ratioConstraint.isActive = true
        } else {
            baseStackView.axis = .vertical
            ratioConstraint.isActive = false
        }
    }
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.select(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch dataSource.snapshot().sectionIdentifiers[section] {
        case .information, .loading:
            return .leastNormalMagnitude
        case .videos:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch dataSource.snapshot().sectionIdentifiers[section] {
        case .information, .loading:
            return nil
        case let .videos(segments):
            guard segments.count > 1 else {
                return nil
            }

            let result = tableView.reusable.dequeueHeaderFooterView(DetailVideoSwitchSectionHeaderView.self)
            result.view.configure(
                segments: segments,
                selectedSegment: presenter.selectedVideoSegment
            ) { [weak self] in
                self?.presenter.selectSegment($0)
            }
            return result.headerFooterView()
        }
    }
}

extension DetailViewController: DetailViewProtocol {
    func loadPlayer(_ embedHtml: String) {
        playerView.load(embedHtml: embedHtml)
    }

    func applySnapshot(_ snapshot: Detail.Snapshot, animated: Bool) {
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach(alert.addAction)
        present(alert, animated: true, completion: nil)
    }
}
