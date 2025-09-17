package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

// Load initializes the configuration by loading environment variables.
func Load() {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file not found, relying on system environment variables.")
	}
}

// Validate ensures that all essential environment variables are set.
func Validate() {
	essentialEnvs := []string{"SUPABASE_URL", "SUPABASE_ANON_KEY", "SUPABASE_SERVICE_ROLE_KEY", "VOLC_AK", "VOLC_SK"}
	for _, env := range essentialEnvs {
		if os.Getenv(env) == "" {
			log.Fatalf("Error: Environment variable %s must be set. If running locally, ensure .env file is present and all keys are filled.", env)
		}
	}
}