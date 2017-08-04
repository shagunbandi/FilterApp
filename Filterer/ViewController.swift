//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

struct Filter {
    var rgbImage: RGBAImage
    var uiImage: UIImage
    var avgRed: Int! = nil
    var avgGreen: Int! = nil
    var avgBlue: Int! = nil
    
    init(uiImage: UIImage){
        self.rgbImage = RGBAImage(image: uiImage)!
        self.uiImage = uiImage
        let AvgValues = self.getAvgValues()
        self.avgRed = AvgValues.0
        self.avgGreen = AvgValues.1
        self.avgBlue = AvgValues.2
    }
    
    func getAvgValues() -> (Int, Int, Int){
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        // Looping through each pixel
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width + x
                var pixel = rgbImage.pixels[index]
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        let count = rgbImage.width*rgbImage.height
        let avgRed = totalRed/count //118
        let avgGreen = totalGreen/count //98
        let avgBlue = totalBlue/count // 83
        return (avgRed, avgGreen, avgBlue)
    }
    
    func warmer(intensity: Int) -> RGBAImage {
        var newImage: RGBAImage = rgbImage
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width+x
                var pixel = rgbImage.pixels[index]
                let redDiff = Int(pixel.red) - avgRed
                if (redDiff > 0){
                    pixel.red = UInt8(max(0, min(255, avgRed + redDiff * intensity / 100)))
                    pixel.blue = UInt8(max(0, min(255, avgBlue + 100 * redDiff / intensity)))
                    newImage.pixels[index] = pixel
                }
            }
        }
        return newImage
    }
    
    func cooler(intensity: Int) -> RGBAImage {
        var newImage: RGBAImage = rgbImage
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width+x
                var pixel = rgbImage.pixels[index]
                let redDiff = Int(pixel.red) - avgRed
                if (redDiff > 0){
                    pixel.red = UInt8(max(0, min(255, avgRed + 100 * redDiff / intensity)))
                    pixel.blue = UInt8(max(0, min(255, avgBlue + redDiff * intensity / 100)))
                    newImage.pixels[index] = pixel
                }
            }
        }
        return newImage
    }
    
    func brightness(intensity: Int) -> RGBAImage {
        func brighter(intensity: Int) -> RGBAImage {
            var newImage: RGBAImage = rgbImage
            for y in 0..<rgbImage.height{
                for x in 0..<rgbImage.width{
                    let index = y*rgbImage.width+x
                    var pixel = rgbImage.pixels[index]
                    
                    let red = Double(pixel.red) + Double(255 - Double(pixel.red)) * Double(intensity) / 100.0
                    let blue = Double(pixel.blue) + Double(255 - Double(pixel.blue)) * Double(intensity) / 100.0
                    let green = Double(pixel.green) + Double(255 - Double(pixel.green)) * Double(intensity) / 100.0
                    
                    pixel.red = UInt8(max(0, min(255, red)))
                    pixel.blue = UInt8(max(0, min(255, blue)))
                    pixel.green = UInt8(max(0, min(255, green)))
                    newImage.pixels[index] = pixel
                }
            }
            return newImage
        }
        
        func darker(intensity: Int) -> RGBAImage {
            var newImage: RGBAImage = rgbImage
            for y in 0..<rgbImage.height{
                for x in 0..<rgbImage.width{
                    let index = y*rgbImage.width+x
                    var pixel = rgbImage.pixels[index]
                    
                    // + because already intensity is negative
                    let red = Double(pixel.red) + Double(pixel.red) * Double(intensity) / 100.0
                    let blue = Double(pixel.blue) + Double(pixel.blue) * Double(intensity) / 100.0
                    let green = Double(pixel.green) + Double(pixel.green) * Double(intensity) / 100.0
                    
                    pixel.red = UInt8(max(0, min(255, red)))
                    pixel.blue = UInt8(max(0, min(255, blue)))
                    pixel.green = UInt8(max(0, min(255, green)))
                    newImage.pixels[index] = pixel
                }
            }
            return newImage
        }
        if (intensity>0){
            return brighter(intensity)
        }
        else{
            return darker(intensity)
        }
    }
    
    func grayscale() -> RGBAImage {
        var newImage: RGBAImage = rgbImage
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width+x
                var pixel = rgbImage.pixels[index]
                
                let grayImage = 0.299 * Double(pixel.red) + 0.587 * Double(pixel.green) + 0.114 * Double(pixel.blue)
                let grayImage1 = round(grayImage)
                
                pixel.red = UInt8(grayImage1)
                pixel.blue = UInt8(grayImage1)
                pixel.green = UInt8(grayImage1)
                
                newImage.pixels[index] = pixel
            }
        }
        return newImage
    }
    
    func inverse() -> RGBAImage {
        var newImage: RGBAImage = rgbImage
        for y in 0..<rgbImage.height{
            for x in 0..<rgbImage.width{
                let index = y*rgbImage.width+x
                var pixel = rgbImage.pixels[index]
                
                pixel.red = UInt8(max(0, 255 - Int(pixel.red)))
                pixel.blue = UInt8(max(0, 255 - Int(pixel.blue)))
                pixel.green = UInt8(max(0, 255 - Int(pixel.green)))
                newImage.pixels[index] = pixel
            }
        }
        return newImage
    }
    
    
    
    mutating func process(allFilters :[String]) {
        for filter in allFilters{
            switch filter.lowercaseString {
            case "warm":
                self.rgbImage = warmer(2)
            case "cool":
                self.rgbImage = cooler(2)
            case "bright":
                self.rgbImage = brightness(50)
            case "dark":
                self.rgbImage = brightness(-50)
            case "grayscale":
                self.rgbImage = grayscale()
            case "inverse":
                self.rgbImage = inverse()
            default:
                print("wrong option chosed")
            }
        }
        self.uiImage = rgbImage.toUIImage()!
    }
    
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate { 

    let imageDefault = UIImage(named: "scenery1")
    var newImage = UIImage(named: "scenery1")
    var filteredImage = UIImage(named: "scenery1")
    
    @IBOutlet var imageView: UIImageView!
    let recognizer = UITapGestureRecognizer()
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var newPhoto: UIButton!
    @IBOutlet weak var sharePhoto: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var filterStack: UIStackView!
    
    @IBOutlet weak var cooler: UIButton!
    @IBOutlet weak var warmer: UIButton!
    @IBOutlet weak var brighter: UIButton!
    @IBOutlet weak var darker: UIButton!
    @IBOutlet weak var greyscale: UIButton!
    @IBOutlet weak var inverse: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet var editMenu: UIView!
    @IBOutlet weak var orignalLabel: UILabel!
    
    @IBOutlet weak var label: UILabel!
    var intensity = 50
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var selectedButton: UIButton!
    
    @IBAction func onSlider(sender: UISlider) {
        intensity = Int(sender.value)
        label.text = "Intensity: " + String(intensity)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        editMenu.translatesAutoresizingMaskIntoConstraints = false
        selectedButton = nil
        
        setImages(newImage!)
        setHighlightColour()
        
        editButton.hidden = true
        orignalLabel.hidden = true
        
        resetButtons()
        
    }
    
    func setContentWidth(uiImage: UIImage) {
        let width = uiImage.size.width
        let height = uiImage.size.height
        var contendWidth = 6*(width/height*100.0)
        if contendWidth < self.secondaryMenu.frame.size.width{
            contendWidth = self.secondaryMenu.frame.size.width
        }
        scrollView.contentSize.width = contendWidth
        widthConstraint.constant = contendWidth
    }
    
    func centeButtonImage(button: UIButton) {
        button.contentMode = .Bottom
        button.imageView?.contentMode = .ScaleAspectFit
    }
    
    func setHighlightColour() {
        cooler.layer.borderColor = UIColor.blueColor().CGColor
        warmer.layer.borderColor = UIColor.blueColor().CGColor
        greyscale.layer.borderColor = UIColor.blueColor().CGColor
        inverse.layer.borderColor = UIColor.blueColor().CGColor
        brighter.layer.borderColor = UIColor.blueColor().CGColor
        darker.layer.borderColor = UIColor.blueColor().CGColor
    }
    
    func compareButtonOnOff() {
        if selectedButton != nil{
            compareButton.enabled = true
            onFilterPreviousFilter(selectedButton) //When cancel previous filter returns
        }
        else{
            compareButton.enabled = false
        }
    }
    
    func setImages(uiImage: UIImage){
        
        imageView.image = uiImage
        let filterObj = Filter(uiImage: uiImage)
        cooler.setImage(filterObj.cooler(max(100, intensity*4)).toUIImage(), forState: UIControlState.Normal)
        warmer.setImage(filterObj.warmer(max(100, intensity*4)).toUIImage(), forState: UIControlState.Normal)
        greyscale.setImage(filterObj.grayscale().toUIImage(), forState: UIControlState.Normal)
        inverse.setImage(filterObj.inverse().toUIImage(), forState: UIControlState.Normal)
        brighter.setImage(filterObj.brightness(intensity).toUIImage(), forState: UIControlState.Normal)
        darker.setImage(filterObj.brightness(-intensity).toUIImage(), forState: UIControlState.Normal)
        compareButtonOnOff()
        setContentWidth(uiImage)
    }
    
    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            self.compareButtonOnOff()
        }))
        self.presentViewController(actionSheet, animated: true, completion: nil)
        resetButtons()
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
    
        presentViewController(cameraPicker, animated: true, completion: nil)
        selectedButton = nil

    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
        selectedButton = nil

    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            newImage = image
            filteredImage = image
            selectedButton = nil
            setImages(newImage!)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
        resetButtons()
        if selectedButton != nil{
            onFilterPreviousFilter(selectedButton)
        }
    }
    
    @IBAction func onEdit(sender: UIButton) {
        if (sender.selected) {
            setImages(newImage!)
            hideEditMenu()
            sender.selected = false
            sender.setTitle("Edit", forState: .Normal)
            filterButton.enabled = true
            newPhoto.enabled = true
            sharePhoto.enabled = true
        } else {
            showEditMenu()
            sender.selected = true
            sender.setTitle("Done", forState: .Normal)
            filterButton.enabled = false
            newPhoto.enabled = false
            sharePhoto.enabled = false
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(100)

        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])

        view.layoutIfNeeded()

        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
        setContentWidth(newImage!)
    }
    
    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
    func showEditMenu() {
        view.addSubview(editMenu)
        
        let bottomConstraint = editMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = editMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = editMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = editMenu.heightAnchor.constraintEqualToConstant(60)
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        self.editMenu.alpha = 0
        self.secondaryMenu.alpha = 1
        UIView.animateWithDuration(0.4) {
            self.editMenu.alpha = 1
            self.secondaryMenu.alpha = 0
        }
    }
    
    func hideEditMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.editMenu.alpha = 0
            self.secondaryMenu.alpha = 1
        }) { completed in
            if completed == true {
                self.editMenu.removeFromSuperview()
            }
        }
    }
    
    func resetButtons() {
        compareButton.selected = false
        cooler.layer.borderWidth = 0
        warmer.layer.borderWidth = 0
        greyscale.layer.borderWidth = 0
        inverse.layer.borderWidth = 0
        brighter.layer.borderWidth = 0
        darker.layer.borderWidth = 0
        orignalLabel.hidden = true
        if selectedButton != nil{
            compareButton.enabled = true
        }
        else{
            compareButton.enabled = false
        }
    }
    
    @IBAction func onCompare(sender: UIButton) {
        if (sender.selected){
            let toImage = filteredImage
            changingAnimation(toImage!)
            sender.selected = false
            editButton.hidden = false
            orignalLabel.hidden = true
        }
        else {
            let toImage = newImage
            changingAnimation(toImage!)
            sender.selected = true
            editButton.hidden = true
            orignalLabel.hidden = false
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first!
        if touch.view == imageView {
            if selectedButton != nil{
                let toImage = newImage
                changingAnimation(toImage!, duration: 0.1)
                orignalLabel.hidden = false
                compareButton.selected = true
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first!
        if (touch.view == imageView) {
            let toImage = filteredImage
            changingAnimation(toImage!, duration: 0.1)
            orignalLabel.hidden = true
            compareButton.selected = false
        }
    }
    
    func changingAnimation(toImage: UIImage, duration: Double? = 0.4){
        UIView.transitionWithView(
            self.imageView,
            duration:duration!,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: {
                self.imageView.image = toImage
            },
            completion: nil
        )
    }
    
    func selectFilterImage(sender: UIButton) {
        filteredImage = imageView.image
        sender.layer.borderWidth = 3
    }
    
    @IBAction func onFilterCooler(sender: UIButton) {
        resetButtons()
        editButton.hidden = false
        let toImage: UIImage!
        toImage = sender.imageView?.image
        changingAnimation(toImage!)
        selectFilterImage(sender)
        selectedButton = sender
        compareButton.enabled = true
    }
    
    @IBAction func onFilterWarmer(sender: UIButton) {
        resetButtons()
        editButton.hidden = false
        let toImage: UIImage!
        toImage = sender.imageView?.image
        changingAnimation(toImage!)
        selectFilterImage(sender)
        selectedButton = sender
        compareButton.enabled = true
    }

    @IBAction func onFilterBrighter(sender: UIButton) {
        resetButtons()
        editButton.hidden = false
        let toImage: UIImage!
        toImage = sender.imageView?.image
        changingAnimation(toImage!)
        selectFilterImage(sender)
        selectedButton = sender
        compareButton.enabled = true
    }
    
    @IBAction func onFilterDarker(sender: UIButton) {
        resetButtons()
        editButton.hidden = false
        let toImage: UIImage!
        toImage = sender.imageView?.image
        changingAnimation(toImage!)
        selectFilterImage(sender)
        selectedButton = sender
        compareButton.enabled = true
    }
    
    @IBAction func onFilterGreyscale(sender: UIButton) {
        resetButtons()
        editButton.hidden = true
        let toImage = sender.imageView?.image
        changingAnimation(toImage!)
        selectFilterImage(sender)
        selectedButton = sender
        compareButton.enabled = true
    }
    
    @IBAction func onFilterInverse(sender: UIButton) {
        resetButtons()
        editButton.hidden = true
        let toImage = sender.imageView?.image
        changingAnimation(toImage!)
        selectFilterImage(sender)
        selectedButton = sender
        compareButton.enabled = true
    }
    
    func onFilterPreviousFilter(sender: UIButton){
        resetButtons()
        editButton.hidden = false
        let toImage = sender.imageView?.image
        changingAnimation(toImage!)
        compareButton.enabled = true
        selectFilterImage(sender)
    }
}

