import logging
import os
import re
import hvac
import subprocess
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from web3 import Web3
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from functools import lru_cache
import time
import torch
import asyncio
from requests.exceptions import HTTPError

# Custom log formatter to redact Infura key dynamically
class RedactingFormatter(logging.Formatter):
    def format(self, record):
        msg = super().format(record)
        infura_key = os.environ.get("INFURA_API_KEY", "unknown")
        return re.sub(rf"https://(sepolia|ropsten)\.infura\.io/v3/{infura_key}", "https://[network].infura.io/v3/[REDACTED]", msg)

# Configure Logging
logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(RedactingFormatter(fmt="%(asctime)s - %(levelname)s - %(message)s"))
logger.handlers = [handler]
logger.setLevel(logging.INFO)

# FastAPI app
app = FastAPI()

# Default network from env, fallback to "sepolia"
NETWORK = os.environ.get("NETWORK", "sepolia")

# AI Model
class AIModel:
    instance = None
    model_loaded = False
    tokenizer = None
    model = None

    @classmethod
    def get_instance(cls):
        if cls.instance is None:
            cls.instance = cls()
        return cls.instance

    async def load_model(self):
        cache_dir = "./model_cache"
        try:
            logger.info("🏁Starting AI model loading at %s", time.ctime())
            start_time = time.time()
            # Check if cache exists and contains config.json
            cache_path = os.path.join(cache_dir, "config.json")
            local_only = os.path.exists(cache_path)
            self.tokenizer = AutoTokenizer.from_pretrained("cardiffnlp/twitter-roberta-base-sentiment", cache_dir=cache_dir, local_files_only=local_only)
            self.model = AutoModelForSequenceClassification.from_pretrained("cardiffnlp/twitter-roberta-base-sentiment", cache_dir=cache_dir, local_files_only=local_only)
            load_duration = time.time() - start_time
            self.model_loaded = True
            logger.info("⏳⌛AI model loaded in %.2f seconds", load_duration)
            logger.info("🚀AI Model Loaded Successfully!✅")
        except Exception as e:
            logger.error(f"🚧 ⚠️Error loading AI model: {e}⚠️ 🚧")
            self.model_loaded = False
            raise

    def analyze(self, tx_data, web3):
        if not self.model_loaded:
            raise RuntimeError("⌛AI Model not loaded yet⏳")
        text = f"TX: {tx_data['from']} -> {tx_data['to']}, Amount: {web3.from_wei(tx_data['value'], 'ether')} ETH, Gas: {tx_data['gas']}"
        inputs = self.tokenizer(text, return_tensors="pt", padding=True, truncation=True, max_length=512)
        with torch.no_grad():
            outputs = self.model(**inputs)
            anomaly_score = torch.softmax(outputs.logits, dim=1)[0][1].item()
        historical_avg_value = 1000000000000000000  # Placeholder
        if tx_data["value"] > historical_avg_value * 5:
            anomaly_score += 0.2
        if anomaly_score > 0.7:
            return f"/̵͇̿̿/’̿’̿ ̿ ̿̿ ̿̿ ̿̿💥High Anomaly Score: {anomaly_score:.2f} -> Potential Risk!☣️☢️"
        elif anomaly_score > 0.5:
            return f" 🕵️ Medium Anomaly Score: {anomaly_score:.2f} -> Needs Review👀"
        else:
            return f"👌Normal Transaction (Score: {anomaly_score:.2f})"

# Ensure hf_xet is installed
def ensure_hf_xet():
    try:
        import hf_xet
        logger.info("📦hf_xet package is already installed✅")
    except ImportError:
        logger.warning("🚨hf_xet not installed in image, expected pre-installation. Falling back to HTTP download.⚠️")

# Health endpoint
@app.get("/health")
async def health_check():
    try:
        web3 = connect_web3()
        ai_model = AIModel.get_instance()
        if ai_model.model_loaded:
            return {"status": "🌾💚healthy", "web3_connected": web3.is_connected(), "model_loaded": True, "network": NETWORK}
        else:
            return {"status": "⏳⌛loading", "web3_connected": web3.is_connected(), "model_loaded": False, "network": NETWORK}, 200
    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"⚠️👎Health check failed: {e}")
        return {"ـــــــــــــــﮩ٨ـ❤️️status": "☣️☠️unhealthy", "⚠️error⚠️": "An internal error has occurred."}, 503

# Vault client setup
@lru_cache(maxsize=1)
def get_vault_client():
    vault_addr = os.environ.get("VAULT_ADDR", "http://vault:8200")
    client = hvac.Client(url=vault_addr)
    client.token = os.environ.get("VAULT_AUTH_TOKEN")
    if not client.is_authenticated():
        raise Exception("Vault authentication failed")
    logger.info("🔐Vault client authenticated successfully✅")
    return client

# Secrets retrieval
@lru_cache(maxsize=1)
def get_infura_key():
    client = get_vault_client()
    try:
        secret = client.secrets.kv.v2.read_secret_version(path="infura", mount_point="secret")
        api_key = secret["data"]["data"]["api_key"]
        if api_key.startswith("https://"):
            logger.warning("⚠︎ ⚡︎Infura key from Vault appears to be a full URL - extracting key")
            api_key = api_key.split("/")[-1]
        os.environ["INFURA_API_KEY"] = api_key
        logger.info("🔑Infura key retrieved from Vault✅")
        return api_key
    except Exception as e:
        logger.error(f"⛔Vault Infura Error: {e}")
        raise

