package middleware

import (
	"net/http"
	"strings"

	"image-generator-backend/internal/platform/supabase"

	"github.com/gin-gonic/gin"
)

// AuthMiddleware creates a gin middleware for authenticating users.
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		client, err := supabase.NewClient()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create Supabase client"})
			c.Abort()
			return
		}

		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
			c.Abort()
			return
		}

		token := strings.TrimPrefix(authHeader, "Bearer ")

		user, err := client.Auth.WithToken(token).GetUser()

		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token: " + err.Error()})
			c.Abort()
			return
		}

		c.Set("userID", user.ID)
		c.Next()
	}
}