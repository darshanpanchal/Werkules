//
//  ActivityCell.swift
//  Entreprenetwork
//
//  Created by Sujal Adhia on 25/12/19.
//  Copyright © 2019 Sujal Adhia. All rights reserved.
//

import UIKit
import AVKit

class ActivityCell: UITableViewCell,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPostTitle: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnLikeCounts: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet var imageCollectionView: UICollectionView!
    @IBOutlet weak var pageControl:UIPageControl!
    @IBOutlet weak var labelSeparator: UILabel!
    @IBOutlet weak var viewRibbon: UIView!
    @IBOutlet weak var lblEstimatedPrize: UILabel!
    @IBOutlet weak var btnRibbon: UIButton!
    
    
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    
    var jobPhotosArray = NSArray()
    
    var delegate:imageDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        RegisterCell()
    }
    
    override func layoutSubviews() {
        imageCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func RegisterCell()  {
        
        imageCollectionView.register(UINib.init(nibName: "ActivityImageCell", bundle: nil), forCellWithReuseIdentifier: "ActivityImageCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityImageCell", for: indexPath as IndexPath) as! ActivityImageCell
        
        var jobPicUrl = jobPhotosArray.object(at: indexPath.row) as! String
        jobPicUrl = jobPicUrl.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        if jobPicUrl.contains(".mp4") == true {
            
            cell.btnJobPic.isHidden = true
            cell.videoPlayerView.isHidden = false
            let player = AVPlayer(url: URL(string: jobPicUrl)!)
            player.isMuted = true
            cell.videoPlayerView.playerLayer.player = player
            cell.videoPlayerView.player?.isMuted = true
            
            cell.videoPlayerView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            cell.videoPlayerView.player!.play()
            
            cell.videoPlayerView.tag = indexPath.row
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullVideo))
            cell.videoPlayerView.addGestureRecognizer(tapGesture)
        }
        else {
            cell.btnJobPic.isHidden = false
            cell.videoPlayerView.isHidden = true
            
            cell.btnJobPic.imageView?.contentMode = .scaleAspectFill
            //        cell.btnJobPic.contentHorizontalAlignment = .fill
            //        cell.btnJobPic.contentVerticalAlignment = .fill
            cell.btnJobPic.sd_setImage(with: URL(string: jobPicUrl), for:.normal, placeholderImage: UIImage(named:"Icon_Add_Picture"), options: []) { (image,
                error, cache, url) in
                
            }
            cell.btnJobPic.tag = indexPath.row
            cell.btnJobPic.addTarget(self, action: #selector(jobPicSelected), for: .touchUpInside)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //You would get something like "model.count" here. It would depend on your data source
        
        return jobPhotosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.window?.frame.size.width)!, height: (self.window?.frame.size.width)!)
         return CGSize(width:90, height: 90)
    }
    
    @objc func jobPicSelected(_ sender : UIButton) {
        
        delegate.didPressButton(button: sender)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        print("page = \(page)")
        
        self.pageControl.currentPage = page
    }
    
    @objc func showFullVideo(_ sender : UITapGestureRecognizer) {

        let view = sender.view as! PlayerView
        let tag = view.tag
        var url = jobPhotosArray.object(at: tag) as! String
        url = url.replacingOccurrences(of: "https://projectw-host.s3.amazonaws.com", with: "http://d3rt0l8qiy6b8v.cloudfront.net")
        
        delegate.showFullVideo(url: url)
    }
}

protocol imageDelegate {
    
    func didPressButton(button:UIButton)
    func showFullVideo(url : String)
}
