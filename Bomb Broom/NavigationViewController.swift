//
//  NavigationView.swift
//  HW3
//
//  Created by Angela Vompa on 4/15/20.
//  Copyright © 2020 Enrico Vompa. All rights reserved.
//

import UIKit

class NavigationViewController: UIViewController {

    // MARK: - Navigation

    @IBOutlet weak var tileSizeTextField: UITextField!
    @IBOutlet weak var bombIconTextField: UITextField!
    @IBOutlet weak var explosionIconTextField: UITextField!
    @IBOutlet weak var flagIconTextField: UITextField!
    @IBOutlet weak var bombAmountSlider: UISlider!
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            print("prepare for seque " + identifier)
            switch identifier {
            case "1":
                if let vc = segue.destination as? GameController {
                    vc.amountOfBombs = 0.10;
                    GameController.bombIcon = bombIconTextField.text ?? GameController.bombIcon;
                    GameController.explosionIcon = explosionIconTextField.text ?? GameController.explosionIcon;
                    GameController.flagIcon = flagIconTextField.text ?? GameController.flagIcon;
                    
                }
            case "2":
                if let vc = segue.destination as? GameController {
                    vc.amountOfBombs = 0.20;
                    GameController.bombIcon = bombIconTextField.text ?? GameController.bombIcon;
                    GameController.explosionIcon = explosionIconTextField.text ?? GameController.explosionIcon;
                    GameController.flagIcon = flagIconTextField.text ?? GameController.flagIcon;
                }
            case "3":
                if let vc = segue.destination as? GameController {
                    vc.amountOfBombs = 0.30;
                    GameController.bombIcon = bombIconTextField.text ?? GameController.bombIcon;
                    GameController.explosionIcon = explosionIconTextField.text ?? GameController.explosionIcon;
                    GameController.flagIcon = flagIconTextField.text ?? GameController.flagIcon;
                }
            case "c":
                if let vc = segue.destination as? GameController {
                    GameController.bombIcon = bombIconTextField.text ?? GameController.bombIcon;
                    GameController.explosionIcon = explosionIconTextField.text ?? GameController.explosionIcon;
                    GameController.flagIcon = flagIconTextField.text ?? GameController.flagIcon;
                    vc.amountOfBombs = Double(bombAmountSlider.value);
                    vc.tileSize = CGFloat(Int(tileSizeTextField.text ?? "44") ?? 44);
                }
            default:
                print("/shrug")
            }
        }
    }
    

}
