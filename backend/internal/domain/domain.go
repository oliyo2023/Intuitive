package domain

import "time"

// GenerateRequest defines the structure for a generation request.
type GenerateRequest struct {
	Prompt string `json:"prompt" binding:"required"`
}

// ApiResponse defines the standard API response structure.
type ApiResponse struct {
	Code int         `json:"code"`
	Msg  string      `json:"msg"`
	Data interface{} `json:"data,omitempty"`
}

// ImageResponse defines the data structure for a successful image generation.
type ImageResponse struct {
	ImageUrl string `json:"imageUrl"`
}

// VideoResponse defines the data structure for a successful video generation.
type VideoResponse struct {
	VideoUrl string `json:"videoUrl"`
}

// Profile defines the structure of a user profile in the database.
type Profile struct {
	ID                string    `json:"id"`
	UpdatedAt         time.Time `json:"updated_at"`
	SubscriptionLevel string    `json:"subscription_level"`
	Credits           int       `json:"credits"`
}