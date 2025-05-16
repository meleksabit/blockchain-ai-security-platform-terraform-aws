package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

type Config struct {
	Port          string
	BlockchainURL string
	AnomalyURL    string
}

type AnomalyData struct {
	BlockNumber uint64 `json:"block_number"`
	TxCount     uint   `json:"tx_count"`
	Anomaly     string `json:"anomaly"`
}

func getConfig() Config {
	return Config{
		Port:          os.Getenv("PORT"),
		BlockchainURL: os.Getenv("BLOCKCHAIN_URL"),
		AnomalyURL:    os.Getenv("ANOMALY_URL"),
	}
}

func main() {
	cfg := getConfig()
	if cfg.Port == "" {
		cfg.Port = "8083"
	}
	if cfg.BlockchainURL == "" {
		cfg.BlockchainURL = "http://blockchain-monitor:8081"
	}
	if cfg.AnomalyURL == "" {
		cfg.AnomalyURL = "http://anomaly-detector:8082"
	}

	r := gin.Default()
	r.LoadHTMLGlob("templates/*")

	r.GET("/dashboard", func(c *gin.Context) {
		client := &http.Client{Timeout: 5 * time.Second}

		// Fetch latest block
		resp, err := client.Get(cfg.BlockchainURL + "/block/latest")
		if err != nil {
			c.HTML(http.StatusInternalServerError, "dashboard.tmpl", gin.H{"Error": err.Error()})
			return
		}
		defer resp.Body.Close()
		var blockData struct {
			BlockNumber uint64 `json:"block_number"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&blockData); err != nil {
			c.HTML(http.StatusInternalServerError, "dashboard.tmpl", gin.H{"Error": "Invalid block response"})
			return
		}

		// Fetch anomaly data
		resp, err = client.Get(cfg.AnomalyURL + "/anomaly/check")
		if err != nil {
			c.HTML(http.StatusInternalServerError, "dashboard.tmpl", gin.H{"Error": err.Error()})
			return
		}
		defer resp.Body.Close()
		var anomaly AnomalyData
		if err := json.NewDecoder(resp.Body).Decode(&anomaly); err != nil {
			c.HTML(http.StatusInternalServerError, "dashboard.tmpl", gin.H{"Error": "Invalid anomaly response"})
			return
		}

		c.HTML(http.StatusOK, "dashboard.tmpl", gin.H{
			"LatestBlock":     blockData.BlockNumber,
			"TransactionCount": anomaly.TxCount,
			"Anomaly":         anomaly.Anomaly,
			"LastUpdated":     time.Now().Format(time.RFC1123),
		})
	})

	log.Printf("Starting dashboard on port %s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
