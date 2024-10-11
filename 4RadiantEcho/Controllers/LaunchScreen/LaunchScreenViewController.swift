import SnapKit
import UIKit

final class LaunchScreenViewController: UIViewController {
    private let loadingLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var stackView = UIStackView()

    private let mainImageView = UIImageView()
    var isIdea: Bool

    init(isIdea: Bool) {
        self.isIdea = isIdea
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#225CEE")
        mainImageView.isHidden = false

        if isIdea {
            mainImageView.image = R.image.launch_idea_image()
        } else {
            mainImageView.image = R.image.launch_main_image()
        }

        loadingLabel.do { make in
            make.textColor = .white
            make.textAlignment = .center
            make.font = UIFont.systemFont(ofSize: 17)
        }

        activityIndicator.do { make in
            make.hidesWhenStopped = true
            make.color = .white
        }

        stackView.do { make in
            make.axis = .horizontal
            make.spacing = 8
            make.alignment = .center
            make.translatesAutoresizingMaskIntoConstraints = false
        }

        stackView.addArrangedSubviews([activityIndicator, loadingLabel])
        view.addSubviews(stackView, mainImageView)

        mainImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-65)
            make.height.equalTo(30)
        }

        activityIndicator.snp.makeConstraints { make in
            make.width.equalTo(22)
            make.height.equalTo(22)
        }

        activityIndicator.startAnimating()

        var currentPercentage = 0
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            currentPercentage += 1
            self.loadingLabel.text = "\(currentPercentage)%"
            if currentPercentage >= 100 {
                timer.invalidate()
            }
        }
    }
}
