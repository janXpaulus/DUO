// Code generated by sqlc. DO NOT EDIT.
// versions:
//   sqlc v1.17.2

package db

import (
	"context"

	"github.com/google/uuid"
)

type Querier interface {
	AddGameDrawStack(ctx context.Context, arg AddGameDrawStackParams) (GameStackDrawCardRel, error)
	AddGamePlaceStack(ctx context.Context, arg AddGamePlaceStackParams) (GameStackPlaceCardRel, error)
	AddPlayerToGame(ctx context.Context, arg AddPlayerToGameParams) (GamePlayerRel, error)
	CreateGameState(ctx context.Context, arg CreateGameStateParams) (GameState, error)
	CreateLobby(ctx context.Context, arg CreateLobbyParams) (Lobby, error)
	CreateUser(ctx context.Context, arg CreateUserParams) (Duouser, error)
	CreateUserLogin(ctx context.Context, arg CreateUserLoginParams) (UserLogin, error)
	DeleteGameState(ctx context.Context, id int32) (GameState, error)
	DeleteLobbyByID(ctx context.Context, id int32) (Lobby, error)
	DeleteUserLoginByUUID(ctx context.Context, userUuid uuid.UUID) (UserLogin, error)
	GetGameDrawStack(ctx context.Context, gameID int64) ([]GameStackDrawCardRel, error)
	GetGamePlaceStack(ctx context.Context, gameID int64) ([]GameStackPlaceCardRel, error)
	GetGameStateById(ctx context.Context, id int32) (GameState, error)
	GetLobbyByID(ctx context.Context, id int32) (Lobby, error)
	GetLobbyByOwnerUUID(ctx context.Context, ownerID uuid.UUID) (Lobby, error)
	GetPlayersGameId(ctx context.Context, playerID uuid.UUID) (GamePlayerRel, error)
	GetPlayersInGame(ctx context.Context, gameID int64) ([]GamePlayerRel, error)
	GetUserByUUID(ctx context.Context, uuid uuid.UUID) (Duouser, error)
	GetUserLoginByUUID(ctx context.Context, userUuid uuid.UUID) (UserLogin, error)
	RemoveGameDrawStack(ctx context.Context, arg RemoveGameDrawStackParams) (GameStackDrawCardRel, error)
	RemoveGamePlaceStack(ctx context.Context, arg RemoveGamePlaceStackParams) (GameStackPlaceCardRel, error)
	RemovePlayerFromGame(ctx context.Context, arg RemovePlayerFromGameParams) (GamePlayerRel, error)
	UpdateGameState(ctx context.Context, arg UpdateGameStateParams) (GameState, error)
	UpdateStackUUID(ctx context.Context, arg UpdateStackUUIDParams) (Lobby, error)
}

var _ Querier = (*Queries)(nil)