@retry(
    wait=wait_exponential(multiplier=1, min=4, max=60),
    stop=stop_after_attempt(5),
    retry=retry_if_exception_type(HTTPError)
)
def connect_web3(network=NETWORK):
    if network == "local":
        url = "http://localhost:8545"
    elif network in ["sepolia", "ropsten"]:
        infura_key = get_infura_key()
        url = f"https://{network}.infura.io/v3/{infura_key}"
    else:
        logger.error(f"💀💻Unsupported network: {network}")
        raise ValueError(f"💀💻Unsupported network: {network}")
    
    try:
        web3 = Web3(Web3.HTTPProvider(url))
        connected = web3.is_connected()
        if not connected:
            logger.error(f"🔗💔Web3 connection failed - {network} not reachable (key redacted)")
            raise HTTPException(status_code=503, detail=f"Failed to connect to {network}")
        logger.info(f"🔗Connected to {network} blockchain!✅")
        return web3
    except HTTPError as e:
        logger.error(f"🌐❌HTTP error connecting to {network}: {e} (key redacted)")
        raise
    except Exception as e:
        logger.error(f"🌐🔗⛓️Web3 connection error for {network}: {e} (key redacted)")
        raise HTTPException(status_code=503, detail=f"{network} connection unavailable")

# Block caching
block_cache = {}
CACHE_TTL = 300  # 5 minutes

def get_latest_block_data(web3):
    current_time = time.time()
    latest_block = web3.eth.block_number
    if latest_block in block_cache and (current_time - block_cache[latest_block]["timestamp"]) < CACHE_TTL:
        logger.info(f"🧹🔗Using cached block {latest_block}")
        return block_cache[latest_block]["data"]
    block_data = web3.eth.get_block(latest_block, full_transactions=True)
    block_cache[latest_block] = {"data": block_data, "timestamp": current_time}
    logger.info(f"🐕🦴Fetched new block {latest_block}")
    return block_data

# Historical data
async def fetch_historical_blocks(web3, start_block, num_blocks):
    historical_data = []
    for block_num in range(start_block, start_block + num_blocks):
        try:
            block = web3.eth.get_block(block_num, full_transactions=True)
            historical_data.append(block)
            logger.info(f"📜🏛️🏺Fetched historical block {block_num}")
            await asyncio.sleep(1)  # Avoid rate limits
        except HTTPError as e:
            logger.error(f"🛑✋Infura rate limit hit: {e}")
            break
    return historical_data

# FastAPI Endpoint
class Transaction(BaseModel):
    from_address: str
    to_address: str
    value: float
    gas: int

@app.post("/analyze")
async def analyze_transaction(tx: Transaction):
    try:
        web3 = connect_web3()
        if not web3.is_address(tx.from_address) or not web3.is_address(tx.to_address):
            raise HTTPException(status_code=400, detail="Invalid Ethereum address")
        tx_data = {"from": tx.from_address, "to": tx.to_address, "value": int(tx.value), "gas": tx.gas}
        ai_model = AIModel.get_instance()
        result = ai_model.analyze(tx_data, web3)
        logger.info(f"🧐Transaction analyzed: {tx.from_address} -> {tx.to_address} | {result}")
        return {"result": result}
    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"❌📉Analyze failed: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during analysis")

@app.on_event("startup")
async def startup_event():
    try:
        ensure_hf_xet()  # Ensure hf_xet is installed
        web3 = connect_web3()
        ai_model = AIModel.get_instance()
        logger.info("1️⃣🚀Initiating ai-agent service")
        asyncio.create_task(ai_model.load_model())  # Load model in background
        logger.info("֎🇦🇮 ai-agent service ready")
        logger.info("🏁Starting blockchain polling and historical fetch in background")
        asyncio.create_task(poll_blockchain(web3))
        asyncio.create_task(fetch_historical_blocks(web3, web3.eth.block_number - 1000, 1000))
        logger.info("🕘🗓️Startup tasks scheduled")
    except HTTPException as e:
        logger.error(f"🔴Startup failed with HTTP exception: {e.detail}")
    except Exception as e:
        logger.error(f"🔴Startup failed: {e}")

async def poll_blockchain(web3):
    ai_model = AIModel.get_instance()
    while not ai_model.model_loaded:
        logger.info("...⏳Waiting for AI model to load before polling...")
        await asyncio.sleep(5)
    while True:
        try:
            block_data = get_latest_block_data(web3)
            for tx in block_data["transactions"]:
                result = ai_model.analyze(tx, web3)
                if "High" in result or "Medium" in result:
                    logger.warning(f"/̵͇̿̿/’̿’̿ ̿ ̿̿ ̿̿ ̿̿💥Anomaly detected in block {block_data['number']}: {result}")
        except Exception as e:
            logger.error(f"🔴🗳️Polling error: {e}")
        await asyncio.sleep(10)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
    