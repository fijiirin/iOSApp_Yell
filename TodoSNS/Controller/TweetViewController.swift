//
//  TweetViewController.swift
//  TodoSNS
//
//  Created by 藤井凜 on 2021/01/05.
//

import UIKit
import Firebase
import FirebaseFirestore

class TweetViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  
  let db = Firestore.firestore()
  var roomModelDatas:[RoomsModel] = [] //構造体が入る配列を用意する
  var idString = String()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UINib(nibName: "CustomCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    
    if UserDefaults.standard.object(forKey: "documentID") != nil { //保存されたユーザーIDを取得
      idString = UserDefaults.standard.object(forKey: "documentID") as! String
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
    
    if UserDefaults.standard.object(forKey: "documentID") != nil { //nilでなければ
      idString = UserDefaults.standard.object(forKey: "documentID") as! String //自身のIDを代入
    } else {
      idString = db.collection("Rooms").document().path //pathをidとして代入
      print(idString) //idStringにはRooms/lijf734g8f3gのような投稿者の
      idString = String(idString.dropFirst(6)) //pathのRooms/までを削除
      UserDefaults.standard.set(idString, forKey: "documentID") //アプリ内に保存
    }
    //データのロード
    loadData()
  }
  
  func loadData() {
    db.collection("Rooms").order(by: "postDate").addSnapshotListener { (snapShot, error) in
      self.roomModelDatas = [] //配列の初期化
      if error != nil {
        return
      }
      
      if let snapShotDoc = snapShot?.documents {
        for doc in snapShotDoc { //ドキュメントの数だけ回す
          let data = doc.data() //ドキュメントの中身を変数化
          //部屋名,ユーザー名,
          if let roomName = data["roomName"] as? String, let userName = data["userName"] as? String, let likeCount = data["like"] as? Int, let likeFlagDic = data["likeFlagDic"] as? Dictionary<String,Bool>, let postDate = data["postDate"] as? Double {
              let roomModel = RoomsModel(roomName: roomName, userName: userName, docID: doc.documentID, likeCount: likeCount, likeFlagDic: likeFlagDic, postDate: postDate)
              self.roomModelDatas.append(roomModel)
              print("情報を取得してモデルにいれました")
          }
        }
        self.roomModelDatas.reverse() //配列の中身を反転させる
        self.collectionView.reloadData()
      }
    }
  }
  
  
  //セクションの数
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  //セルの数
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return roomModelDatas.count
  }
  //セルの中身の構築
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCell
    
    cell.layer.borderWidth = 1.0
    cell.layer.borderColor = UIColor.black.cgColor
    cell.contentLabel.text = "\(roomModelDatas[indexPath.row].roomName)"
    cell.contentLabel.numberOfLines = 0
    cell.likeButton.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)
    cell.likeButton.tag = indexPath.row
    
    if (self.roomModelDatas[indexPath.row].likeFlagDic[idString] != nil) == true { //自分が対象のroomにいいねしたのか
      let flag = self.roomModelDatas[indexPath.row].likeFlagDic[idString] //flagに自身のidのBool値を入れる
      if flag as! Bool == true {
        cell.likeButton.setImage(UIImage(named: "like"), for: .normal) //trueの時はいいねした状態
        print("いいねの画像にきりかえました")
      } else if flag as! Bool == false {
        cell.likeButton.setImage(UIImage(named: "nolike"), for: .normal) //falseの時はいいねしていない状態
        print("いいねではない画像にきりかえました")
      }
    }
    
    return cell
  }
  //セルをタップした時
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let commentVC = storyboard?.instantiateViewController(identifier: "commentVC") as! CommentViewController
    commentVC.idString = roomModelDatas[indexPath.row].docID //ドキュメントのIDを渡す
    commentVC.roomNameString = "\(roomModelDatas[indexPath.row].roomName)" //部屋名
    commentVC.postDateString = "\(roomModelDatas[indexPath.row].postDate)" //投稿日
    commentVC.createRoomUserNameString = "\(roomModelDatas[indexPath.row].userName)" //投稿者名
    commentVC.likeCount = roomModelDatas[indexPath.row].likeCount //いいね数を渡す
    
    
    navigationController?.pushViewController(commentVC, animated: true)
  }
  //アイテムの大きさを設定
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.bounds.width/2.0 //collectionViewの2分の１を幅に設定
    let height = width //正方形にするので、高さを幅と同じ値にする
    
    return CGSize(width: width, height: height) //設定した幅と高さを返す
  }
  //
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }
  //
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  //
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  
  //画面遷移
  @IBAction func goCreateTweet(_ sender: Any) {
    let postVC = storyboard?.instantiateViewController(identifier: "postVC") as! PostViewController
    navigationController?.pushViewController(postVC, animated: true)
  }
  
  
  //セル内のいいねボタンを押した時
  @objc func like(_ sender:UIButton) {
    //値を送信する
    var count = Int()
    let flag = self.roomModelDatas[sender.tag].likeFlagDic[idString]
    
    if flag == nil { //１回もいいねしていない時
      count = self.roomModelDatas[sender.tag].likeCount + 1
      //いいねボタンを押したRoomに情報を入れる
      db.collection("Rooms").document(roomModelDatas[sender.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
      print("一回もいいねしてないので最初のいいねします")
    } else { //flagがあったら
      if flag as! Bool == true { //いいね状態だったら
        count = self.roomModelDatas[sender.tag].likeCount - 1
        //いいねボタンを押したRoomに情報を入れる
        db.collection("Rooms").document(roomModelDatas[sender.tag].docID).setData(["likeFlagDic":[idString:false]], merge: true)
        print("いいね状態を解除します")
      } else {
        count = self.roomModelDatas[sender.tag].likeCount + 1
        //いいねボタンを押したRoomに情報を入れる
        db.collection("Rooms").document(roomModelDatas[sender.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
        print("いいねします")
      }
    }
    //countの情報を送信する
    db.collection("Rooms").document(roomModelDatas[sender.tag].docID).updateData(["like":count], completion: nil)
    collectionView.reloadData()
    print("いいね数を送信します")
  }
  
  
}
