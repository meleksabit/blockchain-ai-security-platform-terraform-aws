package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

type Config struct {
	Port          string
	BlockchainURL string
}

type BlockData struct {
	BlockNumber uint64 `json:"block_number"`
	TxCount     uint   `json:"transaction_count"`
}

func getConfig() Config {
	return Config{
		Port:          os.Getenv("PORT"),
		BlockchainURL: os.Getenv("BLOCKCHAIN_URL"),
	}
}

func main() {
	cfg := getConfig()
	if cfg.Port == "" {
		cfg.Port = "8082"
	}
	if cfg.BlockchainURL == "" {
		cfg.BlockchainURL = "http://blockchain-monitor:8081"
	}

	r := gin.Default()

	// Health endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"service": "anomaly-detector",
			"port":    cfg.Port,
			"blockchain_url": cfg.BlockchainURL,
		})
	})

	// Anomaly check endpoint
	r.GET("/anomaly/check", func(c *gin.Context) {
		client := &http.Client{Timeout: 5 * time.Second}
		resp, err := client.Get(cfg.BlockchainURL + "/block/latest")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		defer resp.Body.Close()

		var latestBlock BlockData
		if err := json.NewDecoder(resp.Body).Decode(&latestBlock); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid response"})
			return
		}

		resp, err = client.Get(fmt.Sprintf("%s/block/%d/transactions", cfg.BlockchainURL, latestBlock.BlockNumber))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		defer resp.Body.Close()

		var blockTx BlockData
		if err := json.NewDecoder(resp.Body).Decode(&blockTx); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid tx response"})
			return
		}

		// Anomaly logic: High tx count
		if blockTx.TxCount > 100 {
			c.JSON(http.StatusOK, gin.H{
				"block_number": blockTx.BlockNumber,
				"tx_count":     blockTx.TxCount,
				"anomaly":      "High transaction volume detected",
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"block_number": blockTx.BlockNumber,
			"tx_count":     blockTx.TxCount,
			"anomaly":      "None",
		})
	})

	log.Printf("Starting anomaly-detector on port %s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
