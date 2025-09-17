package handler

import (
	"net/http"

	"image-generator-backend/internal/domain"

	"github.com/gin-gonic/gin"
)

// Success sends a standardized successful response.
func Success(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, domain.ApiResponse{
		Code: 200,
		Msg:  "success",
		Data: data,
	})
}

// Fail sends a standardized error response.
func Fail(c *gin.Context, httpStatus int, code int, msg string) {
	c.JSON(httpStatus, domain.ApiResponse{
		Code: code,
		Msg:  msg,
		Data: nil,
	})
}