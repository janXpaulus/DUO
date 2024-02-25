// Code generated by sqlc. DO NOT EDIT.
// versions:
//   sqlc v1.17.2
// source: session.sql

package db

import (
	"context"

	"github.com/google/uuid"
)

const createSession = `-- name: CreateSession :one
INSERT INTO game_session (pin, owner_id, max_players) VALUES ($1, $2, $3) RETURNING id, pin, owner_id, max_players
`

type CreateSessionParams struct {
	Pin        string    `json:"pin"`
	OwnerID    uuid.UUID `json:"owner_id"`
	MaxPlayers int32     `json:"max_players"`
}

func (q *Queries) CreateSession(ctx context.Context, arg CreateSessionParams) (GameSession, error) {
	row := q.db.QueryRowContext(ctx, createSession, arg.Pin, arg.OwnerID, arg.MaxPlayers)
	var i GameSession
	err := row.Scan(
		&i.ID,
		&i.Pin,
		&i.OwnerID,
		&i.MaxPlayers,
	)
	return i, err
}

const deleteSessionByID = `-- name: DeleteSessionByID :one
DELETE FROM game_session WHERE id = $1 RETURNING id, pin, owner_id, max_players
`

func (q *Queries) DeleteSessionByID(ctx context.Context, id int32) (GameSession, error) {
	row := q.db.QueryRowContext(ctx, deleteSessionByID, id)
	var i GameSession
	err := row.Scan(
		&i.ID,
		&i.Pin,
		&i.OwnerID,
		&i.MaxPlayers,
	)
	return i, err
}

const getSessionByID = `-- name: GetSessionByID :one
SELECT id, pin, owner_id, max_players FROM game_session WHERE id = $1
`

func (q *Queries) GetSessionByID(ctx context.Context, id int32) (GameSession, error) {
	row := q.db.QueryRowContext(ctx, getSessionByID, id)
	var i GameSession
	err := row.Scan(
		&i.ID,
		&i.Pin,
		&i.OwnerID,
		&i.MaxPlayers,
	)
	return i, err
}

const getSessionByOwnerUUID = `-- name: GetSessionByOwnerUUID :one
SELECT id, pin, owner_id, max_players FROM game_session WHERE owner_id = $1
`

func (q *Queries) GetSessionByOwnerUUID(ctx context.Context, ownerID uuid.UUID) (GameSession, error) {
	row := q.db.QueryRowContext(ctx, getSessionByOwnerUUID, ownerID)
	var i GameSession
	err := row.Scan(
		&i.ID,
		&i.Pin,
		&i.OwnerID,
		&i.MaxPlayers,
	)
	return i, err
}
