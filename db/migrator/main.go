package main

import (
	"context"
	"fmt"
	"github.com/Nerzal/gocloak/v8"
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

func KeycloakClient() (gocloak.GoCloak, *gocloak.JWT, error) {
	adminUsername := os.Getenv("KEYCLOAK_ADMIN_USER")
	adminPassword := os.Getenv("KEYCLOAK_ADMIN_PASSWORD")
	keycloakHost := os.Getenv("KEYCLOAK_HOST")

	client := gocloak.NewClient(keycloakHost)
	token, err := client.LoginAdmin(context.Background(), adminUsername, adminPassword, "master")
	if err != nil {
		return nil, nil, err
	}

	return client, token, nil
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

	if err := CreateKeycloakUser(); err != nil {
		log.Fatal(err)
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
	if err := client.Up(); err != nil {
		log.Println(err)

		if err == migrate.ErrNoChange {
			os.Exit(0)
		}

		if err := client.Down(); err != nil {
			log.Fatal(err)
		}
	}
	log.Println("[Rebugit migrator]: Migration done")
	return nil
}

func CreateUserPassword(client *pgx.Conn) error {
	password := os.Getenv("POSTGRES_USER_PASSWORD")
	if password == "" {
		log.Println("[Rebugit migrator]: WARNING: you are using a default user password, this is could be EXTREMELY UNSAFE, " +
			"you should set your password with POSTGRES_USER_PASSWORD")
	}

	log.Println("[Rebugit migrator]: adding password to user app")
	query := fmt.Sprintf("ALTER USER app WITH PASSWORD '%s'", password)
	if _, err := client.Exec(context.Background(), query); err != nil {
		return err
	}

	log.Println("[Rebugit migrator]: password added")

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

// CreateKeycloakUser This will create a new keycloak user. Note, if the user already exists it will skip its creation,
// otherwise it will fail
func CreateKeycloakUser() error {
	realmName := os.Getenv("KEYCLOAK_REALM_NAME")
	username := os.Getenv("KEYCLOAK_USER_NAME")

	client, jwt, err := KeycloakClient()
	if err != nil {
		return err
	}

	log.Printf("[Rebugit migrator]: Search for existing user with email: %v", username)
	getUserCountParams := gocloak.GetUsersParams{
		Email:               gocloak.StringP(username),
		Enabled:             gocloak.BoolP(true),
		Username:            gocloak.StringP(username),
	}
	count, err := client.GetUserCount(context.Background(), jwt.AccessToken, realmName, getUserCountParams)
	if err != nil {
		return err
	}

	log.Printf("[Rebugit migrator]: Users found: %v", count)
	if count > 0 {
		log.Println("[Rebugit migrator]: User already exists, skipping user creation")
		return nil
	}

	user := gocloak.User{
		Username:      gocloak.StringP(username),
		Enabled:       gocloak.BoolP(true),
		EmailVerified: gocloak.BoolP(true),
		Email:         gocloak.StringP(username),
		Credentials: &[]gocloak.CredentialRepresentation{
			{
				Temporary:         gocloak.BoolP(false),
				Type:              gocloak.StringP("password"),
				Value:             gocloak.StringP(os.Getenv("KEYCLOAK_USER_PASSWORD")),
			},
		},
	}
	if _, err := client.CreateUser(context.Background(), jwt.AccessToken, realmName, user); err != nil {
		return err
	}

	log.Printf("[Rebugit migrator]: New user created with email: %v", username)

	return nil
}
