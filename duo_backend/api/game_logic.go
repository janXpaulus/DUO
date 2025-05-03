package api

import (
	"log"
    "github.com/duo/pb"
)

// CanPlaceCard checks if a card can be placed on top of another card
func CanPlaceCard(cardToPlace Card, topCardOnStack Card) bool {

	log.Printf("Checking if card %v can be placed on top of card %v", cardToPlace, topCardOnStack)

    // Check if the card to place has the same color or value as the top card
    if cardToPlace.CardColor == topCardOnStack.CardColor || cardToPlace.CardValue == topCardOnStack.CardValue || cardToPlace.CardColor == "wild" || topCardOnStack.CardColor == "wild" {
		log.Printf("Card %v can be placed on top of card %v", cardToPlace, topCardOnStack)
        return true
    }


    return false
}


func isSpecialCard(card Card) bool {
    log.Printf("Checking if card %v is a special card", card.CardId)
    return card.CardType == "special"
}

// Implement the logic for special cards
func handleSpecialCard(cardToPlace Card, game *Game) (int, pb.Direction) {
    log.Printf("Handling special card %v", cardToPlace)

    playerOffset := 1 // Default to the next player

    switch cardToPlace.CardValue {
    case "suspend":
        // FIXME Index out of range
        log.Printf("Suspended next player")
        playerOffset = 1 // Skip next player
    case "change_directions":
        log.Printf("Changing directions")
        if game.Direction == pb.Direction_CLOCKWISE {
            game.Direction = pb.Direction_COUNTER_CLOCKWISE
            log.Printf("New game direction: %v", game.Direction)
        } else {
            game.Direction = pb.Direction_CLOCKWISE
            log.Printf("New game direction: %v", game.Direction)
        }
    }

    return playerOffset, game.Direction
}


