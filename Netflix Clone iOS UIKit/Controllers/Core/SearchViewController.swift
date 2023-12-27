
import UIKit

class SearchViewController: UIViewController {
    
    private var contents: [Content] = []
    
    private let discoverTable: UITableView = {
        let tableView = UITableView()
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        return tableView
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search Movies or TV Series"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(discoverTable)
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        
        discoverTable.delegate = self
        discoverTable.dataSource = self
        
        getDiscoverMovies()
        
        searchController.searchResultsUpdater = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
    
    private func getDiscoverMovies() {
        APIManager.shared.getDiscoverMovies { [weak self] result in
            switch result {
            case .success(let contents):
                self?.contents = contents
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier, for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        let contentViewModel = ContentViewModel(contentName: contents[indexPath.row].originalTitle ?? contents[indexPath.row].originalName ?? "Unknown", posterUrl: contents[indexPath.row].posterPath ?? "")
        cell.configure(with: contentViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let content = contents[indexPath.row]
        guard let contentName = content.originalTitle ?? content.originalName else {
            return
        }
        
        APIManager.shared.getMovie(for: contentName + " trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                let viewModel = ContentPreviewViewModel(
                    title: contentName,
                    overview: self?.contents[indexPath.row].overview ?? "",
                    youtubeVideo: videoElement
                )
                                
                DispatchQueue.main.async { [weak self] in
                    let vc = ContentPreviewViewController()
                    vc.configure(with: viewModel)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        
        resultsController.delegate = self
        
        APIManager.shared.search(for: query) { result in
            switch result {
            case .success(let contents):
                DispatchQueue.main.async {
                    resultsController.contents = contents
                    resultsController.searchResultsCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidTapItem(_ viewModel: ContentPreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = ContentPreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
