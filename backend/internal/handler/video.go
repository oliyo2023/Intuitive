package handler

import (
	"log"
	"net/http"
	"time"

	"image-generator-backend/internal/domain"

	"github.com/gin-gonic/gin"
)

// VideoHandler holds the services needed by the video handlers.
type VideoHandler struct {
	// VideoService *service.VideoService // In the future
}

// NewVideoHandler creates a new VideoHandler.
func NewVideoHandler() *VideoHandler {
	return &VideoHandler{}
}

// GenerateVideo handles the video generation request.
func (h *VideoHandler) GenerateVideo(c *gin.Context) {
	var req domain.GenerateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, 40001, "Invalid request parameters: "+err.Error())
		return
	}

	log.Printf("Received video generation request for prompt: %s", req.Prompt)

	// Simulate a delay
	time.Sleep(5 * time.Second)

	// Return a dummy URL
	dummyVideoURL := "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4"

	Success(c, domain.VideoResponse{VideoUrl: dummyVideoURL})
}