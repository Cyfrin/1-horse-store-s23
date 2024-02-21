-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil huff

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all:  remove install build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install openzeppelin/openzeppelin-contracts@v5.0.1 --no-commit && forge install huff-language/huffmate --no-commit && forge install huff-language/foundry-huff --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

coverage :; forge coverage 

coverage-report :; forge coverage --report debug > coverage-report.txt

scope :; tree ./src/ | sed 's/└/#/g; s/──/--/g; s/├/#/g; s/│ /|/g; s/│/|/g'

scopefile :; @tree ./src/ | sed 's/└/#/g' | awk -F '── ' '!/\.sol$$/ { path[int((length($$0) - length($$2))/2)] = $$2; next } { p = "src"; for(i=2; i<=int((length($$0) - length($$2))/2); i++) if (path[i] != "") p = p "/" path[i]; print p "/" $$2; }' > scope.txt

slither :; slither . --config-file slither.config.json 

huff :; huffc -e shanghai -b ./src/HorseStore.huff > compiled_huff.txt

yul :; solc --strict-assembly --optimize --optimize-runs 20000 yul/HorseStoreYul.yul --bin | grep 60 

aderyn :; aderyn . 