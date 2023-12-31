
import UIKit

class UpcomingViewController: UIViewController {
    
    private var contents: [Content] = []
    
    private let upcomingTable: UITableView = {
        let tableView = UITableView()
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(upcomingTable)
        
        upcomingTable.delegate = self
        upcomingTable.dataSource = self
        
        getUpcoming()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTable.frame = view.bounds
    }
    
    private func getUpcoming() {
        APIManager.shared.getUpcomingMovies { [weak self] result in
            switch result {
            case .success(let contents):
                self?.contents = contents
                DispatchQueue.main.async {
                    self?.upcomingTable.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension UpcomingViewController: UITableViewDataSource, UITableViewDelegate  {
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
