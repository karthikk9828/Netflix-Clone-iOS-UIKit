
import UIKit

class ContentTableViewCell: UITableViewCell {

    static let identifier = "ContentTableViewCell"
    
    private let contentPosterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentPosterImageView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(playButton)
        
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentPosterImageView.frame = contentView.bounds
    }
    
    func applyConstraints() {
        let contentPosterImageViewConstraints = [
            contentPosterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentPosterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            contentPosterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            contentPosterImageView.widthAnchor.constraint(equalToConstant: 100),
        ]
        
        let contentLabelConstraints = [
            contentLabel.leadingAnchor.constraint(equalTo: contentPosterImageView.trailingAnchor, constant: 20),
            contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        let playButtonConstraints = [
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(contentPosterImageViewConstraints)
        NSLayoutConstraint.activate(contentLabelConstraints)
        NSLayoutConstraint.activate(playButtonConstraints)
    }
    
    public func configure(with contentViewModel: ContentViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(contentViewModel.posterUrl)") else { return }
        contentPosterImageView.sd_setImage(with: url, completed: nil)
        contentLabel.text = contentViewModel.contentName
    }
}
