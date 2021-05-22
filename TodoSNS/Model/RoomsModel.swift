//
//  RoomsModel.swift
//  TodoSNS
//
//  Created by 藤井凜 on 2021/01/06.
//

import Foundation

struct RoomsModel {
  let roomName:String
  let userName:String
  let docID:String
  let likeCount:Int //いいねの数
  let likeFlagDic:Dictionary<String, Any> //key:誰が（uidで識別）, value:いいねなのか取り消したのか(true,false)
  let postDate:Double
}
