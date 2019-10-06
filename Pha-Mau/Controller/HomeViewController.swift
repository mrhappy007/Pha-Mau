//
//  ViewController.swift
//  Pha-Mau
//
//  Created by Hieu Nghia on 3/21/19.
//  Copyright © 2019 Hieu Nghia. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var reviewColorView: UIView!
    @IBOutlet weak var colorsSegmented: UISegmentedControl!
    @IBOutlet weak var colorNameTextField: UITextField!
    @IBOutlet weak var colorCodeTextfield: UITextField!

    var colorManager = ColorManager.context

    var mainColor = ColorModel()

    var pageColorViewController: ColorPageViewController? {
        didSet {
            pageColorViewController?.pageColorDelegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        colorManager.loadContext()
        pageColorViewController?.mainColorUpdate(color: UIColor(hex: mainColor.hexCode))
        colorNameTextField.text = mainColor.name
        updateUI(newColor: mainColor)
    }

    private func updateUI(newColor: ColorModel) {
        reviewColorView.backgroundColor = UIColor(hex: newColor.hexCode)
        colorCodeTextfield.text = newColor.hexCode
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageColorViewController = segue.destination as? ColorPageViewController {
            self.pageColorViewController = pageColorViewController
        }

        if segue.identifier == "ChooseColorWithCamera" {
            if let customCameraView = segue.destination as? CustomCameraViewController {
                customCameraView.customCameraDelegate = self
            }
        }
    }

    @IBAction func colorNameDidChange(_ sender: UITextField) {
        mainColor.name = sender.text ?? mainColor.name
    }

    @IBAction func maMauDidChange(_ sender: UITextField) {
        guard let hexCode = sender.text else {
            sender.text = mainColor.hexCode
            return
        }

        let exception: UInt32 = 16_777_215 // Todo: ffffff

        let canner = Scanner(string: hexCode)
        var value: UInt32 = exception
        canner.scanHexInt32(&value)

        if value >= exception {
            sender.text = mainColor.hexCode
            return
        }

        mainColor.hexCode = hexCode
        updateUI(newColor: mainColor)
    }

    @IBAction func maMauTouchUpOutside(_ sender: UITextField) {
    }

    @IBAction func switchColorSegmeted(_ sender: UISegmentedControl) {
        switchColorView(index: sender.selectedSegmentIndex)
        pageColorViewController?.whichToPage(index: sender.selectedSegmentIndex, updateColor: UIColor(hex: mainColor.hexCode))
    }

    @IBAction func saveDidSelect(_ sender: UIBarButtonItem) {
        colorManager.appentColor(colorModel: mainColor)
        guard let colorListView = (storyboard?.instantiateViewController(withIdentifier: "ColorListView") as? ColorListViewController) else {
            return
        }
        self.navigationController?.pushViewController(colorListView, animated: true)
    }

    @IBAction func mixColor(_ sender: UIButton) {
        guard let chooseColorView = (storyboard?.instantiateViewController(withIdentifier: "ChooseColorsView") as? ChooseColorsViewController) else {
            return
        }
        chooseColorView.mainColor = mainColor
        self.navigationController?.pushViewController(chooseColorView, animated: true)
    }

    private func switchColorView(index: Int) {
        let images = [#imageLiteral(resourceName: "RGB"), #imageLiteral(resourceName: "CMYK"), #imageLiteral(resourceName: "HSV")]
        let imagesBW = [#imageLiteral(resourceName: "RGBB&W"), #imageLiteral(resourceName: "CMYKB&W"), #imageLiteral(resourceName: "HSVB&W")]
        for index in 0...2 {
            colorsSegmented.setImage(imagesBW[index], forSegmentAt: index)
        }
        colorsSegmented.setImage(images[index], forSegmentAt: index)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension HomeViewController: ColorPageViewControllerDelegate {
    func sliderAction(pageViewController: UIPageViewController, colorHexCode: String) {
        mainColor.hexCode = colorHexCode
        updateUI(newColor: mainColor)
    }
}

extension HomeViewController: CustomCameraDelegate {
    func choosedColor(colorHexResult: String) {
        if colorHexResult.isEmpty { return }
        mainColor.hexCode = colorHexResult
        updateUI(newColor: mainColor)
        print("Done choose color: ", colorHexResult)
    }
}
