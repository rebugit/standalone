package main

import (
	"context"
	"fmt"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/jackc/pgx/v4"
	"log"
	"os"
)

func PgxClient(connectionURI string) (*pgx.Conn, error) {
	return pgx.Connect(context.Background(), connectionURI)
}

func MigrateClient(connectionURI string) (*migrate.Migrate, error) {
	return migrate.New("file://migrations", connectionURI)
}

func main() {
	connectionURI := getConnectionURI()
	pgxClient, err := PgxClient(connectionURI)
	if err != nil {
		log.Fatal(err)
	}
	if err := CreateUserPassword(pgxClient); err != nil {
		log.Fatal(err)
	}

	keycloak, err := NewKeycloak()
	if err != nil {
		log.Fatal(err)
	}

	if err := keycloak.CreateRealm(); err != nil {
		log.Fatal(err)
	}

	if err := keycloak.CreateUser(); err != nil {
		log.Fatal()
	}

	migrateClient, err := MigrateClient(connectionURI)
	if err != nil {
		log.Fatal(err)
	}
	if err := migrateDb(migrateClient); err != nil {
		log.Fatal(err)
	}
}

func migrateDb(client *migrate.Migrate) error {
	log.Println("[Rebugit migrator]: Postgres: starting migration")
	if err := client.Up(); err != nil {
		log.Println(err)

		if err == migrate.ErrNoChange {
			os.Exit(0)
		}

		if err := client.Down(); err != nil {
			log.Fatal(err)
		}
	}
	log.Println("[Rebugit migrator]: Postgres: migration done")
	return nil
}

func CreateUserPassword(client *pgx.Conn) error {
	password := os.Getenv("POSTGRES_USER_PASSWORD")
	if password == "" {
		log.Println("[Rebugit migrator]: WARNING: you are using a default user password, this is could be EXTREMELY UNSAFE, " +
			"you should set your password with POSTGRES_USER_PASSWORD")
	}

	log.Println("[Rebugit migrator]: Postgres: adding password to user app")
	query := fmt.Sprintf("ALTER USER app WITH PASSWORD '%s'", password)
	if _, err := client.Exec(context.Background(), query); err != nil {
		return err
	}

	log.Println("[Rebugit migrator]: Postgres: password added to user app")

	return nil
}

func getConnectionURI() string {
	connectionURI := fmt.Sprintf(
		"postgres://%v:%v@%v:%v/%v?sslmode=disable",
		os.Getenv("POSTGRES_ADMIN"),
		os.Getenv("POSTGRES_PASSWORD"),
		os.Getenv("POSTGRES_HOST"),
		os.Getenv("POSTGRES_PORT"),
		"rebugit",
	)
	return connectionURI
}
