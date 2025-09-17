package supabase

import (
	"fmt"
	"os"

	"github.com/supabase-community/supabase-go"
)

// NewClient creates a new Supabase client with the anonymous key.
func NewClient() (*supabase.Client, error) {
	supabaseUrl := os.Getenv("SUPABASE_URL")
	supabaseKey := os.Getenv("SUPABASE_ANON_KEY")
	if supabaseUrl == "" || supabaseKey == "" {
		return nil, fmt.Errorf("SUPABASE_URL and SUPABASE_ANON_KEY must be set")
	}
	return supabase.NewClient(supabaseUrl, supabaseKey, nil)
}

// NewAdminClient creates a new Supabase client with the service role key.
func NewAdminClient() (*supabase.Client, error) {
	supabaseUrl := os.Getenv("SUPABASE_URL")
	supabaseServiceKey := os.Getenv("SUPABASE_SERVICE_ROLE_KEY")
	if supabaseUrl == "" || supabaseServiceKey == "" {
		return nil, fmt.Errorf("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
	}
	return supabase.NewClient(supabaseUrl, supabaseServiceKey, nil)
}