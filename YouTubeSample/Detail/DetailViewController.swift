//
//  DetailViewController.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/26.
//

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
        tableView.register(DetailSummaryViewCell.self, forCellReuseIdentifier: DetailSummaryViewCell.reuseIdentifier)
        tableView.register(DetailChannelViewCell.self, forCellReuseIdentifier: DetailChannelViewCell.reuseIdentifier)
        tableView.register(DetailDescriptionViewCell.self, forCellReuseIdentifier: DetailDescriptionViewCell.reuseIdentifier)
        tableView.register(VideoViewCell.self, forCellReuseIdentifier: VideoViewCell.reuseIdentifier)
        tableView.register(LoadingViewCell.self, forCellReuseIdentifier: LoadingViewCell.reuseIdentifier)
        tableView.register(DetailVideoSwitchSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: DetailVideoSwitchSectionHeaderView.reuseIdentifier)
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailSummaryViewCell.reuseIdentifier,
                for: indexPath
            ) as! DetailSummaryViewCell
            cell.configure(data)
            return cell

        case let .channel(data):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailChannelViewCell.reuseIdentifier,
                for: indexPath
            ) as! DetailChannelViewCell
            cell.configure(data)
            return cell

        case let .description(text):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailDescriptionViewCell.reuseIdentifier,
                for: indexPath
            ) as! DetailDescriptionViewCell
            cell.configure(text)
            return cell

        case let .video(data):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: VideoViewCell.reuseIdentifier,
                for: indexPath
            ) as! VideoViewCell
            cell.configure(data)
            return cell

        case .loading:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LoadingViewCell.reuseIdentifier,
                for: indexPath
            ) as! LoadingViewCell
            cell.startAnimating()
            return cell
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

        let isLandscape = traitCollection.verticalSizeClass == .compact && traitCollection.horizontalSizeClass == .regular
        if isLandscape {
            baseStackView.axis = .horizontal
            ratioConstraint.isActive = true
        }  else {
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
        case .videos:
            let view = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: DetailVideoSwitchSectionHeaderView.reuseIdentifier
            ) as! DetailVideoSwitchSectionHeaderView
            view.configure(
                segments: presenter.videoSegments,
                selectedSegment: presenter.selectedVideoSegment,
                delegate: self
            )
            return view
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

extension DetailViewController: DetailVideoSwitchSectionHeaderViewDelegate {
    func sectionHeaderView(_ view: DetailVideoSwitchSectionHeaderView, selectedIndexChanged index: Int) {
        presenter.selectSegment(index: index)
    }
}
