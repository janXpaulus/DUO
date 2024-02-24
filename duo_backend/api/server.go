package api

import (
	"log"

	db "github.com/duo/db/sqlc"
	"github.com/duo/pb"
	"github.com/duo/token"
	"github.com/duo/util"
)

type Server struct {
	pb.UnimplementedDUOServiceServer
	Config util.Config
	Store  db.Store
	Maker  token.Maker
}

func NewServer(store db.Store, config util.Config) *Server {

	maker, makerErr := token.NewPasetoMaker(config.TokenSymmetricKey)
	if makerErr != nil {
		log.Fatalf("Error creating token maker: %s", makerErr)
	}

	return &Server{
		Store:  store,
		Config: config,
		Maker:  maker,
	}
}

func (server *Server) OnError(err error) {
	if err != nil {
		log.Printf("An error occurred: %s", err)
	}
}
