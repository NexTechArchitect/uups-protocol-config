-include .env

.PHONY: all clean install update build test snapshot format anvil deploy-v1 upgrade-v1-v2 upgrade-v2-v3 help

# -------------------------------------------------
# DEFAULTS
# -------------------------------------------------

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
LOCAL_RPC := http://localhost:8545

# -------------------------------------------------
# CORE COMMANDS
# -------------------------------------------------

all: clean install build

clean:
	forge clean

install:
	forge install foundry-rs/forge-std --no-commit
	forge install openzeppelin/openzeppelin-contracts --no-commit
	forge install openzeppelin/openzeppelin-contracts-upgradeable --no-commit

update:
	forge update

build:
	forge build

test:
	forge test -vv

snapshot:
	forge snapshot

format:
	forge fmt

# -------------------------------------------------
# LOCAL CHAIN
# -------------------------------------------------

anvil:
	anvil -m "test test test test test test test test test test test junk" \
	--steps-tracing --block-time 1

# -------------------------------------------------
# NETWORK CONFIG
# -------------------------------------------------

NETWORK_ARGS := --rpc-url $(LOCAL_RPC) \
	--private-key $(DEFAULT_ANVIL_KEY) \
	--broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) \
	--private-key $(PRIVATE_KEY) \
	--broadcast
endif

# -------------------------------------------------
# DEPLOY & UPGRADE
# -------------------------------------------------

deploy-v1:
	forge script script/DeployProtocolConfigV1.s.sol \
	$(NETWORK_ARGS)

upgrade-v1-v2:
	forge script script/UpgradeV1ToV2.s.sol \
	$(NETWORK_ARGS)

upgrade-v2-v3:
	forge script script/UpgradeV2ToV3.s.sol \
	$(NETWORK_ARGS)

# -------------------------------------------------
# HELP
# -------------------------------------------------

help:
	@echo "Available commands:"
	@echo ""
	@echo "  make build              Build contracts"
	@echo "  make test               Run tests"
	@echo "  make anvil              Start local anvil node"
	@echo ""
	@echo "  make deploy-v1           Deploy V1 behind proxy"
	@echo "  make upgrade-v1-v2       Upgrade proxy V1 → V2"
	@echo "  make upgrade-v2-v3       Upgrade proxy V2 → V3"
	@echo ""
	@echo "  make deploy-v1 ARGS='--network sepolia'"
	@echo "  make upgrade-v1-v2 ARGS='--network sepolia'"
