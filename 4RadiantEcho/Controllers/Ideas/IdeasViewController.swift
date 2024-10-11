import SnapKit
import UIKit

final class IdeasViewController: UIViewController {
    private let ideasLabel = UILabel()
    private let createIdeaView = CreateIdeaView()
    private let ideasCountView = IdeasCountView()
    private let addCategoryView = AddCategoryView()
    private let categoryPlaceView = CategoryPlaceView()

    var category: [CategoryModel] = [] {
        didSet {
            saveCategory(category)
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)

        let configuration = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let backButtonImage = UIImage(systemName: "chevron.left", withConfiguration: configuration)?
            .withTintColor(UIColor(hex: "#225CEE"), renderingMode: .alwaysOriginal)

        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(didTapCancel))
        navigationItem.leftBarButtonItem = backButton

        view.backgroundColor = UIColor(hex: "#070A13")
        
        drawself()
        category = loadCategory()
        updateIdeasCount()
        addCategoryView.delegate = self
    }

    private func drawself() {
        ideasLabel.do { make in
            make.text = L.ideasMeetings()
            make.font = .systemFont(ofSize: 34, weight: .bold)
            make.textColor = .white
        }
        
        view.addSubviews(
            ideasLabel, createIdeaView, ideasCountView, addCategoryView, categoryPlaceView, collectionView
        )
        
        ideasLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(3)
        }
        
        createIdeaView.snp.makeConstraints { make in
            make.top.equalTo(ideasLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(ideasCountView.snp.leading).offset(-8)
            make.height.equalTo(102)
        }
        
        ideasCountView.snp.makeConstraints { make in
            make.top.equalTo(ideasLabel.snp.bottom).offset(24)
            make.trailing.equalToSuperview().inset(16)
            make.leading.equalTo(createIdeaView.snp.trailing).offset(8)
            make.size.equalTo(102)
        }
        
        addCategoryView.snp.makeConstraints { make in
            make.top.equalTo(createIdeaView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(categoryPlaceView.snp.leading).offset(-8)
            make.width.equalToSuperview().dividedBy(2).offset(-20)
            make.height.equalTo(130)
        }
        
        categoryPlaceView.snp.makeConstraints { make in
            make.top.equalTo(createIdeaView.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(addCategoryView.snp.trailing).offset(8)
            make.width.equalTo(addCategoryView.snp.width)
            make.height.equalTo(addCategoryView.snp.height)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(addCategoryView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func updateIdeasCount() {
        let totalCount = category.count
        ideasCountView.updateFirstLabel(with: totalCount)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Data Persistence Methods
    private func loadCategory() -> [CategoryModel] {
        return CategoryDataManager.shared.loadCategories()
    }

    private func saveCategory(_ models: [CategoryModel]) {
        CategoryDataManager.shared.saveCategories(models)
    }
}

// MARK: - AddCategoryViewDelegate
extension IdeasViewController: AddCategoryViewDelegate {
    func didTapAddCategory() {
        let alertController = UIAlertController(title: L.addCategory(), message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = L.name()
        }
        
        let cancelAction = UIAlertAction(title: L.cancel(), style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: L.add(), style: .default) { _ in
            guard let categoryName = alertController.textFields?[0].text, !categoryName.isEmpty else { return }
            let newCategory = CategoryModel(id: UUID(), name: categoryName, ideas: [])
            self.category.append(newCategory)
            self.collectionView.reloadData()
            self.updateIdeasCount()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - CategoryCellDelegate
extension IdeasViewController: CategoryCellDelegate {
    func didTapButton(with category: CategoryModel) {
        let categoryProfileVC = CategoryProfileViewController()
        categoryProfileVC.category = category
        categoryProfileVC.categoryId = category.id
        categoryProfileVC.delegate = self
        
        let navController = UINavigationController(rootViewController: categoryProfileVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - CategoryProfileDelegate
extension IdeasViewController: CategoryProfileDelegate {
    func didDeleteCategory(withId id: UUID) {
        if let index = category.firstIndex(where: { $0.id == id }) {
            category.remove(at: index)
            collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension IdeasViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (category.count + 1) / 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let index1 = section * 2
        let index2 = index1 + 1
        
        if index2 < category.count {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            fatalError("Unable to dequeue CategoryCell")
        }
        
        let categoryIndex = indexPath.section * 2 + indexPath.item
        if categoryIndex < category.count {
            let categoryItem = category[categoryIndex]
            cell.delegate = self
            cell.configure(with: categoryItem)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2) - 20
        let height: CGFloat = 130
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
    }
}
