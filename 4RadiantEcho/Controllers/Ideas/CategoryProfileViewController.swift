import UIKit

protocol CategoryProfileDelegate: AnyObject {
    func didDeleteCategory(withId id: UUID)
}

class CategoryProfileViewController: UIViewController {
    private let titleLabel = UILabel()
    private let deleteButton = OnboardingButton()
    private let noMeetingsView = NoMeetingsView()
    
    var meeting: MeetingModel?
    
    var categoryId: UUID?
    var category: CategoryModel?
    var ideas: [IdeasModel] = []
    
    var participants: [ParticipantModel] = []
    private var newMeetingsVC: NewMeetingViewController?
    weak var delegate: CategoryProfileDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(IdeaCell.self, forCellWithReuseIdentifier: IdeaCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#070A13")
        setupNavigationBar()
        setupUI()
        setupConstraints()
        
        if let category = category {
            ideas = category.ideas ?? []
            collectionView.reloadData()
        }
        
        configure(with: category)
        updateViewVisibility()
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

        let editButton = UIBarButtonItem(title: L.edit(), style: .plain, target: self, action: #selector(editButtonTapped))
         editButton.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)

        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupUI() {
        titleLabel.do { make in
            make.font = .systemFont(ofSize: 34, weight: .bold)
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
            titleLabel, noMeetingsView,
            collectionView, deleteButton
        )
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(3)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(41)
        }
        
        noMeetingsView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(178)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    private func updateViewVisibility() {
        let isIdeasEmpty = ideas.isEmpty
        noMeetingsView.isHidden = !(isIdeasEmpty)
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func editButtonTapped() {
        guard let category = category else { return }
        
        let newMeetingsVC = NewIdeaViewController(isEditing: false)
        newMeetingsVC.delegate = self
        newMeetingsVC.currentCategory = category
        newMeetingsVC.categoryId = category.id

        if #available(iOS 15.0, *) {
            if let sheet = newMeetingsVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = .large
            }
        } else {
            newMeetingsVC.modalPresentationStyle = .fullScreen
            newMeetingsVC.modalTransitionStyle = .coverVertical
        }

        present(newMeetingsVC, animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped() {
        guard let categoryId = categoryId else {
            print("Error: categoryId is nil")
            return
        }
        
        let alert = UIAlertController(title: "Delete Category", message: "Are you sure you want to delete this category?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            CategoryDataManager.shared.deleteCategory(withId: categoryId)
            self.delegate?.didDeleteCategory(withId: categoryId)
            self.dismiss(animated: true, completion: nil)
        }
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(closeAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func configure(with category: CategoryModel?) {
        guard let category = category else { return }
        
        titleLabel.text = category.name
        ideas = category.ideas ?? []
        collectionView.reloadData()
    }
}

// MARK: - NewIdeaDelegate
extension CategoryProfileViewController: NewIdeaDelegate {
    func didAddIdea(_ idea: IdeasModel) {
        if ideas == nil { ideas = [] }
        ideas.append(idea)
        collectionView.reloadData()
        updateViewVisibility()
    }

    
    func didUpdateIdea(_ idea: IdeasModel) {
        guard let categoryId = categoryId else { return }
        
        if let index = ideas.firstIndex(where: { $0.id == idea.id }) {
            ideas[index] = idea
            
            CategoryDataManager.shared.updateIdea(inCategoryId: categoryId, ideaId: idea.id, title: idea.title, description: idea.description)
            
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            updateViewVisibility()
        } else {
        }
    }
}

// MARK: - IdeaCellDelegate
extension CategoryProfileViewController: IdeaCellDelegate {
    func didTapEdit(with idea: IdeasModel) {
        guard let category = category else { return }
        
        let newMeetingsVC = NewIdeaViewController(isEditing: true)
        newMeetingsVC.delegate = self
        newMeetingsVC.currentCategory = category
        newMeetingsVC.categoryId = category.id
        newMeetingsVC.currentIdea = idea

        if #available(iOS 15.0, *) {
            if let sheet = newMeetingsVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = .large
            }
        } else {
            newMeetingsVC.modalPresentationStyle = .fullScreen
            newMeetingsVC.modalTransitionStyle = .coverVertical
        }

        present(newMeetingsVC, animated: true, completion: nil)
    }
    
    func didTapOpen(with idea: IdeasModel) {
        let ideaProfileVC = IdeaProfileViewController()
        ideaProfileVC.idea = idea
        ideaProfileVC.ideaId = idea.id
        ideaProfileVC.categoryId = categoryId
        ideaProfileVC.delegate = self
        
        let navController = UINavigationController(rootViewController: ideaProfileVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - IdeaProfileDelegate
extension CategoryProfileViewController: IdeaProfileDelegate {
    func didDeleteIdea(withId id: UUID) {
        guard let categoryId = categoryId else { return }
        guard let index = ideas.firstIndex(where: { $0.id == id }) else { return }
        ideas.remove(at: index)
        CategoryDataManager.shared.removeIdea(fromCategoryId: categoryId, ideaId: id)
        if ideas.isEmpty {
            collectionView.reloadData()
            updateViewVisibility()
        } else {
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }, completion: { _ in
                self.updateViewVisibility()
            })
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CategoryProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ideas.isEmpty ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ideas.isEmpty ? 0 : ideas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdeaCell.reuseIdentifier, for: indexPath) as? IdeaCell else {
            fatalError("Unable to dequeue NewTopicCell")
        }

        let idea = ideas[indexPath.item]
        cell.delegate = self
        cell.configure(with: idea)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 138
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 12, right: 10)
    }
}
