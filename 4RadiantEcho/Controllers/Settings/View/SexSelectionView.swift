import SnapKit
import UIKit

protocol SexSelectionDelegate: AnyObject {
    func didSelectSex(selectedIndices: [Int])
}

final class SexSelectionView: UIControl {
    private let mainContainerView = UIView()

    private let manView = UIView()
    private let womanView = UIView()
    private let manImageView = UIImageView()
    private let womanImageView = UIImageView()
    private let manLabel = UILabel()
    private let womanLabel = UILabel()

    private let stackView = UIStackView()

    private var selectedIndices: [Int] = [] {
        didSet {
            updateViewsAppearance()
        }
    }

    private var views: [UIView] = []
    weak var delegate: SexSelectionDelegate?

    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [manLabel, womanLabel].forEach { label in
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.textColor = .white.withAlphaComponent(0.7)
            label.textAlignment = .center
        }

        [manView, womanView].forEach { view in
            view.backgroundColor = .clear
        }

        manLabel.text = L.man()
        womanLabel.text = L.woman()
        manImageView.image = R.image.profile_empty_icon()
        womanImageView.image = R.image.profile_empty_icon()

        stackView.do { make in
            make.axis = .horizontal
            make.spacing = 0
            make.distribution = .fillProportionally
            make.alignment = .leading
        }

        manView.addSubviews(manImageView, manLabel)
        womanView.addSubviews(womanImageView, womanLabel)

        stackView.addArrangedSubviews([manView, womanView])
        addSubviews(stackView)

        let tapGestureRecognizers = [
            UITapGestureRecognizer(target: self, action: #selector(dayTapped(_:))),
            UITapGestureRecognizer(target: self, action: #selector(dayTapped(_:)))
        ]

        manView.addGestureRecognizer(tapGestureRecognizers[0])
        womanView.addGestureRecognizer(tapGestureRecognizers[1])

        views = [manView, womanView]
        updateViewsAppearance()
    }

    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        [manImageView, womanImageView].forEach { imageView in
            imageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview()
            }
        }

        manLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(manImageView.snp.trailing).offset(28)
        }

        womanLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(womanImageView.snp.trailing).offset(28)
        }

        [manView, womanView].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(44)
                make.width.equalToSuperview().dividedBy(2)
            }
        }
    }

    @objc private func dayTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        guard let index = views.firstIndex(of: tappedView) else { return }

        selectedIndices = [index]

        updateViewsAppearance()
        delegate?.didSelectSex(selectedIndices: selectedIndices)
    }

    private func updateViewsAppearance() {
        for (index, view) in views.enumerated() {
            if selectedIndices.contains(index) {
                if index == 0 {
                    manImageView.image = R.image.profile_fill_icon()
                } else {
                    womanImageView.image = R.image.profile_fill_icon()
                }
            } else {
                if index == 0 {
                    manImageView.image = R.image.profile_empty_icon()
                } else {
                    womanImageView.image = R.image.profile_empty_icon()
                }
            }
        }
    }

    func configure(selectedIndices: [Int]) {
        self.selectedIndices = selectedIndices
    }

    func configureForCell(selectedIndices: [Int]) {
        self.selectedIndices = selectedIndices
        updateViewsAppearance()
        isUserInteractionEnabled = true
    }
}
