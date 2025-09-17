package main

import (
	"log"
	"os"

	"image-generator-backend/internal/config"
	"image-generator-backend/internal/handler"
	"image-generator-backend/internal/middleware"
	"image-generator-backend/internal/service"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load and validate configuration
	config.Load()
	config.Validate()

	// Initialize services
	imageService := service.NewImageService()

	// Initialize handlers
	imageHandler := handler.NewImageHandler(imageService)
	videoHandler := handler.NewVideoHandler()

	// Set up router
	r := gin.Default()

	// Apply middlewares
	r.Use(middleware.CORSMiddleware())

	// Set up routes
	api := r.Group("/api")
	api.Use(middleware.AuthMiddleware())
	{
		api.POST("/generate-image", imageHandler.GenerateImage)
		api.POST("/generate-video", videoHandler.GenerateVideo)
	}

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Server starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to run server: %v", err)
	}
}