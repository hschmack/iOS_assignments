//
//  MyCollectionViewController.swift
//  BlackJack
//
//  Hayden Schmackpfeffer 2/17/16
//  Copyright © 2016 CBC. All rights reserved.
//

import UIKit

class MyCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var deckCountLabel: UILabel!
    @IBOutlet weak var cardCountLabel: UILabel!
    @IBOutlet weak var buttonHit: UIButton!
    @IBOutlet weak var buttonStand: UIButton!
    
    @IBOutlet weak var dealerView: UICollectionView!
    @IBOutlet weak var playerView: UICollectionView!
    
    private var gameModel : BJDGameModel
    
    required init?(coder aDecoder: NSCoder) {
        gameModel = BJDGameModel()
        super.init(coder : aDecoder)
        
        let aSelector : Selector = "handleNotificationGameDidEnd:"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: aSelector, name: "BJNotificationGameDidEnd", object: gameModel)
        
    }
    
    func handleNotificationGameDidEnd(notification: NSNotification){
        if let userInfo : Dictionary = notification.userInfo{
            if let num = userInfo["didDealerWin"] {
                let message = num.boolValue! ? "Dealer won!" : "You won!"
                let alert = UIAlertController(title: "Game Over", message: message, preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "Play again", style: .Default, handler: ({ (_: UIAlertAction)-> Void in self.restartGame() }))
                alert.addAction(alertAction)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        restartGame()
    }
    
    override func viewDidAppear(animated: Bool) {
        promptForDecks()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.dealerView) {
            return gameModel.getDealerCardCount()
        } else if (collectionView == self.playerView) {
            return gameModel.getPlayerCardCount()
        }
        return 6
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //let myCellView = collectionView.cellForItemAtIndexPath(indexPath) as! cardCollectionViewCell
        
        let myCellView = collectionView.dequeueReusableCellWithReuseIdentifier("CellView", forIndexPath: indexPath) as! cardCollectionViewCell
        
        let i = indexPath.row
        
        if (collectionView == dealerView) {
            if let dealerCard = gameModel.dealerCardAtIndex(i){
                if dealerCard.isFaceUp{
                    myCellView.myCell.image = dealerCard.getCardImage()
                    myCellView.layer.zPosition = CGFloat(i);
                }else{
                    myCellView.myCell.image = UIImage(named: "card-back.png")
                    myCellView.layer.zPosition = CGFloat(i);
                }
            }
        } else if (collectionView == playerView){
            if let playerCard = gameModel.playerCardAtIndex(i) {
                if playerCard.isFaceUp {
                    myCellView.playerCell.image = playerCard.getCardImage()
                    myCellView.layer.zPosition = CGFloat(i);
                } else {
                    myCellView.playerCell.image = UIImage(named: "card-back.png")
                    myCellView.layer.zPosition = CGFloat(i);
                }
            }
        }
        
        //position the cells
        //myCellView.frame.origin = CGPoint(x: i*30, y: 8)
        
        return myCellView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(-100)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func playDealerTurn(){
        buttonHit.enabled = false
        buttonStand.enabled = false
        
        showSecondDealerCard()
        
    }
    
    func showNextDealerCard(){
        let card = gameModel.nextDealerCard()
        card.isFaceUp = true
        renderCards()
        gameModel.updateGameStage()
        if gameModel.gameStage != .BJGameStageGameOver {
            let aSelector : Selector = "showNextDealerCard"
            performSelector(aSelector, withObject: nil, afterDelay: 0.5)
            
            //showNextDealerCard()
        }
    }
    
    func updateCardCount(){
        let cardCount = String(gameModel.getCardCount())
        cardCountLabel.text = "Cards Left: " + cardCount
    }
    
    func updateDeckCount(){
        let deckCount = String(gameModel.getDecksRemaining());
        deckCountLabel.text = "Remaining Decks: \(deckCount)"
    }
    
    func showSecondDealerCard(){
        if let card = gameModel.lastDealerCard(){
            card.isFaceUp = true
            renderCards()
            gameModel.updateGameStage()
            if(gameModel.gameStage != .BJGameStageGameOver){
                let aSelector : Selector = "showNextDealerCard"
                performSelector(aSelector, withObject: nil, afterDelay: 0.5)
                //showNextDealerCard()
            }
        }
    }
    
    func restartGame(){
        if (gameModel.resetGame() == false) {
            gamesOverForReal()
            return
        }
        var card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        
        card = gameModel.nextDealerCard()
        card.isFaceUp = true
        card = gameModel.nextDealerCard()
        
        gameModel.checkIfPlayerHasBlackjack()
        renderCards()
        updateDeckCount()
        renderDealer()
        
        buttonHit.enabled = true
        buttonStand.enabled = true
        
    }
    
    @IBAction func playerHit(sender: UIButton) {
        let card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        renderCards()
        //...
        gameModel.updateGameStage()
    }
    
    @IBAction func playerStand(sender: UIButton) {
        gameModel.gameStage = .BJGameStageDealer
        renderCards()
        playDealerTurn()
    }
    
    // final function called, creates Notifcation that you are out of decks
    func gamesOverForReal() {
        buttonHit.enabled = false;
        buttonStand.enabled = false;
        
        let alert = UIAlertController(title: "Blackjack", message: "Out of Decks Thanks for Playing, restart the app if you want to continue", preferredStyle: UIAlertControllerStyle.Alert)
        
        showViewController(alert, sender: self)
        
    }
    func renderDealer(){
        dealerView.reloadData()
    }
    
    func renderCards(){
        if (gameModel.gameStage == .BJGameStageDealer) {
            dealerView.reloadData()
        } else {
            playerView.reloadData()
        }
        updateCardCount()
    }

    func promptForDecks() {
        let deckPrompt = UIAlertController(title: "Blackjack", message: "Enter the amount of decks you want to play with", preferredStyle: UIAlertControllerStyle.Alert)
        deckPrompt.addTextFieldWithConfigurationHandler(addTextField)
        deckPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        deckPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: gotDeckPrompt))
        presentViewController(deckPrompt, animated: true, completion: nil)
    }
    
    @IBOutlet var deckInput: UITextField?
    
    func gotDeckPrompt(alert: UIAlertAction!) {
        guard let deckNum = Int(deckInput!.text!) else {
            return
        }
        gameModel.setDecks(deckNum-1)
        updateDeckCount()
    }
    
    func addTextField(textField: UITextField!) {
        textField.keyboardType = UIKeyboardType.NumberPad
        self.deckInput = textField
    }


}
