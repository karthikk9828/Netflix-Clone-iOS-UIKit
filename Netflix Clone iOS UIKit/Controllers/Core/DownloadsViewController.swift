
import UIKit

class DownloadsViewController: UIViewController {
    private var contentItems: [ContentItem] = []
    
    private let dowloadedTable: UITableView = {
        let tableView = UITableView()
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.addSubview(dowloadedTable)
        
        dowloadedTable.delegate = self
        dowloadedTable.dataSource = self
        
        getLocalDownloadedContents()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("downloaded"), object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.getLocalDownloadedContents()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dowloadedTable.frame = view.bounds
    }
    
    private func getLocalDownloadedContents() {
        DataPersistenceManager.shared.getDownloadedContents { [weak self] result in
            switch result {
            case .success(let contents):
                self?.contentItems = contents
                DispatchQueue.main.async {
                    self?.dowloadedTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension DownloadsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier, for: indexPath) as? ContentTableViewCell else {
            return UITableViewCell()
        }
        let content = contentItems[indexPath.row]
        let contentViewModel = ContentViewModel(
            contentName: content.originalTitle ?? content.originalName ?? "Unknown",
            posterUrl: content.posterPath ?? ""
        )
        cell.configure(with: contentViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let content = contentItems[indexPath.row]
            DataPersistenceManager.shared.deleteContent(model: content) { result in
                switch result {
                case .success(()):
                    print("Deleted \(content.originalTitle ?? content.originalName ?? "") from database")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            contentItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let content = contentItems[indexPath.row]
        guard let contentName = content.originalTitle ?? content.originalName else {
            return
        }
        
        APIManager.shared.getMovie(for: contentName + " trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                let viewModel = ContentPreviewViewModel(
                    title: contentName,
                    overview: self?.contentItems[indexPath.row].overview ?? "",
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
