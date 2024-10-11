import UIKit

protocol IdeaProfileDelegate: AnyObject {
    func didDeleteIdea(withId id: UUID)
}

class IdeaProfileViewController: UIViewController {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let deleteButton = OnboardingButton()
    
    var idea: IdeasModel?
    var ideaId: UUID?
    var categoryId: UUID?
    var category: CategoryModel?

    weak var delegate: IdeaProfileDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#070A13")
        setupNavigationBar()
        setupUI()
        setupConstraints()
        
        configure(with: idea)
    }

    private func setupNavigationBar() {
        let backButton = UIButton(type: .system)
        backButton.setTitle(L.back(), for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)

        let chevronImage = UIImage(systemName: "chevron.left")
        backButton.setImage(chevronImage, for: .normal)
        
        backButton.tintColor = .systemBlue
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func setupUI() {
        titleLabel.do { make in
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textColor = .white
            make.textAlignment = .left
            make.numberOfLines = 0
        }        
        
        descriptionLabel.do { make in
            make.font = .systemFont(ofSize: 17)
            make.textColor = .white
            make.textAlignment = .left
            make.numberOfLines = 0
        }

        deleteButton.do { make in
            make.setBackgroundColor(.white.withAlphaComponent(0.05))
            make.setTitle(to: L.delete())
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteButtonTapped))
            make.addGestureRecognizer(tapGesture)
        }
        
        view.addSubviews(
            titleLabel, descriptionLabel ,deleteButton
        )
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(3)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(41)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped() {
        guard let ideaId = ideaId, let categoryId = categoryId else {
            print("Error: ideaId or categoryId is nil")
            return
        }

        let alert = UIAlertController(title: "Delete Idea", message: "Are you sure you want to delete this idea?", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            CategoryDataManager.shared.removeIdea(fromCategoryId: categoryId, ideaId: ideaId)
            self.delegate?.didDeleteIdea(withId: ideaId)
            self.dismiss(animated: true, completion: nil)
        }

        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(closeAction)

        present(alert, animated: true, completion: nil)
    }
    
    private func configure(with idea: IdeasModel?) {
        guard let idea = idea else { return }
        
        titleLabel.text = idea.title
        descriptionLabel.text = idea.description
    }
}
