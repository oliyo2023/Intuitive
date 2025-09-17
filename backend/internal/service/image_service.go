package service

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"image-generator-backend/internal/domain"
	"image-generator-backend/internal/platform/supabase"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/google/uuid"
	"github.com/volcengine/volc-sdk-golang/service/visual"
)

// ImageService provides image generation business logic.
type ImageService struct {
	// You can add dependencies like a repository here
}

// NewImageService creates a new ImageService.
func NewImageService() *ImageService {
	return &ImageService{}
}

// ProcessImageGeneration handles the core logic of generating an image.
func (s *ImageService) ProcessImageGeneration(ctx context.Context, prompt string, userId string) (string, error) {
	client, err := supabase.NewClient()
	if err != nil {
		return "", err
	}

	// 1. Check user credits
	var profile []domain.Profile
	data, _, err := client.From("profiles").Select("*", "exact", false).Eq("id", userId).Execute()
	if err != nil {
		return "", fmt.Errorf("failed to fetch profile: %w", err)
	}
	if err := json.Unmarshal(data, &profile); err != nil {
		return "", fmt.Errorf("failed to unmarshal profile data: %w", err)
	}

	if len(profile) == 0 {
		adminClient, err := supabase.NewAdminClient()
		if err != nil {
			return "", fmt.Errorf("failed to create supabase admin client: %w", err)
		}

		newProfileData := map[string]interface{}{
			"id":                 userId,
			"subscription_level": "free",
			"credits":            10,
		}

		_, _, err = adminClient.From("profiles").Upsert(newProfileData, "id", "", "").Execute()
		if err != nil {
			return "", fmt.Errorf("failed to upsert profile for user %s: %w", userId, err)
		}

		profile = []domain.Profile{
			{
				ID:                userId,
				SubscriptionLevel: "free",
				Credits:           10,
			},
		}
	}

	if profile[0].Credits <= 0 {
		return "", fmt.Errorf("insufficient credits")
	}

	// 2. Generate image with Volcengine
	volcResp, err := callVolcengineAPI(prompt) // This should be in its own service too
	if err != nil {
		return "", fmt.Errorf("Volcengine API failed: %w", err)
	}

	dataField, ok := volcResp["data"].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("no 'data' field in Volcengine response: %v", volcResp)
	}

	images, ok := dataField["binary_data_base64"].([]interface{})
	if !ok || len(images) == 0 {
		return "", fmt.Errorf("no 'binary_data_base64' in Volcengine response: %v", volcResp)
	}

	imageBase64, ok := images[0].(string)
	if !ok {
		return "", fmt.Errorf("image data is not a string: %v", images[0])
	}

	imageBytes, err := base64.StdEncoding.DecodeString(imageBase64)
	if err != nil {
		return "", fmt.Errorf("failed to decode base64 image: %w", err)
	}

	// 3. Upload to Supabase Storage
	fileName := fmt.Sprintf("%s.png", uuid.New().String())
	bucket := "ai-images"
	path := fmt.Sprintf("generated_images/%s", fileName)

	publicURL, err := uploadToSupabaseStorage(ctx, bucket, path, imageBytes)
	if err != nil {
		return "", err
	}

	// 4. Decrement user credits
	newCredits := profile[0].Credits - 1
	_, _, err = client.From("profiles").Update(map[string]interface{}{"credits": newCredits}, "", "").Eq("id", userId).Execute()
	if err != nil {
		log.Printf("Failed to decrement credits for user %s: %v", userId, err)
	}

	// 5. Save record to database
	insertData := []map[string]interface{}{
		{
			"id":         uuid.New().String(),
			"prompt":     prompt,
			"image_url":  publicURL,
			"created_at": time.Now().UTC().Format(time.RFC3339),
			"user_id":    userId,
		},
	}

	_, _, err = client.From("generated_images").Insert(insertData, false, "", "", "").Execute()
	if err != nil {
		log.Printf("Failed to save image record to database: %v", err)
	}

	return publicURL, nil
}

// TODO: Move these to their own services/packages

func uploadToSupabaseStorage(ctx context.Context, bucket, path string, data []byte) (string, error) {
	supabaseUrl := os.Getenv("SUPABASE_URL")
	supabaseServiceKey := os.Getenv("SUPABASE_SERVICE_ROLE_KEY")
	if supabaseUrl == "" || supabaseServiceKey == "" {
		return "", fmt.Errorf("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
	}

	// Construct the URL: https://<project-ref>.supabase.co/storage/v1/object/<bucket>/<path>
	url := fmt.Sprintf("%s/storage/v1/object/%s/%s", supabaseUrl, bucket, path)

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewReader(data))
	if err != nil {
		return "", fmt.Errorf("failed to create upload request: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+supabaseServiceKey)
	req.Header.Set("Content-Type", "image/png")
	req.Header.Set("x-upsert", "true") // Use "true" to enable upsert

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to execute upload request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("upload failed with status %d: %s", resp.StatusCode, string(bodyBytes))
	}

	// Construct the public URL
	publicURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s", supabaseUrl, bucket, path)
	return publicURL, nil
}

func callVolcengineAPI(prompt string) (map[string]interface{}, error) {
	// This should be initialized once, not on every call.
	visual.DefaultInstance.Client.SetAccessKey(os.Getenv("VOLC_AK"))
	visual.DefaultInstance.Client.SetSecretKey(os.Getenv("VOLC_SK"))
	reqBody := map[string]interface{}{
		"req_key":       "sd_xl",
		"prompt":        prompt,
		"model_version": "sd_xl_v1",
		"width":         1024,
		"height":        1024,
		"return_url":    false,
	}

	resp, status, err := visual.DefaultInstance.CVProcess(reqBody)
	if err != nil {
		return nil, fmt.Errorf("API call error: %w", err)
	}
	if status != http.StatusOK {
		respBytes, _ := json.Marshal(resp)
		return nil, fmt.Errorf("API returned non-200 status: %d, response: %s", status, string(respBytes))
	}

	return resp, nil
}
