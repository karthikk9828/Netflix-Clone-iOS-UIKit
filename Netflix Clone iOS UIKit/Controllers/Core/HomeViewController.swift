
import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingSeries = 1
    case PopularMovies = 2
    case UpcomingMovies = 3
    case TopRatedMovies = 4
}

class HomeViewController: UIViewController {
    
    private var randomTrendingMovie: Content?
    private var headerView: HeroHeaderUIView?
    
    let sectionTitles: [String] = [
        "Trending Movies",
        "Trending Series",
        "Popular Movies",
        "Upcoming Movies",
        "Top Rated Movies",
    ]
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        
        homeFeedTable.dataSource = self
        homeFeedTable.delegate = self
        
        configureNavigationBar()
        configureHeeaderView()
        
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeFeedTable.tableHeaderView = headerView
    }
    
    private func configureHeeaderView() {
        APIManager.shared.getTrendingMovies { [weak self] result in
            switch result {
            case .success(let contents):
                let selected = contents.randomElement()
                self?.randomTrendingMovie = selected
                
                let viewModel = ContentViewModel(
                    contentName: selected?.originalTitle ?? "",
                    posterUrl: selected?.posterPath ?? ""
                )
                self?.headerView?.configure(with: viewModel)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func configureNavigationBar() {
        var image = UIImage(named: "netflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil),
        ]
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        switch indexPath.section {
        case Sections.TrendingMovies.rawValue:
            APIManager.shared.getTrendingMovies { result in
                switch result {
                case .success(let contents):
                    cell.configure(with: contents)
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.TrendingSeries.rawValue:
            APIManager.shared.getTrendingSeries { result in
                switch result {
                case .success(let contents):
                    cell.configure(with: contents)
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.PopularMovies.rawValue:
            APIManager.shared.getPopularMovies { result in
                switch result {
                case .success(let contents):
                    cell.configure(with: contents)
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.UpcomingMovies.rawValue:
            APIManager.shared.getUpcomingMovies { result in
                switch result {
                case .success(let contents):
                    cell.configure(with: contents)
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.TopRatedMovies.rawValue:
            APIManager.shared.getTopRatedMovies { result in
                switch result {
                case .success(let contents):
                    cell.configure(with: contents)
                case .failure(let error):
                    print(error)
                }
            }
        default:
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultoffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultoffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

extension HomeViewController: CollectionViewTableViewCellDelegate {
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: ContentPreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = ContentPreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
