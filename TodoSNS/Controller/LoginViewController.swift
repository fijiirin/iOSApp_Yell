//
//  LoginViewController.swift
//  TodoSNS
//
//  Created by 藤井凜 on 2021/01/05.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
  
  
  @IBOutlet weak var textField: UITextField!
  
  var userIdString = String()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    composeUnderline()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true //ナビゲーションバーを非表示
    
  }
  
  
  func login() {
    //匿名ログイン(結果がクロージャーで返ってくる)
    Auth.auth().signInAnonymously { (authResult, error) in
      let user = authResult?.user //返ってきた結果のユーザー情報をインスタンス化
      print(user.debugDescription)
      UserDefaults.standard.set(self.textField.text, forKey: "userName") //テキストをアプリ内に保存
      //画面遷移
      let tabVC = self.storyboard?.instantiateViewController(identifier: "tabVC") as! UITabBarController
      self.navigationController?.pushViewController(tabVC, animated: true)
    }
  }
  
  //ログインボタン（以下２つ）
  @IBAction func done(_ sender: Any) {
    login()
  }
  @IBAction func done2(_ sender: Any) {
    login()
  }
  
  //textFieldの下線を作成
  func composeUnderline() {
    let border = CALayer() //下線をインスタンス化
    let width = CGFloat(2.0)
    
    border.borderColor = UIColor.gray.cgColor //色の設定
    border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: 1)
    border.borderWidth = width
    
    textField.placeholder = "名前を入力してください"
    textField.layer.addSublayer(border)
  }
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    textField.resignFirstResponder()
  }
  
}
