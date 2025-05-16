package main

import (
    "context"
    "fmt"
    "log"
    "math"
    "math/big"
    "errors"
    "net/http"
    "os"
    "strconv"
    "time"

    "github.com/ethereum/go-ethereum/ethclient"
    "github.com/gin-gonic/gin"
    "github.com/hashicorp/vault/api"
)

type Config struct {
    Network    string
    Port       string
    VaultAddr  string
    VaultToken string
}

func getConfig() Config {
    cfg := Config{
        Network:    os.Getenv("NETWORK"),
        Port:       os.Getenv("PORT"),
        VaultAddr:  os.Getenv("VAULT_ADDR"),
        VaultToken: os.Getenv("VAULT_TOKEN"),
    }
    if cfg.Network == "" {
        cfg.Network = "sepolia" // Default to testnet for safety
    }
    if cfg.Port == "" {
        cfg.Port = "8081"
    }
    if cfg.VaultAddr == "" {
        cfg.VaultAddr = "http://vault:8200"
    }
    return cfg
}

func getInfuraKeyFromVault(cfg Config) (string, error) {
    client, err := api.NewClient(&api.Config{Address: cfg.VaultAddr})
    if err != nil {
        return "", fmt.Errorf("failed to create Vault client: %v", err)
    }
    client.SetToken(cfg.VaultToken)
    log.Printf("Fetching Infura key from Vault at %s", cfg.VaultAddr)

    secret, err := client.Logical().Read("secret/data/infura")
    if err != nil {
        return "", fmt.Errorf("failed to read Vault secret at secret/data/infura: %v", err)
    }
    if secret == nil {
        return "", fmt.Errorf("no secret found at secret/data/infura")
    }

    data, ok := secret.Data["data"].(map[string]interface{})
    if !ok || data == nil {
        return "", fmt.Errorf("invalid Vault data format: no 'data' field or not a map")
    }

    key, ok := data["api_key"]
    if !ok || key == nil {
        return "", fmt.Errorf("no infura key found in Vault data: %v", data)
    }

    infuraKey, ok := key.(string)
    if !ok {
        return "", fmt.Errorf("invalid infura key format in Vault, expected string, got %T", key)
    }

    // Mask only for logging purposes
    maskedKey := maskKey(infuraKey)
    log.Printf("Vault secret raw data: %v", map[string]interface{}{
        "data":     map[string]interface{}{"api_key": maskedKey},
        "metadata": secret.Data["metadata"],
    })
    log.Printf("Successfully retrieved Infura key: %s", maskedKey)

    return infuraKey, nil // Return unmasked key
}

// Helper function to mask the key
func maskKey(key string) string {
    if len(key) <= 8 {
        return "****" // Mask the entire key if it's too short
    }
    return key[:4] + "..." + key[len(key)-4:]
}

type BlockchainService struct {
    client *ethclient.Client
}

func connectWeb3(cfg Config, infuraKey string) (*ethclient.Client, error) {
    var url string
    switch cfg.Network {
    case "local":
        url = "http://localhost:8545"
    case "sepolia", "ropsten":
        url = fmt.Sprintf("https://%s.infura.io/v3/%s", cfg.Network, infuraKey)
    default:
        return nil, fmt.Errorf("unsupported network: %s", cfg.Network)
    }

    for attempt := 1; attempt <= 5; attempt++ {
        client, err := ethclient.Dial(url)
        if err == nil {
            ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
            defer cancel()
            if _, err = client.NetworkID(ctx); err == nil {
                log.Printf("Connected to %s on attempt %d", cfg.Network, attempt)
                return client, nil
            }
        }
        log.Printf("Attempt %d failed for %s: %v", attempt, cfg.Network, err)
        if attempt == 5 {
            break
        }
        wait := time.Duration(1<<uint(attempt-1)) * time.Second
        if wait > 60*time.Second {
            wait = 60 * time.Second
        }
        time.Sleep(wait)
    }
    return nil, fmt.Errorf("failed to connect to %s after 5 attempts", cfg.Network)
}

func NewBlockchainService(cfg Config) (*BlockchainService, error) {
    infuraKey, err := getInfuraKeyFromVault(cfg)
    if err != nil {
        return nil, err
    }
    client, err := connectWeb3(cfg, infuraKey)
    if err != nil {
        return nil, err
    }
    return &BlockchainService{client: client}, nil
}

func (s *BlockchainService) GetLatestBlock(ctx context.Context) (uint64, error) {
    header, err := s.client.HeaderByNumber(ctx, nil)
    if err != nil {
        return 0, err
    }
    return header.Number.Uint64(), nil
}

func (s *BlockchainService) GetTransactionCount(ctx context.Context, blockNumber uint64) (uint, error) {
    if blockNumber > uint64(math.MaxInt64) {
        return 0, errors.New("block number exceeds maximum int64 value")
    }
    block, err := s.client.BlockByNumber(ctx, big.NewInt(int64(blockNumber)))
    if err != nil {
        return 0, err
    }
    return uint(len(block.Transactions())), nil
}

func main() {
    cfg := getConfig()
    svc, err := NewBlockchainService(cfg)
    if err != nil {
        log.Fatalf("Failed to initialize blockchain service: %v", err)
    }

    r := gin.Default()

    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"status": "ok", "network": cfg.Network})
    })

    r.GET("/block/latest", func(c *gin.Context) {
        ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
        defer cancel()
        blockNum, err := svc.GetLatestBlock(ctx)
        if err != nil {
            log.Printf("Failed to get latest block: %v", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }
        c.JSON(http.StatusOK, gin.H{"block_number": blockNum})
    })

    r.GET("/block/:number/transactions", func(c *gin.Context) {
        blockNumStr := c.Param("number")
        blockNum, err := strconv.ParseUint(blockNumStr, 10, 64)
        if err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": "invalid block number"})
            return
        }
        ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
        defer cancel()
        txCount, err := svc.GetTransactionCount(ctx, blockNum)
        if err != nil {
            log.Printf("Failed to get tx count for block %d: %v", blockNum, err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }
        c.JSON(http.StatusOK, gin.H{"block_number": blockNum, "transaction_count": txCount})
    })

    log.Printf("Starting blockchain-monitor on port %s, network: %s", cfg.Port, cfg.Network)
    if err := r.Run(":" + cfg.Port); err != nil {
        log.Fatalf("Failed to start server: %v", err)
    }
}
