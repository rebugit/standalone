package main

import (
	"fmt"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"log"
	"os"
)

func main() {
	connectionURI, err := getConnectionURI()
	if err != nil {
		log.Fatal(err)
	}

	m, err := migrate.New("file://migrations", connectionURI)
	if err != nil {
		log.Fatal(err)
	}

	if err := m.Up(); err != nil {
		log.Println(err)

		if err == migrate.ErrNoChange {
			os.Exit(0)
		}

		if err := m.Down(); err != nil {
			log.Fatal(err)
		}
	}

	log.Println("Migration done")
}

func getConnectionURI() (string, error) {
	creds, err := getCredentials()
	if err != nil {
		return "", err
	}
	Port := 5432

	connectionURI := fmt.Sprintf(
		"postgres://%v:%v@%v:%v/%v?sslmode=disable",
		creds.Username,
		creds.Password,
		creds.Host,
		Port,
		creds.Dbname,
	)
	return connectionURI, nil
}

type credentials struct {
	Password string `json:"password"`
	Host     string `json:"host"`
	Dbname   string `json:"dbname"`
	Username string `json:"username"`
}

func getCredentials() (credentials, error) {
	return credentials{
		Password: os.Getenv("POSTGRES_PASSWORD"),
		Host:     os.Getenv("POSTGRES_HOST"),
		Dbname:   "rebugit",
		Username: os.Getenv("POSTGRES_ADMIN"),
	}, nil
}