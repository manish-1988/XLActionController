//  Twitter.swift
//  Twitter ( https://github.com/xmartlabs/XLActionController )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

#if XLACTIONCONTROLLER_EXAMPLE
import XLActionController
#endif

public class TwitterCell: ActionCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    func colorWithHexString(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: NSScanner = NSScanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "#")
        // Scan hex value
        scanner.scanHexInt(&hexInt)
        return hexInt
    }
    func initialize() {

        backgroundColor = colorWithHexString("#FDC50A")
        actionImageView?.clipsToBounds = true
        actionImageView?.layer.cornerRadius = 5.0
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        selectedBackgroundView = backgroundView
    }
}

public class TwitterActionControllerHeader: UICollectionReusableView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        label.backgroundColor = .whiteColor()
        label.font = UIFont.boldSystemFontOfSize(17)
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .lightGrayColor()
        return bottomLine
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellowColor()
        addSubview(label)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label]))
        addSubview(bottomLine)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[line(1)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["line": bottomLine]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[line]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["line": bottomLine]))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


public class TwitterActionController: ActionController<TwitterCell, ActionData, TwitterActionControllerHeader, String, UICollectionReusableView, Void> {
    public var cellColor : UIColor!
    public var headerColor : UIColor!
    public var fontNameSubTitle : UIFont!
    public var fontNameDetail : UIFont!

    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        settings.animation.present.duration = 0.6
        settings.animation.dismiss.duration = 0.6
        cellSpec = CellSpec.nibFile(nibName: "TwitterCell", bundle: Bundle(for: TwitterCell.self), height: { _ in 56 })
        headerSpec = .cellClass(height: { _ -> CGFloat in return 45 })
        
        
        onConfigureHeader = { header, title in
            header.label.text = title
            if self.headerColor != nil
            {
                header.backgroundColor = self.headerColor
            }
            
        }
        onConfigureCellForAction = { [weak self] cell, action, indexPath in
            if self?.cellColor != nil
            {
                cell.backgroundColor = self?.cellColor
            }
            cell.setup(action.data?.title, detail: action.data?.subtitle, image: action.data?.image)
            cell.separatorView?.isHidden = indexPath.item == (self?.collectionView.numberOfItems(inSection: indexPath.section))! - 1
            cell.alpha = action.enabled ? 1.0 : 0.5
            
            if self?.fontNameSubTitle != nil
            {
                cell.actionTitleLabel?.font = self?.fontNameSubTitle
            }
            
            if self?.fontNameDetail != nil
            {
                cell.actionDetailLabel?.font = self?.fontNameDetail
            }
            
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.clipsToBounds = false
        let hideBottomSpaceView: UIView = {
            let hideBottomSpaceView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: contentHeight + 20))
            hideBottomSpaceView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            hideBottomSpaceView.backgroundColor = .white
            return hideBottomSpaceView
        }()
        collectionView.addSubview(hideBottomSpaceView)
        collectionView.sendSubview(toBack: hideBottomSpaceView)
        
    }
    
    override open func dismissView(_ presentedView: UIView, presentingView: UIView, animationDuration: Double, completion: ((_ completed: Bool) -> Void)?) {
        onWillDismissView()
        let animationSettings = settings.animation.dismiss
        let upTime = 0.1
        UIView.animate(withDuration: upTime, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.collectionView.frame.origin.y -= 10
            }, completion: { [weak self] (completed) -> Void in
                UIView.animate(withDuration: animationDuration - upTime,
                               delay: 0,
                               usingSpringWithDamping: animationSettings.damping,
                               initialSpringVelocity: animationSettings.springVelocity,
                               options: UIViewAnimationOptions.curveEaseIn,
                               animations: { [weak self] in
                                presentingView.transform = CGAffineTransform.identity
                                self?.performCustomDismissingAnimation(presentedView, presentingView: presentingView)
                    },
                               completion: { [weak self] finished in
                                self?.onDidDismissView()
                                completion?(finished)
                    })
            })
    }
}
