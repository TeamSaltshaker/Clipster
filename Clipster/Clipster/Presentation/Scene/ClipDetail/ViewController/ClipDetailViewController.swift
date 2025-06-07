import UIKit

final class ClipDetailViewController: UIViewController {
    private let clipDetailView = ClipDetailView()

    override func loadView() {
        view = clipDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension ClipDetailViewController {
    func configure() {
        setAttributes()
    }

    func setAttributes() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: clipDetailView.backButton)

        let deleteButton = UIBarButtonItem(customView: clipDetailView.deleteButton)
        let editButton = UIBarButtonItem(customView: clipDetailView.editButton)
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
    }
}
