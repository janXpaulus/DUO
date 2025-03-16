package api

import (
	"log"
)

// CanPlaceCard checks if a card can be placed on top of another card
func CanPlaceCard(cardToPlace Card, topCardOnStack Card) bool {

	log.Printf("Checking if card %v can be placed on top of card %v", cardToPlace, topCardOnStack)

    // Check if the card to place has the same color or value as the top card
    if cardToPlace.CardColor == topCardOnStack.CardColor
        || cardToPlace.CardValue == topCardOnStack.CardValue
        || cardToPlace.CardColor == "wild"
        || topCardOnStack.CardColor == "wild" 
        {
		log.Printf("Card %v can be placed on top of card %v", cardToPlace, topCardOnStack)
        return true
    }


    return false
}