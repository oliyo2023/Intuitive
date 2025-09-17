package handler

import (
	"net/http"

	"image-generator-backend/internal/domain"
	"image-generator-backend/internal/service"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// ImageHandler holds the services needed by the image handlers.
type ImageHandler struct {
	ImageService *service.ImageService
}

// NewImageHandler creates a new ImageHandler.
func NewImageHandler(imageService *service.ImageService) *ImageHandler {
	return &ImageHandler{ImageService: imageService}
}

// GenerateImage handles the image generation request.
func (h *ImageHandler) GenerateImage(c *gin.Context) {
	var req domain.GenerateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		Fail(c, http.StatusBadRequest, 40001, "Invalid request parameters: "+err.Error())
		return
	}

	userID, exists := c.Get("userID")
	if !exists {
		Fail(c, http.StatusUnauthorized, 40101, "User not authenticated")
		return
	}

	userIDString := userID.(uuid.UUID).String()

	imageUrl, err := h.ImageService.ProcessImageGeneration(c.Request.Context(), req.Prompt, userIDString)
	if err != nil {
		// Here you can map different service errors to different codes
		Fail(c, http.StatusInternalServerError, 50001, err.Error())
		return
	}

	Success(c, domain.ImageResponse{ImageUrl: imageUrl})
}