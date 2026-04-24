
import UIKit

fileprivate let _leftImagePaddingDefault: CGFloat = 18
fileprivate let _RightImagePaddingDefault: CGFloat = 18

class AuthTextField: UITextField{
    override var text: String? {
        didSet {
            updateBorderBasedOnText()
        }
    }
    override var isEnabled: Bool {
        didSet {
            updateEnabledState()
        }
    }
    /// Info label that is shown for a user. This label will appear under the text field.
    /// You can use it to configure appearance.
    public private(set) lazy var infoLabel = UILabel()
    
    var errorText = ""
    var emptyErrorText = ""
    
    var hasErrorMessage: Bool = false {
        didSet {
            if hasErrorMessage {
                showError()
            } else {
                hideError()
            }
        }
    }
    
    /// Animation duration for showing and hiding the info label.
    @IBInspectable public var infoAnimationDuration: Double = 0.5
    
    /// Color of info text.
    var infoTextColor: UIColor = UIColor.red
    var infoFontSize: CGFloat = 12.0
    var imageView: UIImageView?
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = _leftImagePaddingDefault {
        didSet {
            updateView()
        }
    }
    @IBInspectable var rightPadding: CGFloat = _leftImagePaddingDefault {
        didSet {
            updateView()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
       initializeSetup()
       
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeSetup()
        
    }
    
    func updateView() {
        //crosButton.addTarget(self, action: #selector(crosButtonTapped), for: .touchUpInside)
        if #available(iOS 10, *) {
            // Disables the password autoFill accessory view.
            textContentType = UITextContentType(rawValue: "")
        }
        
        if let image = leftImage {
            leftViewMode = .always
            
            imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
            imageView?.image = image
            imageView?.contentMode = .scaleAspectFit
            imageView?.tintColor = UIColor.gray
            
            var width = leftPadding + 20
            
            if borderStyle == UITextField.BorderStyle.none || borderStyle == UITextField.BorderStyle.line {
                width = width + 12
            }
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
            view.addSubview(imageView!)
            
            leftView = view
            
        } else  if let  image = rightImage {
            
            rightViewMode = .always
            
            imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
            imageView?.image = image
            imageView?.contentMode = .scaleAspectFit
            imageView?.tintColor = UIColor.gray
            
            var width = rightPadding + 20
            
            if borderStyle == UITextField.BorderStyle.none || borderStyle == UITextField.BorderStyle.line {
                width = width + 12
            }
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
            view.addSubview(imageView!)
            
            rightView = view
        }
        else{
            leftViewMode = .never
        }
    }
    
    @objc func editingChanged() {
        guard isEnabled else { return }
        hideError(animated: true)
    }
    @objc func editingStart() {
        guard isEnabled else { return }
          layer.borderColor = UIColor(named: "customBlueColor")?.cgColor
          backgroundColor = .white
    }
    
    @objc func editingEnd() {
        guard isEnabled else { return }
        updateBorderBasedOnText()
    }
    
    
    
    private func updateBorderBasedOnText() {
        guard isEnabled else { return }
        
        if self.text?.isEmpty ?? true {
            layer.borderColor = UIColor(named: "customGreyColor")?.cgColor
            self.backgroundColor = UIColor(named: "customCardbg")
        } else {
            layer.borderColor = UIColor(named: "customBlueColor")?.cgColor
            self.backgroundColor = UIColor.white
        }
    }
    
    private func updateEnabledState() {
        if isEnabled {
            // Enabled state (existing look)
            updateBorderBasedOnText()
            alpha = 1.0
        } else {
            // Disabled state (different look)
            backgroundColor = UIColor(named: "customTFBorderColor") ?? UIColor.lightGray.withAlphaComponent(0.3)
            layer.borderColor = UIColor(named: "customGreyColor")?.cgColor
            alpha = 0.7
            resignFirstResponder()
        }
    }

    func setBorder() {
        
        layer.borderColor = UIColor(named: "customGreyColor")?.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
    }
    
    var padding: UIEdgeInsets {
        get {
            if leftImage != nil {
                return UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 18)
            }else if rightImage != nil {
                return UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 40)
            }
            return UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        }
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    /// Shows info label with/without animation.
    /// - Parameters:
    ///   - text: Custom text to show.
    ///   - animated: By default is `true`.
    public func showError(_ text: String, animated: Bool = true) {
        guard animated else {
            infoLabel.text = text
            return
        }
        
        UIView.transition(with: infoLabel, duration: infoAnimationDuration, options: [.transitionCrossDissolve], animations: {
            self.infoLabel.alpha = 1
            self.infoLabel.text = text
        })
    }
    
    public func showError() {
        UIView.transition(with: infoLabel, duration: infoAnimationDuration, options: [.transitionCrossDissolve], animations: {
            self.infoLabel.alpha = 1
            self.infoLabel.text = (self.text?.isEmpty ?? true) ? self.emptyErrorText : self.errorText
        })
    }
    
    /// Hides the info label with animation or not.
    /// - Parameter animated: By default is `true`.
    public func hideError(animated: Bool = true) {
        guard animated else {
            infoLabel.alpha = 0
            return
        }
        
        UIView.animate(withDuration: infoAnimationDuration) {
            self.infoLabel.alpha = 0
        }
    }
    
    private func initializeSetup() {
        plugInfoLabel()
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addTarget(self, action: #selector(editingStart), for: .editingDidBegin)
        addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        //setBorder()
        if self.text == ""{
            self.backgroundColor = UIColor(named: "customBGColor")
            layer.borderColor = UIColor(named: "customGreyColor")?.cgColor
            layer.borderWidth = 1
            layer.cornerRadius = 10
        }else{
            layer.borderColor = UIColor(named: "customBlueColor")?.cgColor
            self.backgroundColor = UIColor.white
           
        }
        updateEnabledState()
       // self.backgroundColor = UIColor(named: "TFbackgroudColor")
    }
    
    private func plugInfoLabel() {
        guard infoLabel.superview == nil else {
            return
        }
        
        infoLabel.numberOfLines = 0
        infoLabel.textColor = infoTextColor
        infoLabel.font = UIFont.systemFont(ofSize: infoFontSize, weight: UIFont.Weight.regular)
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            infoLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: 1)
            ])
    }
     override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
           if action == #selector(UIResponderStandardEditActions.paste(_:)) {
               return false
           }
           return super.canPerformAction(action, withSender: sender)
       }
    
    var onEmpty: EmptyEvent?


}

