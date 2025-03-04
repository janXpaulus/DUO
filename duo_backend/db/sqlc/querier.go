// Code generated by sqlc. DO NOT EDIT.
// versions:
//   sqlc v1.20.0

package db

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
)

type Querier interface {
	AddFriendRequest(ctx context.Context, arg AddFriendRequestParams) (FriendRequest, error)
	AddFriendship(ctx context.Context, arg AddFriendshipParams) (Friendship, error)
	AddGameDrawStack(ctx context.Context, arg AddGameDrawStackParams) (GameStackDrawCardRel, error)
	AddGamePlaceStack(ctx context.Context, arg AddGamePlaceStackParams) (GameStackPlaceCardRel, error)
	AddPlayerToGame(ctx context.Context, arg AddPlayerToGameParams) (GamePlayerRel, error)
	ClearNotificationsByUserId(ctx context.Context, userID uuid.UUID) (sql.Result, error)
	CreateGameState(ctx context.Context, arg CreateGameStateParams) (GameState, error)
	CreateLobby(ctx context.Context, arg CreateLobbyParams) (Lobby, error)
	CreateNotification(ctx context.Context, arg CreateNotificationParams) (Notification, error)
	CreateUser(ctx context.Context, arg CreateUserParams) (Duouser, error)
	CreateUserLogin(ctx context.Context, arg CreateUserLoginParams) (UserLogin, error)
	DeleteFriendRequest(ctx context.Context, arg DeleteFriendRequestParams) (FriendRequest, error)
	DeleteFriendship(ctx context.Context, arg DeleteFriendshipParams) (Friendship, error)
	DeleteGameState(ctx context.Context, id int32) (GameState, error)
	DeleteLobbyByID(ctx context.Context, id int32) (Lobby, error)
	DeleteUserLoginByUUID(ctx context.Context, userUuid uuid.UUID) (UserLogin, error)
	GetFriendsByUserId(ctx context.Context, user2ID uuid.UUID) ([]GetFriendsByUserIdRow, error)
	GetGameDrawStack(ctx context.Context, gameID int64) ([]GameStackDrawCardRel, error)
	GetGamePlaceStack(ctx context.Context, gameID int64) ([]GameStackPlaceCardRel, error)
	GetGameStateById(ctx context.Context, id int32) (GameState, error)
	GetLobbyByID(ctx context.Context, id int32) (Lobby, error)
	GetLobbyByOwnerUUID(ctx context.Context, ownerID uuid.UUID) (Lobby, error)
	GetNotificationsByUserId(ctx context.Context, userID uuid.UUID) ([]Notification, error)
	GetOpenFriendRequestByRequesteeId(ctx context.Context, requesteeID uuid.UUID) ([]FriendRequest, error)
	GetPlayersGameId(ctx context.Context, playerID uuid.UUID) (GamePlayerRel, error)
	GetPlayersInGame(ctx context.Context, gameID int32) ([]GamePlayerRel, error)
	GetUserByUUID(ctx context.Context, argUuid uuid.UUID) (Duouser, error)
	GetUserLoginByUUID(ctx context.Context, userUuid uuid.UUID) (UserLogin, error)
	RemoveGameDrawStack(ctx context.Context, arg RemoveGameDrawStackParams) (GameStackDrawCardRel, error)
	RemoveGamePlaceStack(ctx context.Context, arg RemoveGamePlaceStackParams) (GameStackPlaceCardRel, error)
	RemovePlayerFromGame(ctx context.Context, arg RemovePlayerFromGameParams) (GamePlayerRel, error)
	UpdateFriendRequestStatus(ctx context.Context, arg UpdateFriendRequestStatusParams) (FriendRequest, error)
	UpdateGameState(ctx context.Context, arg UpdateGameStateParams) (GameState, error)
	UpdateStackUUID(ctx context.Context, arg UpdateStackUUIDParams) (Lobby, error)
	UpdateUserStatus(ctx context.Context, arg UpdateUserStatusParams) (Duouser, error)
}

var _ Querier = (*Queries)(nil)
