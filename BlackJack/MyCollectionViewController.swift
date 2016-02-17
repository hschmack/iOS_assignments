//
//  MyCollectionViewController.swift
//  BlackJack
//
//  Created by Jing Li on 2/10/16.
//  Copyright © 2016 CBC. All rights reserved.
//

import UIKit

class MyCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var deckCountLabel: UILabel!
    @IBOutlet weak var cardCountLabel: UILabel!
    @IBOutlet weak var buttonHit: UIButton!
    @IBOutlet weak var buttonStand: UIButton!
    
    @IBOutlet weak var dealerView: UICollectionView!
    
//    private var dealerCardView = [Card]()
//    private var playerCardView = [Card]()
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.dealerView) {
            return gameModel.getPlayerCardCount()
        }
        return 2
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //let myCellView = collectionView.cellForItemAtIndexPath(indexPath) as! cardCollectionViewCell
        
        let myCellView = collectionView.dequeueReusableCellWithReuseIdentifier("CellView", forIndexPath: indexPath) as! cardCollectionViewCell
        
        let i = indexPath.row
        
        if (collectionView == dealerView) {
            if let dealerCard = gameModel.dealerCardAtIndex(i){
                print ("CARD ADDED WITH VALUE: \(dealerCard.digit)")
                if dealerCard.isFaceUp{
                    myCellView.myCell.image = dealerCard.getCardImage()
                }else{
                    myCellView.myCell.image = UIImage(named: "card-back.png")
                }
            }
        }
        
        //position the cells
        myCellView.frame.origin = CGPoint(x: i*30, y: 8)
        
        return myCellView
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
        
        buttonHit.enabled = true
        buttonStand.enabled = true
        
    }
    
    @IBAction func playerHit(sender: UIButton) {
        let card = gameModel.nextPlayerCard()
        card.isFaceUp = true
        renderCards()
        //...
        gameModel.updateGameStage()
        
        if gameModel.gameStage == .BJGameStageDealer{
            playDealerTurn()
        }
    }
    
    @IBAction func playerStand(sender: UIButton) {
        gameModel.gameStage = .BJGameStageDealer
        playDealerTurn()
    }
    
    func gamesOverForReal() {
        buttonHit.enabled = false;
        buttonStand.enabled = false;
        
        let alert = UIAlertController(title: "Blackjack", message: "Out of Decks", preferredStyle: UIAlertControllerStyle.Alert)
        
        showViewController(alert, sender: self)
        
    }
    
    // CHANGE THIS
    func renderCards(){
        dealerView.reloadData()
    }
    
    // DONT NEED TO CHANGE THESE
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
