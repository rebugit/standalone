package main

import (
	"context"
	"github.com/Nerzal/gocloak/v8"
	"log"
	"os"
	"strings"
)

type keycloak struct {
	client      gocloak.GoCloak
	jwt         *gocloak.JWT
	realmName   string
	clientName  string
	rebugitHost string
	username    string
	password    string
}

// This is for first time creation only since import configuration does not work properly

func NewKeycloak() (*keycloak, error) {
	adminUsername := os.Getenv("KEYCLOAK_ADMIN_USER")
	adminPassword := os.Getenv("KEYCLOAK_ADMIN_PASSWORD")
	keycloakHost := os.Getenv("KEYCLOAK_HOST")
	rebugitHost := os.Getenv("REBUGIT_HOST")
	realmName := os.Getenv("KEYCLOAK_REALM_NAME")
	username := os.Getenv("KEYCLOAK_USER_NAME")
	userPassword := os.Getenv("KEYCLOAK_USER_PASSWORD")

	client := gocloak.NewClient(keycloakHost)
	token, err := client.LoginAdmin(context.Background(), adminUsername, adminPassword, "master")
	if err != nil {
		return nil, err
	}

	return &keycloak{
		client:      client,
		jwt:         token,
		realmName:   realmName,
		clientName:  "web",
		rebugitHost: rebugitHost,
		username:    username,
		password:    userPassword,
	}, nil
}

// CreateUser This will create a new keycloak user. Note, if the user already exists it will skip its creation,
// otherwise it will fail
func (k keycloak) CreateUser() error {
	token := k.jwt.AccessToken

	log.Printf("[Rebugit migrator]: Search for existing user with email: %v", k.username)
	getUserCountParams := gocloak.GetUsersParams{
		Email:    gocloak.StringP(k.username),
		Enabled:  gocloak.BoolP(true),
		Username: gocloak.StringP(k.username),
	}
	count, err := k.client.GetUserCount(context.Background(), token, k.realmName, getUserCountParams)
	if err != nil {
		return err
	}

	log.Printf("[Rebugit migrator]: Users found: %v", count)
	if count > 0 {
		log.Println("[Rebugit migrator]: User already exists, skipping user creation")
		return nil
	}

	user := gocloak.User{
		Username:      gocloak.StringP(k.username),
		Enabled:       gocloak.BoolP(true),
		EmailVerified: gocloak.BoolP(true),
		Email:         gocloak.StringP(k.username),
		Credentials: &[]gocloak.CredentialRepresentation{
			{
				Temporary: gocloak.BoolP(false),
				Type:      gocloak.StringP("password"),
				Value:     gocloak.StringP(k.password),
			},
		},
	}
	if _, err := k.client.CreateUser(context.Background(), token, k.realmName, user); err != nil {
		return err
	}

	log.Printf("[Rebugit migrator]: New user created with email: %v", k.username)

	return nil
}

func (k keycloak) CreateRealm() error {
	foundRealm, err := k.client.GetRealm(context.Background(), k.jwt.AccessToken, k.realmName)
	if err != nil {
		if strings.Contains(err.Error(), "Realm not found") {
			log.Printf("[Rebugit migrator]: Realm with name: %v, not found", k.realmName)
		} else {
			return err
		}
	}

	if foundRealm != nil {
		log.Printf("[Rebugit migrator]: Found realm with name: %v, skipping creation", *foundRealm.Realm)
		return nil
	}

	log.Printf("[Rebugit migrator]: Creating realm: %v with user: %v", k.realmName, k.username)
	realm := gocloak.RealmRepresentation{
		Enabled:               gocloak.BoolP(true),
		Realm:                 gocloak.StringP(k.realmName),
		LoginWithEmailAllowed: gocloak.BoolP(true),
		BruteForceProtected:   gocloak.BoolP(true),
		AccessTokenLifespan:   gocloak.IntP(900),
		Clients: &[]gocloak.Client{
			{
				ClientID:    gocloak.StringP(k.clientName),
				Description: gocloak.StringP("Rebugit dashboard client"),
				Enabled:     gocloak.BoolP(true),
				Name:        gocloak.StringP(k.clientName),
				RedirectURIs: &[]string{
					"/rebugit/web/*",
				},
				RootURL: gocloak.StringP(k.rebugitHost),
				WebOrigins: &[]string{
					k.rebugitHost,
				},
				PublicClient: gocloak.BoolP(true),
			},
		},
	}
	if _, err := k.client.CreateRealm(context.Background(), k.jwt.AccessToken, realm); err != nil {
		return err
	}

	log.Printf("[Rebugit migrator]: Realm created: %v", k.realmName)

	return nil
}
