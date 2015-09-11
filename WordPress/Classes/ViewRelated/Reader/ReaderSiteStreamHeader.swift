import Foundation

@objc public class ReaderSiteStreamHeader: UIView, ReaderStreamHeader
{
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var followButton: PostMetaButton!
    @IBOutlet private weak var descriptionView: UIView!
    @IBOutlet private weak var followCountLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var followCountBottomConstraint: NSLayoutConstraint!
    public var delegate: ReaderStreamHeaderDelegate?
    private var defaultBlavatar = "blavatar-default"

    // MARK: - Lifecycle Methods

    public override func awakeFromNib() {
        super.awakeFromNib()

        applyStyles()
    }

    func applyStyles() {
        backgroundColor = WPStyleGuide.greyLighten30()
        WPStyleGuide.applyReaderStreamHeaderTitleStyle(titleLabel)
        WPStyleGuide.applyReaderStreamHeaderDetailStyle(detailLabel)
        WPStyleGuide.applyReaderSiteStreamDescriptionStyle(descriptionLabel)
        WPStyleGuide.applyReaderSiteStreamCountStyle(followCountLabel)
    }

    public override func sizeThatFits(size: CGSize) -> CGSize {
        // Vertical and horizontal margins
        let hMargin = descriptionLabel.frame.minX
        let vMargin = descriptionLabel.frame.minY

        let innerWidth = size.width - (hMargin * 2)
        let adjustedSize = CGSize(width:innerWidth, height:CGFloat.max)
        var height = descriptionView.frame.minY
        height += vMargin
        height += descriptionLabel.sizeThatFits(adjustedSize).height
        height += descriptionBottomConstraint.constant
        height += followCountLabel.sizeThatFits(adjustedSize).height
        height += followCountBottomConstraint.constant;

        return CGSize(width: size.width, height: height)
    }


   // MARK: - Configuration

    public func configureHeader(topic: ReaderAbstractTopic) {
        assert(topic.isKindOfClass(ReaderSiteTopic), "Topic must be a site topic")

        let siteTopic = topic as! ReaderSiteTopic

        avatarImageView.setImageWithURL(NSURL(), placeholderImage: UIImage(named: defaultBlavatar))
        titleLabel.text = siteTopic.title
        detailLabel.text = NSURL(string: siteTopic.siteURL)?.host
        if siteTopic.following {
            WPStyleGuide.applyReaderStreamHeaderFollowingStyle(followButton)
        } else {
            WPStyleGuide.applyReaderStreamHeaderNotFollowingStyle(followButton)
        }

        descriptionLabel.attributedText = attributedSiteDescriptionForTopic(siteTopic)

        if descriptionLabel.attributedText?.length > 0 {
            // Bottom and top margins should match.
            descriptionBottomConstraint.constant = descriptionLabel.frame.minY
        } else {
            descriptionBottomConstraint.constant = 0
        }


        followCountLabel.text = formattedFollowerCountForTopic(siteTopic)
    }

    func formattedFollowerCountForTopic(topic:ReaderSiteTopic) -> String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.groupingSeparator = NSLocale.currentLocale().objectForKey(NSLocaleGroupingSeparator) as! String
        numberFormatter.numberStyle = .DecimalStyle
        let count = numberFormatter.stringFromNumber(topic.subscriberCount)
        let pattern = NSLocalizedString("%@ followers", comment: "The number of followers of a site. The '%@' is a placeholder for the numeric value. Example: `1000 followers`")
        let str = String(format: pattern, count!)
        return str
    }

    func attributedSiteDescriptionForTopic(topic:ReaderSiteTopic) -> NSAttributedString {
        let attributes = WPStyleGuide.readerStreamHeaderDescriptionAttributes() as! [String: AnyObject]
        return NSAttributedString(string: topic.siteDescription, attributes: attributes)
    }


    // MARK: - Actions

    @IBAction func didTapFollowButton(sender: UIButton) {
        delegate?.handleFollowActionForHeader(self)
    }
}
